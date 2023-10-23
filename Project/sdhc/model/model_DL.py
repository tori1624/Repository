######################################################
#    프로그램명    : model_DL.py
#    작성자        : Youngho Lee
#    작성일자      : 2023.03.27
#    파라미터      : None
#    설명          : 딥러닝 관련 모듈
######################################################

import os
import random
import numpy as np
import pandas as pd
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
from tensorflow.keras import Model
    
    
def check_clmn_order(train_sam, data_pd, preset_std):
    """
    학습 데이터의 컬럼과 일치하도록 추론 데이터의 컬럼을 정렬하는 함수
    
    <param>
    train_sam : 학습 데이터 샘플
    data_pd : 추론 데이터
    preset_std : 정규화용 min, max 데이터
    """
    
    data_pd, _ = data_pd.align(train_sam, join='right', axis=1, fill_value=0) 
    preset_std, _ = preset_std.align(train_sam, join='right', axis=1, fill_value=0)

    assert list(data_pd.columns)==list(train_sam.columns), '테스트데이터셋이 훈련데이터셋 컬럼 순서와 동일하지 않습니다.'   
    assert list(preset_std.columns)==list(data_pd.columns), '훈련데이터셋_std가 훈련데이터셋 컬럼 순서와 동일하지 않습니다.'        
    
    return data_pd, preset_std
    
    
def load_minmax_scaler(_data_pd, _preset_std):
    """
    추론 데이터에 min-max 정규화를 적용하는 함수
    
    <param>
    _data_pd : 추론 데이터
    preset_std : 정규화용 min, max 데이터
    """

    _data_pd = (_data_pd - _preset_std.loc['min', :].values) / (_preset_std.loc['max', :].values - _preset_std.loc["min", :].values) 
    _data_pd = _data_pd.fillna(0) 
    _data_pd = _data_pd.applymap(lambda x: 1 if (x > 1) else x)
    _data_pd = _data_pd.applymap(lambda x: 0 if (x < 0) else x)
    
    return  _data_pd


def figure_out_tbl_id(table_name):
    """
    타겟 테이블 id 추출 함수
    
    <param>
    table_name : 타겟 테이블 명
    """
    
    sql_for_relid = f"""select relid from PG_STAT_USER_TABLES where 1=1 and relname = '{table_name}'"""
    
    return sql_for_relid
    
    
def figure_out_clmn_order(_relid_num) :
    """
    타겟 테이블 컬럼명 및 순서 추출 함수
    
    <param>
    _relied_num : 타겟 테이블 id
    """
    
    sql_for_col_name= f"""select attname
                from (select objsubid, description from PG_DESCRIPTION where objoid = {_relid_num} ) A
                left join 
                (select attnum, attname from pg_attribute where attrelid = {_relid_num} ) B 
                on A.objsubid = B.attnum 
                where b.attnum is not null"""
    
    return sql_for_col_name


# 패키지별로 seed 고정하기 위한 함수
def set_seed(seed):
    random.seed(seed) # random
    np.random.seed(seed) # np
    os.environ["PYTHONHASHSEED"] = str(seed) # os
    tf.random.set_seed(seed) # tensorflow
    
    
def set_global_determinism(seed=42):    
    set_seed(seed=seed)   
    os.environ['TF_DETERMINISTIC_OPS'] = '1'   
    os.environ['TF_CUDNN_DETERMINISTIC'] = '1'   
    tf.config.threading.set_inter_op_parallelism_threads(1)
