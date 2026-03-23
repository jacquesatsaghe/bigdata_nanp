from pyspark.sql import SparkSession
from pyspark.sql.functions import col

def main():
    # Initialisation de la Session Spark
    # Note : En mode SparkSubmit, le master est généralement géré par la config Airflow
    spark = SparkSession.builder \
        .appName("Airflow-PySpark-Example") \
        .getOrCreate()

    # 1. Création de données d'exemple
    data = [(1, "Alice"), (2, "Bob"), (3, "Charlie"), (4, "David")]
    columns = ["id", "name"]
    
    df = spark.createDataFrame(data, columns)
    print("Données initiales :")
    df.show()

    # 2. Transformation simple : ajouter une colonne 'id_squared'
    df_transformed = df.withColumn("id_squared", col("id") * col("id"))

    # 3. Affichage du résultat
    print("Données transformées :")
    df_transformed.show()

    # 4. (Optionnel) Sauvegarde en CSV ou Parquet
    # df_transformed.write.mode("overwrite").csv("output_data")

    spark.stop()

if __name__ == "__main__":
    main()
