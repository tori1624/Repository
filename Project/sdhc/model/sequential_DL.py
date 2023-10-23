######################################################
#    프로그램명    : sequential_DL.py
#    작성자        : Youngho Lee
#    작성일자      : 2023.07.10
#    파라미터      : None
#    설명          : EMR 딥러닝 모듈 - Sequential 모델 형태
######################################################

import tensorflow as tf


def create_model(unit_size=4096, dropout_rate=0.55, initial_learning_rate=0.001, 
                 decay_steps=100, decay_rate=0.5, focal_gamma=1):

    model = tf.keras.Sequential([
        tf.keras.layers.Dense(units=unit_size, kernel_regularizer=tf.keras.regularizers.l1(0.0001)),
        tf.keras.layers.BatchNormalization(),
        tf.keras.layers.Dropout(dropout_rate),
        tf.keras.layers.PReLU(),

        tf.keras.layers.Dense(units=unit_size, kernel_regularizer=tf.keras.regularizers.l1(0.0001)),
        tf.keras.layers.BatchNormalization(),
        tf.keras.layers.Dropout(dropout_rate),
        tf.keras.layers.PReLU(),

        tf.keras.layers.Dense(units=unit_size, kernel_regularizer=tf.keras.regularizers.l1(0.0001)),
        tf.keras.layers.BatchNormalization(),
        tf.keras.layers.Dropout(dropout_rate),
        tf.keras.layers.PReLU(),

        tf.keras.layers.Dense(units=unit_size, kernel_regularizer=tf.keras.regularizers.l1(0.0001)),
        tf.keras.layers.BatchNormalization(),
        tf.keras.layers.Dropout(dropout_rate),
        tf.keras.layers.PReLU(),

        tf.keras.layers.Dense(units=unit_size, kernel_regularizer=tf.keras.regularizers.l1(0.0001)),
        tf.keras.layers.BatchNormalization(),
        tf.keras.layers.Dropout(dropout_rate),
        tf.keras.layers.PReLU(),

        tf.keras.layers.Dense(units=1, activation='sigmoid', kernel_regularizer=tf.keras.regularizers.l1(0.0001))
    ])

    lr_schedule = tf.keras.optimizers.schedules.ExponentialDecay(initial_learning_rate, decay_steps=decay_steps, 
                                                                 decay_rate=decay_rate, staircase=False)

    METRICS = [
        tf.keras.metrics.BinaryAccuracy(name='accuracy'),
        tf.keras.metrics.Precision(name='precision'),
        tf.keras.metrics.Recall(name='recall')
        ]

    model.compile(optimizer=tf.keras.optimizers.Adam(learning_rate=lr_schedule),
                  loss=tf.keras.losses.BinaryFocalCrossentropy(gamma=focal_gamma),
                  metrics=METRICS)

    return model
