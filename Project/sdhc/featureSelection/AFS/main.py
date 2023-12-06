# https://github.com/upup123/AAAI-2019-AFS

import tensorflow.compat.v1 as tf
tf.disable_v2_behavior()

import os
import numpy as np
from sklearn.preprocessing import MinMaxScaler

import model
from utils import BatchCreate
from read_to_csv import read_csv, to_csv

# gpu
device = 'GPU'
tf.config.experimental.list_physical_devices(device)

if device == 'GPU':
    gpus = tf.config.experimental.list_physical_devices('GPU')
    tf.config.experimental.set_visible_devices(devices=gpus[0], device_type='GPU')
    tf.config.experimental.set_virtual_device_configuration(gpus[0],
        [tf.config.experimental.VirtualDeviceConfiguration(memory_limit=4*1024)])
else:
    os.environ['CUDA_VISIBLE_DEVICES'] = '-1'

# parameter
input_size = 889
output_size = 1
E_node = 128 # 32
A_node = 32
AO_node = 2
set_seed = 42
L_node = 500
moving_average_decay = 0.99

regularization_rate = 0.0001
learning_rate_base = 0.01
learning_rate_decay = 0.99
batch_size = 1024
train_step = 2000


def run_train(sess, train_X, train_Y, val_X, val_Y):
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


def run_test(A, train_X, train_Y, test_X, test_Y, total_batch):

    attention_weight = A.mean(0)
    AFS_weight_rank = list(np.argsort(attention_weight))[::-1]
    ac_score_list = []
    index = 1
    for K in range(5, 300, 10):
        use_train_x = train_X[:, AFS_weight_rank[:K]]
        use_test_x = test_X[:, AFS_weight_rank[:K]]
        accuracy = model.test(K, use_train_x, train_Y, use_test_x, test_Y, total_batch, index)
        index += 1
        print('Using Top {} features| accuracy:{:.4f}'.format(K, accuracy))

        ac_score_list.append(accuracy)
    return ac_score_list


# dataset
rmv_clmn = ['hspt_id', 'ptnt_no', 'ckup_ywek_ix', 'ftr_bdsr_yn', 'bdsr_yn', 'bdsr_dgss_dt_cnt']

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

minmax_X = MinMaxScaler()
minmax_X.fit(train_X)
scale_train_X = minmax_X.transform(train_X)
scale_val_X = minmax_X.transform(val_X)
scale_test_X = minmax_X.transform(test_X)

# AFS
Train_size = len(train_X)
total_batch = Train_size / batch_size
model.build(total_batch)
with tf.Session() as sess:
    tf.global_variables_initializer().run()
    print('== Get feature weight by using AFS ==')
    A = run_train(sess, scale_train_X, train_Y, scale_val_X, val_Y)
# print('== The Evaluation of AFS ==')
# ac_score_list = run_test(A, scale_train_X, train_Y, scale_test_X, true, total_batch)

# rf
from sklearn.ensemble import RandomForestClassifier

attention_weight = A.mean(0)
AFS_weight_rank = list(np.argsort(attention_weight))[::-1]

afs_train_X = train_X[train_X.columns[AFS_weight_rank[0:40]]]
afs_test_X = test_X[test_X.columns[AFS_weight_rank[0:40]]]

rf_model = RandomForestClassifier()
rf_model.fit(afs_train_X, train_Y)

# evaluation
from sklearn.metrics import roc_auc_score

cut_off = 0.5
prob = rf_model.predict_proba(afs_test_X)
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
