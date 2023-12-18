######################################################
#    프로그램명    : train_emr_bdsr.py
#    작성자        : Youngho Lee
#    작성일자      : 2023.12.15
#    파라미터      : None
#    설명          : AFS 기반 변수 추출 및 RF 기반 욕창 모델 학습 (MLflow 적용)
######################################################

import os
import sys
import boto3
import click
import configparser
import numpy as np
import pandas as pd
from sklearn.metrics import roc_auc_score
from sklearn.preprocessing import MinMaxScaler
from sklearn.ensemble import RandomForestClassifier

import mlflow
import mlflow.sklearn
from mlflow import MlflowClient

import tensorflow.compat.v1 as tf
tf.disable_v2_behavior()

# wd = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
wd = '/home/yhlee/test'
del sys.path[0]
sys.path.insert(0, wd)
os.chdir(wd)

import afs.afs_model
from afs.afs_utils import BatchCreate
from afs.read_to_csv import read_csv, to_csv


def afs_train(sess, train_X, train_Y, val_X, val_Y, train_step, batch_size):
    X = tf.get_collection('input')[0]
    Y = tf.get_collection('output')[0]

    Iterator = BatchCreate(train_X, train_Y)
    for step in range(1, train_step+1):
        if step % 100 == 0:
            val_loss, val_accuracy = sess.run(tf.get_collection('validate_ops'),
                                              feed_dict={X: val_X,
                                                         Y: np.expand_dims(val_Y, axis=1)})

            print('[%4d] AFS-loss:%.12f AFS-accuracy:%.6f' % (step, val_loss, val_accuracy))
        xs, ys = Iterator.next_batch(batch_size)
        _, A = sess.run(tf.get_collection('train_ops'),
                        feed_dict={X: xs, Y: np.expand_dims(ys, axis=1)})

    return A


@click.command()
@click.option('--run_name', type=click.STRING, default='test', show_default=True,
              help='MLflow Run Name 설정')
@click.option('--cut_off', default=0.7, show_default=True, help='MLflow 등록 시 임계값')


