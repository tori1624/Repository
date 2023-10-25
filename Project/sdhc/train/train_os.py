######################################################
#    프로그램명    : train_os.py
#    작성자        : Youngho Lee
#    작성일자      : 2023.07.11
#    파라미터      : None
#    설명          : 학습 과정 진행 (Over Sampling 적용)
######################################################

import os
import sys
import click
import configparser
import numpy as np
import pandas as pd
import tensorflow as tf
from sklearn.preprocessing import MinMaxScaler
from imblearn.over_sampling import SMOTE, ADASYN
from tensorflow.keras.wrappers.scikit_learn import KerasClassifier

import mlflow
import mlflow.tensorflow
from mlflow import MlflowClient

# path
wd = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
del sys.path[0]
sys.path.insert(0, wd)
os.chdir(wd)

from model.model_DL import *
from model.sequential_DL import *


# 파일 실행 관련 parameter
@click.command()
@click.option('--cate', type=click.Choice([{cate1}, {cate2}], case_sensitive=False))
@click.option('--run_name', type=click.STRING, default='test', show_default=True)
@click.option('--cut_off', default=0.7, show_default=True)


def train_mlflow(cate, run_name, cut_off):

    # 1. config 설정
    config = configparser.ConfigParser()
    config.read('./utils/config.ini')

    hpo_config = configparser.ConfigParser()
    hpo_config.read('./utils/config_hpo.ini')

    #  1) default
    device = config['DEFAULT']['DEVICE']
    my_seed = config.getint('DEFAULT', 'SEED')
    rmv_clmn = eval(config['DEFAULT']['BASE_CLMN']) + [f'ftr_{cate}_yn']

    #  2) file name
    std_filename = config['FILENAME']['STD']
    train_filename = config[f'DATA_{cate.upper()}']['TRAIN']
    val_filename = config[f'DATA_{cate.upper()}']['VAL']
    test_filename = config[f'DATA_{cate.upper()}']['TEST']

    #  3) path
    data_path = config['PATH']['DATA_PATH']
    std_path = config['PATH']['SUB_PATH']

    os.makedirs(std_path, exist_ok=True)

    # 4) parameter
    patience = config.getint(f'PARAM_{cate.upper()}', 'PATIENCE')
    min_delta = config.getfloat(f'PARAM_{cate.upper()}', 'MIN_DELTA')
    pos_weight = config.getfloat(f'PARAM_{cate.upper()}', 'POS_WEIGHT')

    unit_size = hpo_config.getint(f'HPO_PARAM_{cate.upper()}', 'UNIT_SIZE')
    dropout_rate = hpo_config.getfloat(f'HPO_PARAM_{cate.upper()}', 'DROPOUT_RATE')
    initial_learning_rate = hpo_config.getfloat(f'HPO_PARAM_{cate.upper()}',
                                                'INITIAL_LEARNING_RATE')
    decay_steps = hpo_config.getint(f'HPO_PARAM_{cate.upper()}', 'DECAY_STEPS')
    decay_rate = hpo_config.getfloat(f'HPO_PARAM_{cate.upper()}', 'DECAY_RATE')
    focal_gamma = hpo_config.getfloat(f'HPO_PARAM_{cate.upper()}', 'FOCAL_GAMMA')
    epochs = hpo_config.getint(f'HPO_PARAM_{cate.upper()}', 'EPCH_NUM')
    batch_size = hpo_config.getint(f'HPO_PARAM_{cate.upper()}', 'BATCH_SIZE')

    set_global_determinism(my_seed)


    # 2. device 설정
    tf.config.experimental.list_physical_devices(device)

    if device == 'GPU':
        gpus = tf.config.experimental.list_physical_devices('GPU')
        tf.config.experimental.set_visible_devices(devices=gpus[0], device_type='GPU')
        tf.config.experimental.set_virtual_device_configuration(gpus[0],
            [tf.config.experimental.VirtualDeviceConfiguration(memory_limit=4*1024)])
    else:
        os.environ['CUDA_VISIBLE_DEVICES'] = '-1'


    # 3. 데이터 로드
    train = pd.pd.read_csv(os.path.join(data_path, train_filename))
    val = pd.pd.read_csv(os.path.join(data_path, val_filename))
    test = pd.pd.read_csv(os.path.join(data_path, test_filename))

    train_X_raw = train.drop(rmv_clmn, axis=1)
    train_X_raw = train_X_raw.astype('float')
    train_Y_raw = train[f'ftr_{cate}_yn']

    ## Over Sampling 적용
    # sm = SMOTE(sampling_strategy=0.1)
    # train_X, train_Y = sm.fit_resample(train_X_raw, train_Y_raw)
    adasyn = ADASYN(sampling_strategy=0.1, random_state=42)
    train_X, train_Y = adasyn.fit_resample(train_X_raw, train_Y_raw)

    val_X = val.drop(rmv_clmn, axis=1)
    val_X = val_X.astype('float')
    val_Y = val[f'ftr_{cate}_yn']

    test_X = test.drop(rmv_clmn, axis=1)
    test_X = test_X.astype('float')
    true = test[f'ftr_{cate}_yn'].values


    # 4. Scaler 및 Class weight 적용
    #  1) Scaler
    minmax_X = MinMaxScaler()
    minmax_X.fit(train_X)
    scale_train_X = minmax_X.transform(train_X)
    scale_val_X = minmax_X.transform(val_X)
    scale_test_X = minmax_X.transform(test_X)

    std_df = pd.DataFrame({'min': minmax_X.data_min_, 'max': minmax_X.data_max_},
                          index=minmax_X.feature_names_in_).reset_index(drop=False)
    to_csv(std_df, os.path.join(std_path, f'{cate}_{std_filename}'))

    #  2) Class weight
    pos = len(np.where(train_Y == 1)[0])
    neg = len(np.where(train_Y == 0)[0])
    pos = pos / pos_weight
    total = pos + neg
    weight_for_0 = (1 / neg) * (total * 0.5)
    weight_for_1 = (1 / pos) * (total * 0.5)

    class_weight = {0: weight_for_0, 1: weight_for_1}


    # 5. 모델 생성
    create_model.__defaults__ = (unit_size, dropout_rate, initial_learning_rate,
                                 decay_steps, decay_rate, focal_gamma)

    callbacks = []

    if patience > 0:
        early_callback = tf.keras.callbacks.EarlyStopping(monitor='val_loss', 
                                                          patience=patience,
                                                          min_delta=min_delta, 
                                                          restore_best_weights=True)
        callbacks.append(early_callback)


    # 6. 모델 평가 (MLflow)
    mlflow.set_tracking_uri({mlflow_uri})
    experiment = mlflow.set_experiment(f'{cate}')

    # 모델 정보 추출
    client = MlflowClient({mlflow_uri})
    model_name = f'{cate}-prod'
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

    with mlflow.start_run(experiment_id=experiment.experiment_id):

        # 1) 모델 학습
        model = KerasClassifier(build_fn=create_model, epochs=epochs,
                                batch_size=batch_size, class_weight=class_weight,
                                verbose=2)
        model.fit(scale_train_X, train_Y, validation_data=(scale_val_X, val_Y),
                  callbacks=callbacks)

        # 2) 예측값 도출
        pred = pd.DataFrame(model.predict(scale_test_X)).iloc[:, 0].values

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
        auc = tf.keras.metrics.AUC()(true, pred)

        # 4) MLflow
        # params
        params = {
            'initial learning rate': round(initial_learning_rate, 5),
            'decay steps': decay_steps,
            'decay rate': round(decay_rate, 3),
            'patience': patience,
            'min delta': round(min_delta, 5),
            'pos weigth': round(pos_weight, 3),
            'focal gamma': round(focal_gamma, 3),
            'epoch': epochs,
            'batch size': batch_size,
            'unit size': unit_size,
            'dropout rate': round(dropout_rate, 3)
        }
        mlflow.tensorflow.mlflow.log_params(params)

        # metrics
        metrics = {
            'accuracy': round(accuracy, 3),
            'precision': round(precision, 3),
            'recall': round(recall, 3),
            'f1': round(f1, 3),
            'auc': round(auc.numpy(), 3)
        }
        mlflow.tensorflow.mlflow.log_metrics(metrics)

        # tags
        tags = {
            'mlflow.runName': run_name,
            'category': cate,
            'cut off': cut_off
        }
        mlflow.set_tags(tags)

        mlflow.tensorflow.log_model(model.model, 'model', registered_model_name=model_name)

    if (accuracy > prod_accuracy) and (precision > prod_precision) and (recall > prod_recall):
        client.transition_model_version_stage(
            name=model_name, version=latest_ver + 1, stage='Staging'
        )


if __name__ == '__main__':
    train_mlflow()
