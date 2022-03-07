#!/usr/bin/env python3
# -*- coding: utf8 -*-
# 원본 소스 : 분석서버 > dart_v2.1 (by. 강창재 수석님)

import numpy as np
import pandas as pd
import pickle as pck
from keras.utils import to_categorical
from keras.models import Sequential, Model
from sklearn.model_selection import train_test_split
from keras.callbacks import EarlyStopping
from keras.optimizers import *
from keras.layers import *
from sklearn.model_selection import KFold
from sklearn.metrics import accuracy_score
from sklearn.ensemble import RandomForestClassifier
import xgboost as xgb
from sklearn.model_selection import cross_val_score

## 데이터 로드
train = pd.read_csv('./data/flcTrain.csv')

# X,Y 구분
trainX = train.loc[:, train.columns != 'FLC'].copy()
trainY = train['FLC'].copy()

## 후처리

# 100세 초과 100세로 통일
trainX.loc[trainX['HOUS_AGE']>100, 'HOUS_AGE'] = 100

# 연속형 및 순서형 변수 scaling
trainX['HOUS_AGE'] = trainX['HOUS_AGE'] / 100
trainX['HOUS_AREA'] = trainX['HOUS_AREA'] / trainX['HOUS_AREA'].max()

# 종속 변수 one-hot-encoding
trainY = to_categorical(trainY)

# 차원 축소 (Auto encoders)
ae_train_tmp, ae_test = train_test_split(trainX.loc[:, trainX.columns.isin(['HOUS_AGE', 'HOUS_AREA'])],
                                         test_size=0.15, random_state=0)
ae_train, ae_dev = train_test_split(ae_train_tmp, test_size=0.15, random_state=0)
encoding_dim = 1

encoder = Sequential()
encoder.add(Dense(encoding_dim, input_dim=ae_train.shape[1], activation='relu'))

decoder = Sequential()
decoder.add(Dense(ae_train.shape[1], activation='relu'))

ae_model = Sequential([encoder, decoder])
ae_model.compile(loss='mse', optimizer=Adam(learning_rate=0.01), metrics=['mae'])
ae_model.fit(
    ae_train, ae_train,
    batch_size=trainX.shape[0],
    epochs=1000,
    validation_data=(ae_dev, ae_dev),
    verbose=1, use_multiprocessing=False, workers=1
)

trainX['Encoded_VAR'] = encoder.predict(trainX.loc[:, trainX.columns.isin(['HOUS_AGE', 'HOUS_AREA'])])

# 더미 변수 생성
for value in [1, 2]:
    trainX['HOUS_SEX_' + str(value)] = np.where(trainX['HOUS_SEX']==value, 1, 0)
for value in [1, 2, 3, 4]:
    trainX['HOUS_REL_' + str(value)] = np.where(trainX['HOUS_REL'] == value, 1, 0)
for value in ['11', '12', '13', '20', '30', '50', '60', '99']:
    trainX['HOUS_CLSS_' + str(value)] = np.where(trainX['HOUS_CLSS'] == value, 1, 0)
for value in ['CAPITAL', 'NEAR_CAPITAL', 'METRO', 'ETC']:
    trainX['HOUS_REGION_' + str(value)] = np.where(trainX['HOUS_REGION']==value, 1, 0)

# 불필요 컬럼 제거
trainX = trainX.drop(columns=['HOUS_SEX', 'HOUS_AGE', 'HOUS_REL', 'HOUS_CLSS', 'HOUS_REGION', 'HOUS_AREA'])
trainX = trainX.values # KeyError(f"None of [{key}] are in the [{axis_name}]")

## 모델 구현(DNN)

# 학습(10k-fold cross validation)
kfold = KFold(n_splits=10, shuffle=True, random_state=0)
fold_no = 1
scores = []

for tr, val in kfold.split(trainX, trainY):
    model = Sequential()
    model.add(Dense(128, input_dim=trainX.shape[1], activation='relu'))
    model.add(Dense(128, activation='relu'))
    model.add(Dense(trainY.shape[1], activation='softmax'))
    model.compile(loss='categorical_crossentropy', optimizer=Adam(learning_rate=0.01), metrics=['accuracy'])
    model.fit(
        x=trainX[tr], y=trainY[tr],
        batch_size=trainX.shape[0],
        epochs=1000,
        callbacks=[EarlyStopping(patience=10, monitor='loss')],
        verbose=0, use_multiprocessing=False, workers=1
    )
    scores.append(model.evaluate(trainX[val], trainY[val])[1])
    fold_no += 1

# 정확도 검증
print('Accuracy : {:.2f}%'.format(np.mean(scores) * 100))

## 모델 구현(Random Forest)

# 학습(10k-fold cross validation)
model = RandomForestClassifier(random_state=0)
scores = cross_val_score(model, trainX, trainY, cv=10, scoring='accuracy')

# 정확도 검증
print('Accuracy : {:.2f}%'.format(np.mean(scores) * 100))

## 모델 구현(XGB)

# 학습(10k-fold cross validation)
trainY = train['FLC'].copy()

model = xgb.XGBClassifier(learning_rate=0.01, n_jobs=8)
scores = cross_val_score(model, trainX, trainY, cv=10, scoring='accuracy')

# 정확도 검증
print('Accuracy : {:.2f}%'.format(np.mean(scores) * 100))
