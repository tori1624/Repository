#!/usr/bin/env python3
# -*- coding: utf8 -*-

import numpy as np
import pandas as pd
from bayes_opt import BayesianOptimization

from sklearn.model_selection import KFold
from sklearn.metrics import accuracy_score
from sklearn.model_selection import cross_val_score

from keras.layers import *
from keras.optimizers import *
from keras.models import Sequential
from keras.callbacks import EarlyStopping
from keras.wrappers.scikit_learn import KerasClassifier


## 데이터 로드
train = pd.read_csv('./data/train.csv')

# X,Y 구분
trainX = train.loc[:, train.columns != 'FLC'].copy()
trainY = train['FLC'].copy()

## 후처리

# 100세 초과 100세로 통일
trainX.loc[trainX['HOUS_AGE'] > 100, 'HOUS_AGE'] = 100

# 연속형 변수 scaling
trainX['HOUS_AGE'] = trainX['HOUS_AGE'] / 100

# 더미 변수 생성
for value in [1, 2]:
    trainX['HOUS_SEX_' + str(value)] = np.where(trainX['HOUS_SEX'] == value, 1, 0)
for value in [1, 2, 3, 4]:
    trainX['HOUS_REL_' + str(value)] = np.where(trainX['HOUS_REL'] == value, 1, 0)
for value in ['11', '12', '13', '20', '30', '50', '60', '99']:
    trainX['HOUS_CLSS_' + str(value)] = np.where(trainX['HOUS_CLSS'] == value, 1, 0)
for value in ['CAPITAL', 'NEAR_CAPITAL', 'METRO', 'ETC']:
    trainX['HOUS_REGION_' + str(value)] = np.where(trainX['HOUS_REGION'] == value, 1, 0)
for value in [0, 20, 40, 60, 85, 100, 130, 165, 230]:
    trainX['HOUS_AREA_' + str(value)] = np.where(trainX['HOUS_AREA'] == value, 1, 0)

# 불필요 컬럼 제거
trainX = trainX.drop(columns=['HOUS_SEX', 'HOUS_REL', 'HOUS_CLSS', 'HOUS_REGION', 'HOUS_AREA'])

# 베이지안 최적화
def bayesOpt(neurons, learning_rate, batch_size, epochs):
    # param
    neurons = round(neurons)
    batch_size = round(batch_size)
    epochs = round(epochs)

    # model
    def nn_model():
        opt = Adam(learning_rate=learning_rate)
        model = Sequential()
        model.add(Dense(neurons, input_dim=trainX.shape[1], activation='relu'))
        model.add(Dense(neurons, activation='relu'))
        model.add(Dense(len(trainY.unique()), activation='softmax'))
        model.compile(loss='categorical_crossentropy', optimizer=opt, metrics=['accuracy'])
        return model

    es = EarlyStopping(monitor='accuracy', mode='max', verbose=0, patience=10)
    nn = KerasClassifier(build_fn=nn_model, epochs=epochs, batch_size=batch_size, verbose=0)
    kfold = KFold(n_splits=5, shuffle=True, random_state=0)
    score = cross_val_score(nn, trainX, trainY, scoring='accuracy', cv=kfold, fit_params={'callbacks': [es]}).mean()
    return score

params_nn = {
    'neurons': (64, 256),
    'learning_rate': (0.001, 1),
    'batch_size': (1, trainX.shape[0]),
    'epochs': (1, 10000)
}

nn_bo = BayesianOptimization(bayesOpt, params_nn)
nn_bo.maximize(init_points=8, n_iter=10) # init_points: 초기 Random search 횟수, n_iter: 추가 search 횟수

# 결과
result = {'neurons': nn_bo.max['params']['neurons'],
          'learning_rate': nn_bo.max['params']['learning_rate'],
          'batch_size': nn_bo.max['params']['batch_size'],
          'epochs': nn_bo.max['params']['epochs']}
