-- merge: insert new records and update existing
-- delete+insert
{{ config(
    materialized='incremental',
    unique_key='id',    
    incremental_strategy='delete+insert',
    format='PARQUET',
    partitioning=['year_at', 'month_at', 'day_at', 'hour_at']
) }}


WITH base_data AS (
    SELECT
        id,
        code,
        name,
        COALESCE(actif, TRUE) as actif,
        CAST(current_timestamp AS TIMESTAMP(6)) as _ts
    FROM {{ source('agence_source', 'client') }}
)

SELECT
    *,
    -- Extraction des composants temporels
    year(_ts)  as year_at,
    month(_ts) as month_at,
    day(_ts)   as day_at,
    hour(_ts)  as hour_at,
    minute(_ts) as min_at,
    
    -- Vos colonnes précédentes
    _ts as updated_at,
    format_datetime(_ts, 'yyyy-MM-dd HH:mm:ss') as updated_at_str
FROM base_data

{% if is_incremental() %}
  -- Optionnel : si vous voulez limiter la lecture source (date ou id: unique_key)
  -- WHERE source_date > (SELECT max(updated_at) FROM {{ this }})
  -- WHERE id > (SELECT max(id) FROM {{ this }})
{% endif %}


