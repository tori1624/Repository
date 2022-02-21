# 패키지
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import tensorflow as tf
import pickle

from IPython.core.interactiveshell import InteractiveShell
InteractiveShell.ast_node_interactivity = "all"

## 1. 데이터 불러오기 및 확인
htd_gagu = pd.read_csv('../2010/seoulM_gagu.csv')
htd_gagu.head() # 226,563

htd_ind = pd.read_csv('../2010/seoulM_ind.csv')
htd_ind.head() # 661,779

htd_travel = pd.read_csv('../2010/seoulM_travel.csv')
htd_travel.head() # 1,390,178

## 2. 데이터 전처리
## 1) 데이터 병합
# sheet code의 데이터 타입 : int32
print(htd_gagu.sheet_code.dtypes, htd_ind.sheet_code.dtypes, htd_travel.sheet_code.dtypes)

# sheet_code 앞에 '0'을 붙이기 위해 sheet_code를 문자형으로 변환(ex :'01'이 서울을 나타냄)
htd_gagu['sheet_code'] = htd_gagu.sheet_code.astype('str')
htd_ind['sheet_code'] = htd_ind.sheet_code.astype('str')
htd_travel['sheet_code'] = htd_travel.sheet_code.astype('str')

# 문자형으로 바뀌었는지 확인하기 위해 데이터 타입 확인
print(htd_gagu.sheet_code.dtypes, htd_ind.sheet_code.dtypes, htd_travel.sheet_code.dtypes)

# sheet_code 앞에 '0' 붙이기
htd_gagu['sheet_code'] = '0' + htd_gagu['sheet_code']
htd_ind['sheet_code'] = '0' + htd_ind['sheet_code']
htd_travel['sheet_code'] = '0' + htd_travel['sheet_code']

# 개인 데이터와 가구 데이터 병합
htd_ig = pd.merge(htd_ind, htd_gagu, on='sheet_code', how='left')

# 개인, 가구 데이터와 통행 데이터를 병합하기 위해 새로운 조인 키 생성
htd_ig['seq'] = htd_ig.seq.astype('str')
htd_travel['seq'] = htd_travel.seq.astype('str')

htd_ig['Nsheet_code'] = htd_ig['sheet_code'] + '_' + htd_ig['seq']
htd_travel['Nsheet_code'] = htd_travel['sheet_code'] + '_' + htd_travel['seq']

# 개인, 가구 데이터와 통행 데이터를 병합
htd = pd.merge(htd_travel, htd_ig, on='Nsheet_code', how='left')

# Feature selection
htd = htd[['Nsheet_code', 'busstop_time', 'subway_time', 'home_memno', 'home_type',
           'home_jumyou', 'home_income', 'car_yesno', 'birth_year', 'sex', 'drive_license',
           'job_type', 'th_yesno', 'start_type', 'start_zcode', 'start_time', 'tr_mokjek',
           'end_type', 'end_zcode', 'tr_sudan', 'end_time']]
htd.head()

## 2) 서울에서 발생한 통행만 추출
htd['start_si'] = htd.start_zcode.str.slice(stop=2)# 출발동 코드 : 서울
htd['end_si'] = htd.end_zcode.str.slice(stop=2) # 도착동 코드 : 서울

# 서울 to 서울
len(htd[(htd["start_si"] == '01') & (htd["end_si"] == '01')])
htd_seoul = htd[(htd.start_si == '01') & (htd.end_si == '01')] # 566,296
htd_seoul = htd_seoul.drop(['start_si', 'end_si'], 1) # drop the start_si and end_si

## 3) 통행 소요시간
htd_time = htd_seoul

htd_time['start_time'] = htd_time.start_time.astype('str') # hhmm
htd_time['end_time'] = htd_time.end_time.astype('str')

