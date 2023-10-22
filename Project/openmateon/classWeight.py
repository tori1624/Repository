#!/usr/bin/env python3
# -*- coding: utf8 -*-

import pandas as pd

from sklearn.metrics import accuracy_score

from keras.layers import *
from keras.optimizers import *
from keras.models import Sequential
from keras.utils import to_categorical
from keras.callbacks import EarlyStopping


# params
l_rate = 0.01
ep = 1000

# Deep Neural Network
train = pd.read_csv('./data/train.csv')

## 데이터셋 구축
trainX = train.loc[:, train.columns.isin(['FLC', 'HOUS_REL']) == False].copy()
trainY = train['HOUS_REL'].copy()

## 후처리
trainX.loc[trainX['HOUS_AGE']>100, 'HOUS_AGE'] = 100

# 연속형 변수 scaling
trainX['HOUS_AGE'] = trainX['HOUS_AGE'] / 100

# 더미 변수 생성
for value in [1, 2]:
    trainX['HOUS_SEX_' + str(value)] = np.where(trainX['HOUS_SEX']==value, 1, 0)
for value in [11, 12, 13, 20, 30, 50, 60, 99]:
    trainX['HOUS_CLSS_' + str(value)] = np.where(trainX['HOUS_CLSS']==value, 1, 0)
for value in ['CAPITAL', 'NEAR_CAPITAL', 'METRO', 'ETC']:
    trainX['HOUS_REGION_' + str(value)] = np.where(trainX['HOUS_REGION']==value, 1, 0)
for value in [0, 20, 40, 60, 85, 100, 130, 165, 230]:
    trainX['HOUS_AREA_' + str(value)] = np.where(trainX['HOUS_AREA']==value, 1, 0)

# 불필요 컬럼 제거
trainX = trainX.drop(columns=['HOUS_SEX', 'HOUS_CLSS', 'HOUS_REGION', 'HOUS_AREA'])

## 모델 구현_학습 (class weight)
from sklearn.utils.class_weight import compute_class_weight

class_weight_list = compute_class_weight('balanced', np.unique(trainY), trainY)
class_weight = dict(zip(np.unique(trainY), class_weight_list))

model = Sequential()
model.add(Dense(128, input_dim=trainX.shape[1], activation='relu'))
model.add(Dense(128, activation='relu'))
model.add(Dense(len(trainY.unique()), activation='softmax'))
model.compile(loss='sparse_categorical_crossentropy', optimizer=Adam(learning_rate=l_rate), metrics=['accuracy'])
model.fit(
    x=trainX, y=trainY,
    batch_size=trainX.shape[0],
    epochs=ep,
    callbacks=[EarlyStopping(patience=10, monitor='loss')],
    verbose=0, use_multiprocessing=False, workers=1,
    class_weight=class_weight
)

# 정확도 검증
tmp = train[['HOUS_REL']].copy()
tmp['REL_PREDICT'] = pd.Series(model.predict(trainX).tolist())
tmp['REL_PREDICT'] = tmp.apply(lambda x: np.argmax(x['REL_PREDICT']), axis=1)
print('Accuracy : {:.2f}%'.format(accuracy_score(tmp['HOUS_REL'], tmp['REL_PREDICT']) * 100))
