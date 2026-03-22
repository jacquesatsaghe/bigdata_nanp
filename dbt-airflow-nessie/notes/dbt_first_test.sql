-- read 'notes.txt' to understand why we use 'dbt.'
-- WITH (location = 's3://dbt-test-bucket/warehouse/test_schema/'); is where your data will reside on minio
-- create bucket 'dbt-test-bucket' before
-- Se connecte directement au catalogue iceberg nessie
-- docker exec -it trino trino --catalog nessie
-- 1. Création du schéma dans Nessie

-- CREATE SCHEMA dbt.test_schema 
-- WITH (location = 's3://dbt-test-bucket/warehouse/test_schema/');
CREATE SCHEMA dbt.test_schema;

-- 2. Création d'une table optimisée pour vos petits fichiers
CREATE TABLE dbt.test_schema.sensor_data (
    sensor_id VARCHAR,
    value DOUBLE,
    ts TIMESTAMP(3)
)
WITH (
    format = 'PARQUET',
    partitioning = ARRAY['day(ts)']
);

-- Connect and set session configs
USE dbt.test_schema;
-- Force la taille des fichiers à être plus petite pour vos tests
SET SESSION dbt.parquet_writer_block_size = '32MB';

-- 3. Insertion de test
INSERT INTO dbt.test_schema.sensor_data 
VALUES ('sensor_01', 25.5, TIMESTAMP '2026-03-12 18:00:00');

-- 4. Vérification
SELECT * FROM dbt.test_schema.sensor_data;

-- 5. croner pour optimisation
-- Fusionne les petits fichiers en fichiers plus gros (à faire périodiquement)
ALTER TABLE dbt.test_schema.sensor_data EXECUTE optimize;
-- Nettoie les anciens snapshots pour alléger MariaDB/Nessie
ALTER TABLE dbt.test_schema.sensor_data EXECUTE expire_snapshots(retention_threshold => '2d');
