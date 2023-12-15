######################################################
#    프로그램명    : afs_utils.py
#    작성자        : Youngho Lee
#    작성일자      : 2023.12.15
#    파라미터      : None
#    설명          : AFS 모델 관련 utils
#    참고          : https://github.com/upup123/AAAI-2019-AFS
######################################################

import numpy as np


class BatchCreate(object):
    def __init__(self, images, labels):
        self._images = images
        self._labels = labels
        self._epochs_completed = 0
        self._index_in_epoch = 0
        self._num_examples = images.shape[0]

    def next_batch(self, batch_size, fake_data=False, shuffle=True):
        start = self._index_in_epoch
        '''
        Disruption in the first epoch
        '''
        if self._epochs_completed == 0 and start == 0 and shuffle:
            perm0 = np.arange(self._num_examples)
            np.random.shuffle(perm0)
            self._images = self._images[perm0]
            self._labels = self._labels[perm0]

        if start+batch_size > self._num_examples:
            # finished epoch
            self._epochs_completed += 1
            '''
            When the remaining sample number of an epoch is less than batch size,
            the difference between them is calculated.
            '''
            rest_num_examples = self._num_examples-start
            images_rest_part = self._images[start:self._num_examples]
            labels_rest_part = self._labels[start:self._num_examples]

            '''Disrupt the data'''
            if shuffle:
                perm = np.arange(self._num_examples)
                np.random.shuffle(perm)
                self._images = self._images[perm]
                self._labels = self._labels[perm]

            '''next epoch'''
            start = 0
            self._index_in_epoch = batch_size - rest_num_examples
            end = self._index_in_epoch
            images_new_part = self._images[start:end]
            labels_new_part = self._labels[start:end]
            return np.concatenate((images_rest_part, images_new_part), axis=0), np.concatenate((labels_rest_part, labels_new_part), axis=0)
        else:
            self._index_in_epoch += batch_size
            end = self._index_in_epoch
            return self._images[start:end], self._labels[start:end]
