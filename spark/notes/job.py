from pyspark.sql import SparkSession
import sys

## HOW to SUBMIT this code:
# 1. connect to jupyter-pyspark (choose one, as root or as user jovyan):
# docker exec -it jupyter-pyspark bash
# docker exec -it --user jovyan jupyter-pyspark bash -l
# 2. run this command:
# spark-submit --packages org.apache.hadoop:hadoop-aws:3.3.4,com.amazonaws:aws-java-sdk-bundle:1.12.262 /notes/job.py

def main():
    # Configuration alignée sur votre fichier YAML (Master: 7077, MinIO: admin/password123)
    # 1 core / executors
    # 800 MB RAM / executors
    spark = SparkSession.builder \
        .master("spark://spark-master:7077") \
        .appName("Minio-SQL-Processing") \
        .config("spark.jars.packages", "org.apache.hadoop:hadoop-aws:3.3.4,com.amazonaws:aws-java-sdk-bundle:1.12.262") \
        .config("spark.hadoop.fs.s3a.endpoint", "http://minio:9000") \
        .config("spark.hadoop.fs.s3a.access.key", "admin") \
        .config("spark.hadoop.fs.s3a.secret.key", "password123") \
        .config("spark.hadoop.fs.s3a.path.style.access", "true") \
        .config("spark.hadoop.fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem") \
        .config("spark.executor.memory", "800m") \
        .config("spark.executor.cores", "1") \
        .config("spark.sql.shuffle.partitions", "2") \
        .config("spark.sql.parquet.filterPushdown", "true") \
        .config("spark.sql.execution.arrow.pyspark.enabled", "true") \
        .getOrCreate()

    # Log pour vérifier que la session est active
    print("--- Session Spark démarrée avec succès ---")

    try:
        
        # Le chemin s3a:// est résolu grâce aux confs de spark-submit
        file_client = "s3a://raw-bucket/client/client_20260311184923.parquet"
        print(f"--- Lecture : {file_client} ---")
        
        # 1. Charger les données (assurez-vous d'avoir créé le bucket dans MinIO)
        df_one_client = spark.read.parquet(file_client)
        df_one_client.show(5)        

        ## 2. Écriture du résultat (Optionnel)
        ## !!!! WRITE REULT IN S3
        #output_path = ""
        #df_one_client.write.mode("overwrite").parquet(output_path)
        #print(f"--- Succès ! Résultat écrit dans : {output_path} ---")

    except Exception as e:
        print(f"!!! Erreur pendant le job : {e}")
        sys.exit(1)

    finally:
        spark.stop()
        print("--- Session Spark arrêtée ---")

if __name__ == "__main__":
    main()
