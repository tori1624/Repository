import os
import numpy as np
import pandas as pd
from sklearn.preprocessing import MinMaxScaler

from read_to_csv import read_csv, to_csv

# Data
rmv_clmn = ['hspt_id', 'ptnt_no', 'ckup_ywek_ix', 'ftr_bdsr_yn', 
            'bdsr_yn', 'bdsr_dgss_dt_cnt', 'asmt_i05_d_vl', 'asmt_i03_vl']

data_path = '/home/yhlee/test/data'
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

# Scaler
minmax_X = MinMaxScaler()
minmax_X.fit(train_X)
scale_train_X = minmax_X.transform(train_X)
scale_val_X = minmax_X.transform(val_X)
scale_test_X = minmax_X.transform(test_X)

# Class Weight
pos_weight = 1

pos = len(np.where(train_Y == 1)[0])
neg = len(np.where(train_Y == 0)[0])
pos = pos / pos_weight
total = pos + neg
weight_for_0 = (1 / neg) * (total * 0.5)
weight_for_1 = (1 / pos) * (total * 0.5)

class_weight = {0: weight_for_0, 1: weight_for_1}

# Logistic Regression
from sklearn.linear_model import LogisticRegression

lr_model = LogisticRegression()
lr_model.fit(scale_train_X, train_Y)

prob = lr_model.predict_proba(scale_test_X)

# Random Forest
from sklearn.ensemble import RandomForestClassifier

rf_model = RandomForestClassifier()
rf_model.fit(scale_train_X, train_Y)

prob = rf_model.predict_proba(scale_test_X)

# permutation
import eli5
from eli5.sklearn import PermutationImportance

perm = PermutationImportance(rf_model, scoring='accuracy', random_state=42).fit(scale_test_X, true)

importances = perm.feature_importances_
indices = np.argsort(importances)[::-1]
importance_df = pd.DataFrame({'vars': train_X.columns[indices], 
                              'importance': importances[indices]})

# LightGBM
import lightgbm
from lightgbm import LGBMClassifier

es = lightgbm.early_stopping(stopping_rounds=100)
lgbm_model = LGBMClassifier(objective='binary',
                            learning_rate=0.01,
                            n_estimators=1000,
                            # class_weight=class_weight,
                            random_state=42)
lgbm_model.fit(scale_train_X, train_Y, eval_set=[(scale_val_X, val_Y)],
               eval_metric='auc', callbacks=[es])

prob = lgbm_model.predict_proba(scale_test_X)

# XGB
from xgboost import XGBClassifier

model = XGBClassifier()
xgb_model = model.fit(scale_train_X, train_Y, eval_set=[(scale_val_X, val_Y)],
                      early_stopping_rounds=100, eval_metric='auc')

prob = xgb_model.predict_proba(scale_test_X)

# evaluation
from sklearn.metrics import roc_auc_score

cut_off = 0.5
prob = prob[:, 1]
pred = np.floor(prob + (1 - cut_off))

TN = np.sum(np.logical_and(pred == 0, true == 0))
FN = np.sum(np.logical_and(pred == 0, true == 1))
FP = np.sum(np.logical_and(pred == 1, true == 0))
TP = np.sum(np.logical_and(pred == 1, true == 1))

accuracy = (TN + TP) / (TN + TP + FN + FP)
precision = TP / (TP + FP)
recall = TP / (TP + FN)
f1 = 2 * (precision * recall) / (precision + recall)
auc = roc_auc_score(true, pred)
print([accuracy, precision, recall, f1, auc])
