-- recap /produit/an/mois
{{ config(
    materialized='table',
    format='PARQUET'
) }}

SELECT 
    code_product,
    year_at,
    month_at,
    SUM(qte) as total_units_sold,
    SUM(total) as total_revenue,
    ROUND(SUM(total) / NULLIF(SUM(qte), 0), 2) as avg_selling_price
FROM {{ ref('marts_sales') }}
GROUP BY 1, 2, 3
ORDER BY total_revenue DESC