htd_time.loc[htd_time.start_time.str.len() == 3, 'start_time'] = '0' + htd_time.loc[htd_seoul.start_time.str.len() == 3, 'start_time']
htd_time.loc[htd_time.start_time.str.len() == 2, 'start_time'] = '00' + htd_time.loc[htd_seoul.start_time.str.len() == 2, 'start_time']
htd_time.loc[htd_time.start_time.str.len() == 1, 'start_time'] = '000' + htd_time.loc[htd_seoul.start_time.str.len() == 1, 'start_time']
htd_time.loc[htd_time.end_time.str.len() == 3, 'end_time'] = '0' + htd_time.loc[htd_seoul.end_time.str.len() == 3, 'end_time']
htd_time.loc[htd_time.end_time.str.len() == 2, 'end_time'] = '00' + htd_time.loc[htd_seoul.end_time.str.len() == 2, 'end_time']
htd_time.loc[htd_time.end_time.str.len() == 1, 'end_time'] = '000' + htd_time.loc[htd_seoul.end_time.str.len() == 1, 'end_time']

# start time
htd_time['start_hour'] = htd_time.start_time.str.slice(stop=2).astype('int64')
htd_time['start_min'] = htd_time.start_time.str.slice(start=2, stop=4).astype('int64')

# end time
htd_time['end_hour'] = htd_time.end_time.str.slice(stop=2).astype('int64')
htd_time['end_min'] = htd_time.end_time.str.slice(start=2, stop=4).astype('int64')

# calculate spent time
htd_time['startTime'] = htd_time.start_hour * 60 + htd_time.start_min
htd_time['endTime'] = htd_time.end_hour * 60 + htd_time.end_min

htd_time['spent_time'] = htd_time.endTime - htd_time.startTime
htd_time['spent_time'].head()
htd_time = htd_time.drop(['start_time', 'end_time', 'start_hour', 'start_min', 'end_hour', 'end_min',
                          'startTime', 'endTime'], 1)

## 4) 통행 거리
# 존 코드에 행정도 코드 조인
# region code import
region_code = pd.read_csv("../region_code.csv")

# make fid code()
region_code['rcode'] = region_code.rcode.astype('str')
region_code = region_code[['zcode', 'rcode']] # select only zcode & rcode

region_code['fid_code'] = pd.Series(np.arange(424), dtype='i8')

# import distance matrix
distance_mat = pd.read_csv("../distance_mat.csv")

# merge htd_dis + region_code
htd_dis = htd_time

htd_dis = pd.merge(htd_dis, region_code,
                   left_on='start_zcode', # htd_dis['start_zcode']
                   right_on='zcode',      # region_code['zcode']
                   how='left')
htd_dis = pd.merge(htd_dis, region_code,
                   left_on='end_zcode',   # htd_dis['start_zcode']
                   right_on='zcode',      # region_code['zcode']
                   how='left')

# merge description
distance = []
se_count = len(htd[(htd["start_si"] == '01') & (htd["end_si"] == '01')])  # 서울내 이동에 한한 교통 건수
for i in range(0, se_count):
    d = distance_mat.iloc[htd_dis.fid_code_x[i], htd_dis.fid_code_y[i]]
    distance.append(d)

htd_dis['distance'] = pd.Series(distance)

htd_dis = htd_dis.drop(['zcode_x', 'fid_code_x', 'zcode_y', 'fid_code_y'], 1)

## 5) 종속변수 범주화
# 종속변수 범주화
htd_dep = htd_dis
htd_dep = htd_dep[htd_dep.tr_sudan < 18] # 566,221

htd_dep['travel_mode'] = htd_dep.tr_sudan

htd_dep.loc[htd_dep.tr_sudan == 1, 'travel_mode'] = 'walk'
htd_dep.loc[(htd_dep.tr_sudan >= 4) &  (htd_dep.tr_sudan <= 12), 'travel_mode'] = 'public'
htd_dep.loc[(htd_dep.tr_sudan == 2) | (htd_dep.tr_sudan == 3) | (htd_dep.tr_sudan >= 13), 'travel_mode'] = 'private'

htd_dep = htd_dep.drop(['Nsheet_code', 'th_yesno', 'start_type', 'start_zcode', 'end_zcode', 'tr_sudan'], 1)

