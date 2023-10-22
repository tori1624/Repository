# Created by: Youngho Lee
# Created on: 2023.03.21
# Created for: Train

from airflow                                    import models, utils
from airflow.operators.bash_operator            import BashOperator
from airflow.operators.dummy_operator           import DummyOperator
from airflow.operators.postgres_operator        import PostgresOperator
from datetime                                   import datetime, timedelta
from airflow.operators.trigger_dagrun           import TriggerDagRunOperator
from time                                       import strftime
from airflow.providers.common.sql.operators.sql import *

from airflow.providers.ssh.operators.ssh        import SSHOperator
from airflow.providers.ssh.hooks.ssh            import SSHHook

import pendulum


ssh_hook = SSHHook(remote_host = {ip},
                      username = {name},
                      password = {pw},
                          port = {port})

local_tz = pendulum.timezone('Asia/Seoul')

default_args = {
        'owner'              : 'airflow',
        'depends_on_past'    : False,
        'start_date'         : utils.dates.days_ago(2)
        }

with models.DAG(
        dag_id            = '1_TRAIN',
        description       = '딥러닝 모델 학습',
        schedule          = None,
        catchup           = False,
        max_active_runs   = 10,
        concurrency       = 10,
        default_args      = default_args
) as dag:
        
        python_exec = 'docker exec -it {docker} python'
        base_path = {base_path}

        start  = DummyOperator(task_id = 'start')
        end    = DummyOperator(task_id = 'end')

        preprocess_1 = SSHOperator(task_id = 'preprocess_1',
                             command     = f'{python_exec} {base_path}/preprocess/preprocess_train_ods.py',
                             cmd_timeout = 600,
                             ssh_hook    = ssh_hook,
                             get_pty     = True)

        preprocess_2 = SSHOperator(task_id = 'preprocess_2',
                             command     = f'{python_exec} {base_path}/preprocess/preprocess_train_dw.py',
                             cmd_timeout = 1200,
                             ssh_hook    = ssh_hook,
                             get_pty     = True)

        train = SSHOperator(task_id = 'train',
                             command     = f'{python_exec} {base_path}/train/train.py --cate={cate}',
                             cmd_timeout = 3600,
                             ssh_hook    = ssh_hook,
                             get_pty     = True)

        preprocess_check = SSHOperator(task_id = 'preprocess_check',
                             command     = f'docker exec -it {docker} bash {base_path}/preprocess/preprocess_check.sh train',
                             cmd_timeout = 600,
                             ssh_hook    = ssh_hook,
                             get_pty     = True)


        start >> preprocess_1 >> preprocess_2 >> train >> preprocess_check >> end
