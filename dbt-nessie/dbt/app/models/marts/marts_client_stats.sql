{{ config(
    materialized='table',
    format='PARQUET'
) }}

SELECT 
    c.code as code_client,
    COUNT(s.sales_id) as number_of_orders,
    SUM(s.total) as lifetime_value,
    ROUND(AVG(s.total), 2) as average_order_value,
    MAX(s.updated_at) as last_purchase_date
FROM {{ ref('marts_sales') }} s
JOIN {{ ref('fact_client') }} c ON s.id_client = c.id
GROUP BY 1
HAVING SUM(s.total) > 0
ORDER BY lifetime_value DESC
