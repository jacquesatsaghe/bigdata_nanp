-- merge: insert new records and update existing
-- delete+insert
{{ config(
    materialized='incremental',
    unique_key='sales_id',    
    incremental_strategy='delete+insert',
    format='PARQUET',
    partitioning=['year_at', 'month_at', 'day_at', 'hour_at']
) }}


WITH base_data AS (
    SELECT
        id,
        id_client,
        id_product,
        CAST(qte AS INT) as qte,
        CAST(total AS DECIMAL(18, 2)) as total,
        CAST(current_timestamp AS TIMESTAMP(6)) as _ts
    FROM {{ source('agence_source', 'sales') }}
)

SELECT
    s.id as sales_id,
    s.id_client,
    s.id_product,
    c.code as code_client,
    p.code as code_product,
    s.qte,
    p.pu,
    s.total,
    -- Extraction des composants temporels
    year(s._ts)  as year_at,
    month(s._ts) as month_at,
    day(s._ts)   as day_at,
    hour(s._ts)  as hour_at,
    minute(s._ts) as min_at,
    
    -- Vos colonnes précédentes
    s._ts as updated_at,
    format_datetime(s._ts, 'yyyy-MM-dd HH:mm:ss') as updated_at_str
FROM base_data s
JOIN {{ ref('fact_client') }} c ON s.id_client = c.id
JOIN {{ ref('fact_product') }} p ON s.id_product = p.id

{% if is_incremental() %}
  -- Optionnel : si vous voulez limiter la lecture source (date ou id: unique_key)
  -- WHERE source_date > (SELECT max(updated_at) FROM {{ this }})
  -- WHERE id > (SELECT max(id) FROM {{ this }})
{% endif %}