def bdsr_train(run_name, cut_off):

    # 1. config 설정
    afs_config = configparser.ConfigParser()
    afs_config.read('./afs/afs_config.ini')
    
    emr_config = configparser.ConfigParser()
    emr_config.read('./afs/emr_config.ini')

    # 1) layer
    input_size = afs_config.getint('LAYERS', 'INPUT_SIZE')
    output_size = afs_config.getint('LAYERS', 'OUTPUT_SIZE')
    E_node = afs_config.getint('LAYERS', 'E_NODE') # 32
    A_node = afs_config.getint('LAYERS', 'A_NODE')
    AO_node = afs_config.getint('LAYERS', 'AO_NODE')
    set_seed = afs_config.getint('LAYERS', 'SEED')
    L_node = afs_config.getint('LAYERS', 'L_NODE')
    moving_average_decay = afs_config.getfloat('LAYERS', 'MOVING_AVERAGE_DECAY')

    # 2) parameters
    regularization_rate = afs_config.getfloat('PARAM', 'REGULARIZATION_RATE')
    learning_rate_base = afs_config.getfloat('PARAM', 'LEARNING_RATE_BASE')
    learning_rate_decay = afs_config.getfloat('PARAM', 'LEARNING_RATE_DECAY')
    batch_size = afs_config.getint('PARAM', 'BATCH_SIZE')
    train_step = afs_config.getint('PARAM', 'TRAIN_STEP')

    # 3) data
    data_path = './data'
    std_path = './data/sub'
    features = afs_config.getint('DATA', 'FEATURES')


    # 2. gpu 설정
    device = 'GPU'
    tf.config.experimental.list_physical_devices(device)

    if device == 'GPU':
        gpus = tf.config.experimental.list_physical_devices('GPU')
        tf.config.experimental.set_visible_devices(devices=gpus[0], device_type='GPU')
        tf.config.experimental.set_virtual_device_configuration(gpus[0],
            [tf.config.experimental.VirtualDeviceConfiguration(memory_limit=4*1024)])
    else:
        os.environ['CUDA_VISIBLE_DEVICES'] = '-1'


    # 3. 데이터 로드
    print('# import data')
    rmv_clmn = rmv_clmn = ['hspt_id', 'ptnt_no', 'ckup_ywek_ix', 'ftr_bdsr_yn',
                           'bdsr_yn', 'bdsr_dgss_dt_cnt']

    trainset = read_csv(os.path.join(data_path, 'bdsr_train.csv'))
    valset = read_csv(os.path.join(data_path, 'bdsr_val.csv'))
    testset = read_csv(os.path.join(data_path, 'bdsr_test.csv'))

    train_X = trainset.drop(rmv_clmn, axis=1)
    train_X = train_X.astype('float')
    train_Y = trainset['ftr_bdsr_yn'].values

    val_X = valset.drop(rmv_clmn, axis=1)
    val_X = val_X.astype('float')
    val_Y = valset['ftr_bdsr_yn'].values

    test_X = testset.drop(rmv_clmn, axis=1)
    test_X = test_X.astype('float')
    true = testset[f'ftr_bdsr_yn'].values

    # 4. Scaler 적용
    minmax_X = MinMaxScaler()
    minmax_X.fit(train_X)
    scale_train_X = minmax_X.transform(train_X)
    scale_val_X = minmax_X.transform(val_X)
    scale_test_X = minmax_X.transform(test_X)

    std_df = pd.DataFrame({'min': minmax_X.data_min_, 'max': minmax_X.data_max_},
                          index=minmax_X.feature_names_in_).reset_index(drop=False)
    std_df['afs'] = 0

    # 5. AFS
    print('# start the AFS algorithm')
    Train_size = len(train_X)
    total_batch = Train_size / batch_size

    afs.afs_model.build(total_batch, input_size, output_size, E_node, A_node, AO_node, 
                        set_seed, L_node, moving_average_decay, regularization_rate, 
                        learning_rate_base, learning_rate_decay, batch_size, train_step)

    with tf.Session() as sess:
        tf.global_variables_initializer().run()
        print('== Get feature weight by using AFS ==')
        A = afs_train(sess, scale_train_X, train_Y, scale_val_X, val_Y,
                      train_step, batch_size)

    attention_weight = A.mean(0)
    AFS_weight_rank = list(np.argsort(attention_weight))[::-1]
    
    afs_train_X = scale_train_X[:, AFS_weight_rank[0:features]]
    afs_test_X = scale_test_X[:, AFS_weight_rank[0:features]]
    
    std_df.loc[sorted(AFS_weight_rank[0:features]), 'afs'] = 1
    to_csv(std_df, os.path.join(std_path, 'bdsr_std.csv'))

    # 6. RF 모델 학습 및 평가 (MLflow)
    print('# Train the model with MLflow')
    mlflow.set_tracking_uri(emr_config['MLFLOW']['PRIVATE_IP'])
    experiment = mlflow.set_experiment(f'emr-bdsr')

    # 모델 정보 추출
    client = MlflowClient(emr_config['MLFLOW']['PRIVATE_IP'])
    model_name = f'emr-bdsr-prod'
    latest_ver = 1

    for mv in client.search_model_versions(f"name='{model_name}'"):
        # 운영 모델 id 및 버전 추출
        if dict(mv)['current_stage'] == 'Production':
            prod_id = dict(mv)['run_id']

        # 최근 모델 버전 추출
        if int(dict(mv)['version']) > latest_ver:
            latest_ver = int(dict(mv)['version'])

    # 운영 모델 성능 추출
    prod_results = client.get_run(prod_id).data.to_dictionary()
    prod_accuracy = prod_results['metrics']['accuracy']
    prod_precision = prod_results['metrics']['precision']
    prod_recall = prod_results['metrics']['recall']

    with mlflow.start_run(experiment_id=experiment.experiment_id) as run:

        # 1) 모델 학습
        rf_model = RandomForestClassifier()
        rf_model.fit(afs_train_X, train_Y)

        # 2) 예측값 도출
        pred = pd.DataFrame(rf_model.predict(afs_test_X)).iloc[:, 0].values

        # 3) 평가
        pred_label = np.floor(pred + (1 - cut_off))
        TN = np.sum(np.logical_and(pred_label == 0, true == 0))
        FN = np.sum(np.logical_and(pred_label == 0, true == 1))
        FP = np.sum(np.logical_and(pred_label == 1, true == 0))
        TP = np.sum(np.logical_and(pred_label == 1, true == 1))

        accuracy = (TN + TP) / (TN + TP + FN + FP)
        precision = TP / (TP + FP)
        recall = TP / (TP + FN)
        f1 = 2 * (precision * recall) / (precision + recall)
        auc = roc_auc_score(true, pred)

        # 4) MLflow
        # metrics
        metrics = {
            'accuracy': round(accuracy, 3),
            'precision': round(precision, 3),
            'recall': round(recall, 3),
            'f1': round(f1, 3),
            'auc': round(auc, 3)
        }
        mlflow.sklearn.mlflow.log_metrics(metrics)

        # tags
        tags = {
            'mlflow.runName': run_name,
            'category': 'bdsr',
            'cut off': cut_off
        }
        mlflow.set_tags(tags)

        mlflow.sklearn.log_model(rf_model, 'model')
        # mlflow.sklearn.log_model(model.model, 'model', registered_model_name=model_name)
    
    # prod 모델 비교
    if (accuracy > prod_accuracy) and (precision > prod_precision) and (recall > prod_recall):
        client.transition_model_version_stage(
            name=model_name, version=latest_ver + 1, stage='Staging'
        )
    
    # s3 업로드
    print('# upload the model to s3')
    s3 = boto3.client('s3',
                      aws_access_key_id=emr_config['S3']['KEY_ID'],
                      aws_secret_access_key=emr_config['S3']['ACCESS_KEY'])
    bucket = emr_config['S3']['BUCKET']
    experiment_id=experiment.experiment_id
    run_id = run.info.run_id
    
    model_path = f'/home/mlflow/mlruns/{experiment_id}/{run_id}/'
    
    for root, dirs, files in os.walk(model_path):
        for filename in files:
            local_path = os.path.join(root, filename)
            s3_path = local_path[13:]
            s3.upload_file(local_path, bucket, s3_path)
    
    
if __name__ == '__main__':
    bdsr_train()
