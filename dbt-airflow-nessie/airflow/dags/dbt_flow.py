from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime, timedelta

# Chemin vers l'exécutable dbt dans l'env virtuel
DBT_BIN = "/opt/mes_env/.env/bin/dbt"

default_args = {
    'owner': 'M2_team',
    'depends_on_past': False,
    'start_date': datetime(2026, 1, 1),
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    'dbt_trino_pipeline',
    default_args=default_args,
    schedule_interval='*/5 * * * *', # Exécution toutes 5 minutes
    catchup=False
) as dag:

    # 1. On lance les tables de faits (Client, Product, Sales)
    run_base_models = BashOperator(
        task_id='dbt_run_base',
        bash_command=f"cd /usr/app && {DBT_BIN} run --select facts"
    )

    # 2. On lance les KPI (qui dépendent des bases)
    run_marts_models = BashOperator(
        task_id='dbt_run_marts',
        bash_command=f"cd /usr/app && {DBT_BIN} run --select marts"
    )
    
    # 3. On lance les Seg or rfm (qui dépendent des bases)
    run_segs_models = BashOperator(
        task_id='dbt_run_segs',
        bash_command=f"cd /usr/app && {DBT_BIN} run --select segment"
    )
    
    # 4. Nettoyage
    run_clean = BashOperator(
        task_id='dbt_clean',
        bash_command=f"cd /usr/app && {DBT_BIN} clean"
    )

    # 5. Tests de qualité de données
    run_tests = BashOperator(
        task_id='dbt_test',
        bash_command=f"cd /usr/app && {DBT_BIN} test"
    )
    
    

    run_base_models >> [run_marts_models,run_segs_models] >> run_clean >> run_tests
