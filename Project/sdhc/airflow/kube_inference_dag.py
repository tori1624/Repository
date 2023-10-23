#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
Created By  : Youngho Lee
Created Date: 2023-10-03
Created for: Inference
version ="2.0"
"""

import pendulum
from time import strftime
from datetime import datetime, timedelta

from airflow import utils
from airflow.models import DAG
from airflow.operators.empty import EmptyOperator
from airflow.providers.cncf.kubernetes.operators.kubernetes_pod import KubernetesPodOperator


local_tz = pendulum.timezone("Asia/Seoul")

dag_id_DAG = "INFERENCE"

environments={
    "DB_HOST": {rds ip},
    "DB_USER_NAME": {user name},
    "DB_USER_PW": {pw},
    "DB_NAME": {db name},
    "DB_PORT": {port}
}

default_args = {
    "owner": {owner},
    "depends_on_past": False,
    "start_date": utils.dates.days_ago(2)
}

with DAG(
    dag_id=dag_id_DAG,
    description="딥러닝 모델 추론",
    schedule=None,
    max_active_runs=10,
    concurrency=10,
    catchup=False,
    default_args=default_args
) as dag:
    
    # AwsEcr
    image_name = {image name}
    namespace_name = {namespace name}
    
    # SetVariable
    base_path = {base_path}
    env_file_nm = "lake.env"
    
    # Workflow
    start = EmptyOperator(task_id = "start")
    end = EmptyOperator(task_id = "end")

    preprocess_1 = KubernetesPodOperator(
        task_id = "preprocess_1",
        name = f"{dag_id_DAG}-preprocess_1",
        namespace = namespace_name,
        image = image_name,
        cmds = ["python3", "-u"],
        arguments = [f"{base_path}/preprocess/preprocess_inference_ods.py"],
        image_pull_policy = "Always",
        is_delete_operator_pod = True,
        cluster_context = "test",
        in_cluster = False,
        get_logs = False,
        startup_timeout_seconds = 300,
        execution_timeout = timedelta(minutes=10),
        env_vars=environments,
    )

    preprocess_2 = KubernetesPodOperator(
        task_id = "preprocess_2",
        name = f"{dag_id_DAG}-preprocess_2",
        namespace = namespace_name,
        image = image_name,
        cmds = ["python3", "-u"],
        arguments = [f"{base_path}/preprocess/preprocess_inference_dw.py"],
        image_pull_policy = "Always",
        is_delete_operator_pod = True,
        cluster_context = "test",
        in_cluster = False,
        get_logs = False,
        startup_timeout_seconds = 300,
        execution_timeout = timedelta(minutes=10),
        env_vars=environments,
    )

    inference = KubernetesPodOperator(
        task_id = "inference",
        name = f"{dag_id_DAG}-inference",
        namespace = namespace_name,
        image = image_name,
        cmds = ["python3", "-u"],
        arguments = [f"{base_path}/inference/inference.py", "--cate={cate}", "--threshold_top=0.9", "--threshold_low=0.7"],
        image_pull_policy = "Always",
        is_delete_operator_pod = True,
        cluster_context = "test",
        in_cluster = False,
        get_logs = False,
        startup_timeout_seconds = 300,
        execution_timeout = timedelta(minutes=120),
        env_vars=environments,
    )
    

    start >> preprocess_1 >> preprocess_2 >> inference >> end
  
