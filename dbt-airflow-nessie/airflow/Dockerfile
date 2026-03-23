# my Dockerfile
FROM apache/airflow:2.11.2-python3.10


USER root

# 1. Installation de git & curl
RUN apt-get update && \
    apt-get install -y --no-install-recommends git curl && \
    apt-get autoremove -yqq --purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Création du dossier et gestion des permissions pour l'utilisateur airflow
RUN mkdir -p /opt/mes_env && chown -R airflow: /opt/mes_env

USER airflow

WORKDIR /usr/app
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1


# Création de l'env virtuel et installation de dbt-trino
RUN python -m venv /opt/mes_env/.env && \
    /opt/mes_env/.env/bin/pip install --no-cache-dir "dbt-trino>=1.5.0"