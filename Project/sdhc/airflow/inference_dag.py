# Created by: Youngho Lee
# Created on: 2023.03.24
# Created for: Inference

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
        dag_id            = '2_INFERENCE',
        description       = '딥러닝 모델 추론',
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

        preprocess_1 = SSHOperator(task_id = 'new_wekl_bsc_ckup',
                             command     = f'{python_exec} {base_path}/preprocess/preprocess_inference_ods.py',
                             cmd_timeout = 600,
                             ssh_hook    = ssh_hook,
                             get_pty     = True)

        preprocess_2 = SSHOperator(task_id = 'dw_preprocess',
                             command     = f'{python_exec} {base_path}/preprocess/preprocess_inference_dw.py',
                             cmd_timeout = 600,
                             ssh_hook    = ssh_hook,
                             get_pty     = True)

        inference = SSHOperator(task_id = 'inference',
                             command     = f'{python_exec} {base_path}/inference/inference.py --cate={cate} --threshold_top=0.9 --threshold_low=0.7',
                             cmd_timeout = 900,
                             ssh_hook    = ssh_hook,
                             get_pty     = True)

        preprocess_check = SSHOperator(task_id = 'preprocess_check',
                             command     = f'{base_path}/preprocess/preprocess_check.sh inference',
                             cmd_timeout = 600,
                             ssh_hook    = ssh_hook,
                             get_pty     = True)


        start >> preprocess_1 >> preprocess_2 >> inference >> preprocess_check >> end
