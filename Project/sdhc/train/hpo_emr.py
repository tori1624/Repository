######################################################
#    프로그램명    : hpo.py
#    작성자        : Youngho Lee
#    작성일자      : 2023.07.06
#    파라미터      : None
#    설명          : 랜덤서치, 베이지안최적화 기반 하이퍼파라미터 최적화 (Hyperparameter-Optimization)
######################################################

import os
import sys
import click
import configparser
import numpy as np

import tensorflow as tf
from bayes_opt import BayesianOptimization
from sklearn.preprocessing import MinMaxScaler
from sklearn.model_selection import RandomizedSearchCV
from sklearn.model_selection import StratifiedKFold, cross_val_score
from tensorflow.keras.wrappers.scikit_learn import KerasClassifier


# path
wd = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
del sys.path[0]
sys.path.insert(0, wd)
os.chdir(wd)

from common.logger import Logger
from model.model_DL import *
from model.sequential_DL import *


# 0. logger 생성
lg = Logger({cate})
logger = lg.make_logger('hpo')

# 파일 실행 관련 parameter
@click.command()
@click.option('--cate', type=click.Choice([{cate1}, {cate2}], case_sensitive=False))


def hpo(cate):

    logger.info(f'# start hyper-parameter optimization the model ({cate})')

    # 1. config 설정
    config = configparser.ConfigParser()
    config.read(f'./utils/config.ini')

    ## default
    device = config['DEFAULT']['DEVICE']
    my_seed = config.getint('DEFAULT', 'SEED')
    rmv_clmn = eval(config['DEFAULT']['BASE_CLMN']) + [f'ftr_{cate}_yn']

    ## file name
    filename = config[f'DATA_{cate.upper()}']['VAL']

    ## path
    data_path = config['PATH']['DATA_PATH']

    ## parameter
    pos_weight = config.getfloat(f'PARAM_{cate.upper()}', 'POS_WEIGHT')

    set_global_determinism(my_seed)

    # 2. device 설정 (GPU, CPU 사용)
    tf.config.experimental.list_physical_devices(device)

    if device == 'GPU':
        gpus = tf.config.experimental.list_physical_devices('GPU')
        tf.config.experimental.set_visible_devices(devices=gpus[0], device_type='GPU')
        tf.config.experimental.set_virtual_device_configuration(gpus[0],
            [tf.config.experimental.VirtualDeviceConfiguration(memory_limit=10*1024)])
    else:
        os.environ['CUDA_VISIBLE_DEVICES'] = '-1'


    # 3. 데이터 불러오기
    #logger.info('# import data')
    hpo_df = pd.read_csv(os.path.join(data_path, filename))
    hpo_df_X = hpo_df.drop(rmv_clmn, axis=1)
    hpo_df_Y = hpo_df[f'ftr_{cate}_yn']


    # 4. Scaler 및 Class weight 적용
    minmax_X = MinMaxScaler()
    minmax_X.fit(hpo_df_X)

    pos = len(np.where(hpo_df_Y == 1)[0])
    neg = len(np.where(hpo_df_Y == 0)[0])
    pos = pos / pos_weight
    total = pos + neg
    weight_for_0 = (1 / neg) * (total * 0.5)
    weight_for_1 = (1 / pos) * (total * 0.5)

    class_weight = {0: weight_for_0, 1: weight_for_1}


    # 5. 랜덤서치로 광범위한 범위에서 HPO 찾기
    #  1) Define the parameter grid for the random search
    params = {
        'batch_size': list(range(1000, 6000, 256)),
        'decay_rate': list(np.logspace(np.log10(0.0000001), np.log10(0.05))),
        'decay_steps': list(range(100, 1001)),
        'initial_learning_rate': list(np.logspace(np.log10(0.0001),
                                                  np.log10(0.05), base=10, num=100)),
        'unit_size': list(range(1000, 6000, 256)),
        'dropout_rate': list(np.linspace(0.3, 0.7, num=20, endpoint=True)),
        'focal_gamma': list(np.linspace(1.0, 2.0, endpoint=True)),
        #'epochs': list(range(1000, 2001))
       }

    #  2) create a KerasClassifier
    model = KerasClassifier(build_fn=create_model, verbose=0, 
                            class_weight=class_weight)

    #  3) create a RandomizedSearchCV object (n_iter:랜덤조합할 횟수, cv:교차검증시 fold개수(defaul=3), vervbos=2:하이퍼파라미터별 메시지 출력형태)
    rs = RandomizedSearchCV(estimator=model, param_distributions=params,
                            n_iter=2, cv=2, verbose=1)

    all_batch_size = []
    all_decay_rate = []
    all_decay_steps = []
    all_initial_learning_rate = []
    all_unit_size = []
    all_dropout_rate = []

    #  4) 랜덤서치 50번 반복
    for i in range(1, 51):
        print('['+str(i)+'번째 랜덤서치]')

        # Run the optimization
        rs.fit(hpo_df_X, hpo_df_Y)

        # print the best score and parameters
        print(rs.best_params_)

        batch_size = rs.best_params_['batch_size']
        decay_rate = rs.best_params_['decay_rate']
        decay_steps = rs.best_params_['decay_steps']
        initial_learning_rate = rs.best_params_['initial_learning_rate']
        unit_size = rs.best_params_['unit_size']
        dropout_rate = rs.best_params_['dropout_rate']

        all_batch_size.append(batch_size)
        all_decay_rate.append(decay_rate)
        all_decay_steps.append(decay_steps)
        all_initial_learning_rate.append(initial_learning_rate)
        all_unit_size.append(unit_size)
        all_dropout_rate.append(dropout_rate)

    all_list = [all_batch_size, all_decay_rate, all_decay_steps, all_initial_learning_rate,
                all_unit_size, all_dropout_rate]

    #  5) 랜덤서치로 찾은 각 HP의 MIN,MAX 값 리스트로 저장
    all_min = list(map(min, all_list))
    all_max = list(map(max, all_list))


    # 6. 베이지안최적화
    #  1) Define the search space for Bayesian Optimization, 랜덤서치에서 찾은 min, max값을 베이지안최적화의 search space로 설정
    params = {
        'batch_size': (all_min[0], all_max[0]),
        'decay_rate': (all_min[1], all_max[1]),
        'decay_steps': (all_min[2], all_max[2]),
        'initial_learning_rate': (all_min[3], all_max[3]),
        'unit_size': (all_min[4], all_max[4]),
        'dropout_rate': (all_min[5], all_max[5]),
        'focal_gamma': (1.0, 2.0),
        # 'epochs': (1000, 2000),
       }

    #  2) Define the function for Bayesian Optimization
    def optimize_model(**params):
        nn = KerasClassifier(build_fn=create_model, verbose=0, 
                             class_weight=class_weight)
        kfold = StratifiedKFold(n_splits=2, shuffle=True)
        score = cross_val_score(nn, hpo_df_X, hpo_df_Y, scoring='accuracy', cv=kfold).mean()
        return score

    #  3) Create the Bayesian OptimizatiSon object
    bo = BayesianOptimization(f=optimize_model, pbounds=params, random_state=42)

    #  4) Run the optimization
    bo.maximize(init_points=10, n_iter=15)
    bo.max
    
    #  5) HPO 결과 확인
    print('BO_PARAMS :', params)
    print('BO :', bo.max)

    #  6) 각 변수에 베이지안 최적값 저장
    batch_size = bo.max['params']['batch_size']
    decay_rate = bo.max['params']['decay_rate']
    decay_steps = bo.max['params']['decay_steps']
    initial_learning_rate = bo.max['params']['initial_learning_rate']
    unit_size = bo.max['params']['unit_size']
    dropout_rate = bo.max['params']['dropout_rate']
    # epochs = bo.best_params_['epochs']
    # focal_gamma = bo.best_params_['focal_gamma']


    # 7. HPO 결과값으로 config_hpo.ini 파일에 값 업데이트
    config = configparser.ConfigParser()

    #  1) config파일 업데이트시, 기존 대소문자 유지
    config.optionxform = str

    config.read(f'./utils/config_hpo.ini')

    config.set(f'HPO_PARAM_{cate.upper()}', 'BATCH_SIZE', str(int(batch_size)))
    config.set(f'HPO_PARAM_{cate.upper()}', 'DECAY_RATE', str(decay_rate))
    config.set(f'HPO_PARAM_{cate.upper()}', 'DECAY_STEPS', str(int(decay_steps)))
    config.set(f'HPO_PARAM_{cate.upper()}', 'INITIAL_LEARNING_RATE', str(initial_learning_rate))
    config.set(f'HPO_PARAM_{cate.upper()}', 'UNIT_SIZE', str(int(unit_size)))
    config.set(f'HPO_PARAM_{cate.upper()}', 'DROPOUT_RATE', str(dropout_rate))
    # config.set(f'HPO_PARAM_{cate.upper()}', 'FOCAL_GAMMA', str(focal_gamma))
    # config.set(f'HPO_PARAM_{cate.upper()}', 'EPCH_NUM', str(int(epochs)))

    with open(f'./utils/config_hpo.ini', 'w') as configfile:
        config.write(configfile)


if __name__ == '__main__':
    hpo()
