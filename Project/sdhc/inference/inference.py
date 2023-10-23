######################################################
#    프로그램명    : inference.py
#    작성자        : Youngho Lee
#    작성일자      : 2023.07.25
#    설명          : 추론 과정 진행 (MLflow 적용)
######################################################

import os
import sys
import shap
import click
import boto3
import datetime
import configparser
import numpy as np
import pandas as pd
import tensorflow as tf
from sqlalchemy import create_engine

import mlflow
import mlflow.tensorflow
import mlflow.keras
from mlflow import MlflowClient

# path
wd = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
del sys.path[0]
sys.path.insert(0, wd)
os.chdir(wd)

from common.logger import Logger
from model.model_DL import *
from preprocess.set_column import *
from preprocess.preprocessor import *

# date
now = datetime.datetime.now()


# 0. logger 생성
lg = Logger({cate})
logger = lg.make_logger('inference')


# 파일 실행 관련 parameter
@click.command()
@click.option('--cate', type=click.Choice([{cate1}, {cate2}], case_sensitive=False))
@click.option('--threshold_top', default=0.7, show_default=True)
@click.option('--threshold_low', default=0.4, show_default=True)
@click.option('--batch_size', default=1024, show_default=True')


def inference_mlflow(cate, threshold_top, threshold_low, batch_size):

    if isinstance(threshold_top, str):
        threshold_top = float(threshold_top)
    if isinstance(threshold_low, str):
        threshold_low = float(threshold_low)
    if isinstance(batch_size, str):
        batch_size = int(batch_size)

    # 1. DB 관련 config 설정
    config = configparser.ConfigParser()
    config.read(f'./utils/config.ini')

    ## DB 정보
    host = os.environ['DB_HOST']
    port = os.environ['DB_PORT']
    dbname = os.environ['DB_NAME']
    user = os.environ['DB_USER_NAME']
    pwd = os.environ['DB_USER_PW']
    table_name = config['DB_OPTION']['TABLE_NM']


    # 2. seed 설정
    my_seed = config['DEFAULT']['SEED']
    set_global_determinism(int(my_seed))


    # 3. 학습 모델 관련 config 설정
    std_filename = config['FILENAME']['STD']
    bg_size = config.getint('SHAP', 'BG_SIZE')
    rmv_clmn = eval(config['DEFAULT']['BASE_CLMN']) + [f'ftr_{cate}_yn']


    # 4. 경로 설정
    data_path = config['PATH']['DATA_PATH']
    base_path = config['PATH']['BASE_PATH']
    train_path = os.path.join(config['PATH']['DATA_PATH'], config[f'DATA_{cate.upper()}']['TRAIN'])
    input_path = os.path.join(config['PATH']['DATA_PATH'], config['FILENAME']['INFER_INPUT'])
    input_std_path = os.path.join(config['PATH']['SUB_PATH'], f'{cate}_{std_filename}')


    # 5. 데이터 불러오기
    logger.info('# import data')

    s3 = boto3.resource('s3',
                        aws_access_key_id=config['S3']['KEY_ID'],
                        aws_secret_access_key=config['S3']['ACCESS_KEY'])
    bucket = s3.Bucket(config['S3']['BUCKET'])

    bucket.download_file('data/inference_input.csv', os.path.join(data_path, 'inference_input.csv'))

    data_bg = pd.read_csv(train_path)  # train_X : not scaling
    data_pd = pd.read_csv(input_path)  # test_X : not scaling
    preset_std = pd.read_csv(input_std_path).set_index('index').T

    logger.info('train data shape : {}'.format(data_bg.shape))
    logger.info('inference data shape : {}'.format(data_pd.shape))


    # 6. 학습과 평가 데이터 컬럼 정렬
    data_pd, preset_std = check_clmn_order(data_bg, data_pd, preset_std)


    # 7. Scaler 적용 및 텐서 변환
    _data_bg = data_bg.drop(rmv_clmn, axis=1)
    _data_pd = data_pd.drop(rmv_clmn, axis=1)
    _data_pd = _data_pd.astype('float')
    _preset_std = preset_std.drop(rmv_clmn, axis=1)

    _data_bg = load_minmax_scaler(_data_bg, _preset_std)
    _data_pd = load_minmax_scaler(_data_pd, _preset_std)

    data_tf = tf.convert_to_tensor(_data_pd)


    # 8. 모델 로드
    logger.info('# load model')

    ## MLflow Model 적용
    mlflow_engine = create_engine(f'postgresql+psycopg2://{mlflow_username}:{mlflow_pw}@{host}:{port}/{mlflow_dbname}')

    ## production model 로드
    experiment_id = pd.read_sql(f'''select experiment_id from public.experiments
                                    where name = {cate};''',
                                mlflow_engine).values[0][0]
    run_id = pd.read_sql(f'''select run_id from public.model_versions
                             where name = {cate-prod}
                             and current_stage = 'Production';''',
                         mlflow_engine).values[0][0]

    prefix = f'mlruns/{experiment_id}/{run_id}/'
    save_path = './model/'
    model_path = f'{save_path}/mlruns/{experiment_id}/{run_id}/artifacts/model'

    for obj in bucket.objects.filter(Prefix=prefix):
        if not os.path.exists(os.path.dirname(save_path+obj.key)):
            os.makedirs(os.path.dirname(save_path+obj.key))
        bucket.download_file(obj.key, save_path+obj.key)

    model = mlflow.keras.load_model(model_path)


    # 9. 추론 진행
    logger.info('# proceed with inference')
    outputs = tf.reshape(model.predict(data_tf, batch_size=batch_size), (-1)).numpy()


    # 10. DB 적재를 위한 컬럼 정렬
    engine = create_engine(f'postgresql+psycopg2://{user}:{pwd}@{host}:{port}/{dbname}')
    table_id = pd.read_sql(figure_out_tbl_id(table_name), engine).iloc[0, 0]  # 테이블 id
    clmn_order = pd.read_sql(figure_out_clmn_order(table_id), engine).iloc[:, 0].tolist()
    clmn_order.remove('fst_rgst_dtm')
    clmn_order.remove('fnl_chg_dtm')

    for clmn in clmn_order:
        if not hasattr(_pred_result, clmn):
            _pred_result[clmn] = np.nan

    pred_result = _pred_result[clmn_order]
    pred_result = pred_result.astype({'hspt_id': str, 'prdt_dt': int}).astype({'prdt_dt': str})


    # 11. 추론 결과 DB 적재
    logger.info('# load results into a DB')

    try:
        with engine.connect() as conn:
            result = pred_result.to_sql(schema={schema}, name=table_name, 
                                        con=conn, if_exists='append', index=False)
        logger.info('# complete')
    except:
        logger.warning('# fail to load')

    return pred_result 


if __name__ == '__main__':
    inference_mlflow()
