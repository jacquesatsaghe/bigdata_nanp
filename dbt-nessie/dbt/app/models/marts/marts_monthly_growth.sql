-- évolution du business mois par mois.
{{ config(
    materialized='table',
    format='PARQUET'
) }}

WITH monthly_sales AS (
    SELECT 
        year_at,
        month_at,
        SUM(total) as revenue
    FROM {{ ref('marts_sales') }}
    GROUP BY 1, 2
)

SELECT 
    year_at,
    month_at,
    revenue,
    -- Calcule la différence avec le mois précédent via une fenêtre Trino
    LAG(revenue) OVER (ORDER BY year_at, month_at) as previous_month_revenue,
    ROUND(((revenue - LAG(revenue) OVER (ORDER BY year_at, month_at)) 
        / NULLIF(LAG(revenue) OVER (ORDER BY year_at, month_at), 0)) * 100, 2) as growth_percentage
FROM monthly_sales
