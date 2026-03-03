-- 1. Apache Polaris Catalog for Apache Iceberg Datastore

-- psql -h localhost -p 5432 -U dbadmin -d findept

CREATE DATABASE findept;
GRANT ALL PRIVILEGES ON DATABASE findept TO dbadmin;

-- The Polaris stack creates the schema as part of it's bootstrap/setup process, 
-- will be called polaris_schema