## 6) 결측치 처리
htd_dep = htd_dep[htd_dep.home_income != ' '] # 564,088

## 7) 다중공선성
from patsy import dmatrices
import statsmodels.api as sm
from statsmodels.stats.outliers_influence import variance_inflation_factor

htd_dep['home_income'] = htd_dep['home_income'].astype('int64') # as numeric

features = 'busstop_time+subway_time+home_memno+home_type+home_jumyou+home_income+car_yesno+birth_year+sex+drive_license+job_type+tr_mokjek+end_type+spent_time+distance'

y, x = dmatrices('travel_mode ~' + features, htd_dep, return_type='dataframe')

vif = pd.DataFrame()
vif["VIF Factor"] = [variance_inflation_factor(x.values, i) for i in range(x.shape[1])]
vif["features"] = x.columns

## 8) 데이터 유형 변환
htd_final = htd_dep

htd_final['home_type'] = htd_final['home_type'].astype('category')
htd_final['home_jumyou'] = htd_final['home_jumyou'].astype('category')
htd_final['home_income'] = htd_final['home_income'].astype('category')
htd_final['car_yesno'] = htd_final['car_yesno'].astype('category')
htd_final['sex'] = htd_final['sex'].astype('category')
htd_final['drive_license'] = htd_final['drive_license'].astype('category')
htd_final['job_type'] = htd_final['job_type'].astype('category')
htd_final['tr_mokjek'] = htd_final['tr_mokjek'].astype('category')
htd_final['end_type'] = htd_final['end_type'].astype('category')
htd_final['travel_mode'] = htd_final['travel_mode'].astype('category')

htd_final = htd_final.drop(['rcode_x', 'rcode_y'], 1)

## 3. PCA for Data Visualization
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler
%matplotlib inline

htd_final.drop(['busstop_time','home_memno','home_type' ,'home_jumyou', 'birth_year'], axis=1, inplace=True)

# X,Y copy
htd_onehot = htd_final.loc[:,htd_final.columns != 'travel_mode'].copy()
htd_onehot_target = htd_final.loc[:,htd_final.columns == 'travel_mode'].copy()

# StanardScaler
htd_onehot_scale = StandardScaler().fit_transform(htd_onehot)

# PCA Projection to 2D
# PCA projection
pca = PCA(n_components=2) # define the dimension
principalComponents = pca.fit_transform(htd_onehot_scale)

principalDf = pd.DataFrame(data=principalComponents, columns=['principal component 1', 'principal component 2'])

finalDf = pd.concat([principalDf, htd_onehot_target['travel_mode']], axis=1)

# Visualize 2D projection
# 2D
fig = plt.figure(figsize=(8,8))
ax = fig.add_subplot(1,1,1)
ax.set_xlabel('Principal Component 1', fontsize=15)
ax.set_ylabel('Principal Component 2', fontsize=15)
ax.set_title('2 Component PCA', fontsize=20)


targets = ['public', 'walk', 'private']
colors = ['r', 'g', 'b']
for target, color in zip(targets,colors):
    indicesToKeep = finalDf['travel_mode'] == target
    ax.scatter(finalDf.loc[indicesToKeep, 'principal component 1'],
               finalDf.loc[indicesToKeep, 'principal component 2'],
               c=color, s=5, alpha=0.1)
ax.legend(targets)
ax.grid()

# 3D PCA VIS
# 3d
# PCA projection
pca = PCA(n_components=3) # define the dimension
principalComponents = pca.fit_transform(htd_onehot_scale)

principalDf = pd.DataFrame(data=principalComponents,
                           columns=['principal component 1', 'principal component 2', 'principal component 3'])

# Visualize 3D projection
from mpl_toolkits.mplot3d import Axes3D  # noqa: F401 unused import

fig = plt.figure(figsize = (8,8))
ax = fig.add_subplot(1,1,1, projection = '3d')
ax.set_xlabel('Principal Component 1', fontsize = 15)
ax.set_ylabel('Principal Component 2', fontsize = 15)
ax.set_zlabel('Principal Component 3', fontsize = 15)
ax.set_title('3 Component PCA', fontsize = 20)


