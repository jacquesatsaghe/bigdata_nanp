-- project.yml
    --  name
    -- dossier des models
    -- profile (dev, prod) -> profiles.yml

-- profiles.yml
    -- section profiles
    -- parametres de connexion à vos BDs

-- models (script sql, dossier /models)

-- examples: creer une table 
-- dbt.test_schema.toto(id_product, qte)
-- source nessie.agence.sales (id_product,qte)
-- fichier: toto.sql
-- SQL

SELECT
    id_product,
    qte,
    total,
    'bonjour' as greetings
FROM    
    {{ source('agence_source', 'sales') }}