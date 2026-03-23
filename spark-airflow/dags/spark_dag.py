from datetime import datetime
from airflow import DAG
from airflow.providers.apache.spark.operators.spark_submit import SparkSubmitOperator
import os

# Chemin absolu vers votre script PySpark
BASE_PATH = os.path.dirname(os.path.realpath(__file__))
SCRIPT_PATH = os.path.join(BASE_PATH, "python_script/script.py")

with DAG(
    dag_id="example_spark_local",
    start_date=datetime(2023, 1, 1),
    schedule=None,
    catchup=False,
    tags=["pyspark", "3.4.0"],
) as dag:

    submit_job = SparkSubmitOperator(
        task_id="run_pyspark_script",
        conn_id="spark-test",     # Doit correspondre au Connection Id créé
        application=SCRIPT_PATH,   # Chemin vers votre script.py
        name="pyspark_airflow_task",
        verbose=True,
        conf={
            "spark.driver.memory": "512m",
            "spark.executor.memory": "800m",
            "spark.executor.cores": "1",
            "spark.driver.maxResultSize": "256m"
        }
    )

    submit_job