targets = ['public', 'walk', 'private']
colors = ['r', 'g', 'b']
for target, color in zip(targets,colors):
    indicesToKeep = finalDf['travel_mode'] == target
    ax.scatter(finalDf.loc[indicesToKeep, 'principal component 1'],
               finalDf.loc[indicesToKeep, 'principal component 2'],
               finalDf.loc[indicesToKeep, 'principal component 3'],
               c=color, s=5, alpha=0.1)
ax.legend(targets)
ax.grid()

## 4. 모델 구축
## 1) without PCA
# X,Y copy
htd_onehot = htd_final.loc[:,htd_final.columns != 'travel_mode'].copy()
htd_onehot_target = htd_final.loc[:,htd_final.columns == 'travel_mode'].copy()

htd_onehot = htd_onehot.values

# category column 지정
label_column = [1,2,3,4,5,6,7] # Series 형태로 넣어줘야하므로 iloc 방식으로 특정 컬럼만 지정

# label encoding
# onehot encoding은 숫자형태만 input으로 받기에 명목변수를 숫자화 해줌
from sklearn import preprocessing
for column_index in label_column:
    le = preprocessing.LabelEncoder()
    htd_onehot[:,column_index] = le.fit_transform(htd_onehot[:,column_index])
    del le

# onehot encoding
from sklearn.preprocessing import OneHotEncoder
ohe = OneHotEncoder(categorical_features = [label_column])
X_data = ohe.fit_transform(htd_onehot)

# X
X_data = X_data.toarray()

# Y
lb = preprocessing.LabelBinarizer()
Y = lb.fit_transform(htd_onehot_target.travel_mode)

# Split train test
from sklearn.model_selection import train_test_split
X_train, X_test, y_train, y_test = train_test_split(X_data, Y, test_size=0.3, random_state=1)

# save data as pickle
import pickle

with open('travel.p', 'wb') as file:
    # train
    pickle.dump(X_train, file)
    pickle.dump(y_train, file)
    # test
    pickle.dump(X_test, file)
    pickle.dump(y_test, file)

## 5. 모델 재현하기
# load pickle data
with open('travel.p', 'rb') as file:
    X_train = pickle.load(file)
    y_train = pickle.load(file)
    X_test = pickle.load(file)

# Tensorflow neural network
# Parameters
learning_rate = 0.3
training_epochs = 3
batch_size = 100

# Neural Network Parameters
n_hidden_1 = 128 # 1st layer number of neurons
n_hidden_2 = 256 # 1st layer number of neurons
n_hidden_3 = 256 # 3rd layer number of neurons
n_hidden_4 = 128 # 3rd layer number of neurons

n_input = X_train.shape[1] # input shape (105, 4)
n_classes = y_train.shape[1] # classes to predict

# Inputs
X = tf.placeholder("float", shape=[None, n_input])
y = tf.placeholder("float", shape=[None, n_classes])


# Dictionary of Weights and Biases
weights = {
    # He initialization
    'h1': tf.Variable(initial_value = tf.random_normal(shape=[n_input, n_hidden_1],
                                    stddev = 1/np.sqrt(n_input/2))),
    'h2': tf.Variable(tf.random_normal(shape=[n_hidden_1, n_hidden_2],
                                    stddev = 1/np.sqrt(n_hidden_1/2))),
    'h3': tf.Variable(tf.random_normal(shape=[n_hidden_2, n_hidden_3],
                                    stddev = 1/np.sqrt(n_hidden_2/2))),
    'h4': tf.Variable(tf.random_normal(shape=[n_hidden_3, n_hidden_4],
                                    stddev = 1/np.sqrt(n_hidden_3/2))),

#   'h1': tf.Variable(tf.random_normal([n_input, n_hidden_1])),
#   'h2': tf.Variable(tf.random_normal([n_hidden_1, n_hidden_2])),
#   'h3': tf.Variable(tf.random_normal([n_hidden_2, n_hidden_3])),
#   'h4': tf.Variable(tf.random_normal([n_hidden_3, n_hidden_4])),
    'out': tf.Variable(tf.random_normal([n_hidden_4, n_classes]))
}

