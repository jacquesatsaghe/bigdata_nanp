# my Dockerfile
FROM apache/airflow:2.11.2-python3.10

USER root

# 1. Installation de Java (JRE) - Version légère sans interface graphique
RUN apt-get update && \
    apt-get install -y --no-install-recommends openjdk-17-jre-headless && \
    apt-get autoremove -yqq --purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 2. Installation de Spark (Binaires uniquement)
ENV SPARK_VERSION=3.4.0
ENV HADOOP_VERSION=3
ENV SPARK_HOME=/opt/spark
ENV PATH="$SPARK_HOME/bin:$PATH"

RUN curl -fL "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz" | tar -xz -C /opt/ && \
    mv /opt/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} $SPARK_HOME && \
    chown -R airflow: /opt/spark
USER airflow

# 3. Installation du provider (Connecteur Airflow) sans dépendances lourdes
RUN pip install --no-cache-dir apache-airflow-providers-apache-spark==4.1.3 --no-deps