biases = {
  'b1': tf.Variable(tf.random_normal([n_hidden_1])),
  'b2': tf.Variable(tf.random_normal([n_hidden_2])),
  'b3': tf.Variable(tf.random_normal([n_hidden_3])),
  'b4': tf.Variable(tf.random_normal([n_hidden_4])),
  'out': tf.Variable(tf.random_normal([n_classes]))
}


# Forward propagation
# Model Forward Propagation step
def forward_propagation(x):
    # Hidden layer1
    layer_1 = tf.add(tf.matmul(x, weights['h1']), biases['b1'])
    layer_1 = tf.nn.relu(layer_1)

    layer_2 = tf.add(tf.matmul(layer_1, weights['h2']), biases['b2'])
    layer_2 = tf.nn.relu(layer_2)

    layer_3 = tf.add(tf.matmul(layer_2, weights['h3']), biases['b3'])
    layer_3 = tf.nn.relu(layer_3)

    layer_4 = tf.add(tf.matmul(layer_3, weights['h4']), biases['b4'])
    layer_4 = tf.nn.relu(layer_4)

    # Output fully connected layer
    out_layer = tf.matmul(layer_4, weights['out']) + biases['out']
    return out_layer


# Model Outputs
yhat = forward_propagation(X)
ypredict = tf.argmax(yhat, axis=1)

# Backward propagation
cost = tf.reduce_mean(tf.nn.softmax_cross_entropy_with_logits(labels = y,
                                                              logits = yhat)) # soft-max
# cost = tf.reduce_mean(tf.nn.sigmoid_cross_entropy_with_logits(labels = y,
#                                                               logits = yhat)) # sigmoid
# optimizer = tf.train.GradientDescentOptimizer(learning_rate)
optimizer = tf.train.AdamOptimizer(learning_rate)

train_op = optimizer.minimize(cost)

# # Train model
# # Initializing the variables

# save_file = './model_save/model.ckpt'

# init = tf.global_variables_initializer()
# saver = tf.train.Saver()

# with tf.Session() as sess:
#     sess.run(init)


#     # EPOCHS
#     for epoch in range(training_epochs):
# #         for i in range(len(X_train)): # Stochasting Gradient Descent
#         batch_count = int(X_train.shape[0]/100)
#         for i in range(batch_count):  # mini batch
#             # 배치사이즈 만큼 데이터를 읽어옴
#             batch_xs, batch_ys = X_train[i*batch_size:i*batch_size+batch_size], y_train[i*batch_size:i*batch_size+batch_size]
#             summary = sess.run(train_op, feed_dict = {X: batch_xs,
#                                                       y: batch_ys})

#         train_accuracy = np.mean(np.argmax(y_train, axis = 1) == sess.run(ypredict,
#                                                                         feed_dict = {X: X_train, y: y_train}))
#         test_accuracy  = np.mean(np.argmax(y_test, axis = 1) == sess.run(ypredict,
#                                                                        feed_dict = {X: X_test, y: y_test}))

#         print("Epoch = %d, train accuracy = %.2f%%, test accuracy = %.2f%%" % (epoch + 1, 100. * train_accuracy, 100. * test_accuracy))
#         predictions = ypredict.eval(feed_dict = {X : X_test})

#         # Save the model
#         saver.save(sess, save_file)

#     sess.close()

## 7. 모델 실행하기
save_file = './model_save/model.ckpt'
saver = tf.train.Saver()

# Launch the graph
with tf.Session() as sess:
    saver.restore(sess, save_file)

    test_accuracy = sess.run(
        ypredict,
        feed_dict={X: X_test, y: y_test})

print('Test Accuracy: {}'.format(test_accuracy))
