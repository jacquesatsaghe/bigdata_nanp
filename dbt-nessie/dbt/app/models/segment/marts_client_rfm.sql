{{ config(
    materialized='table',
    format='PARQUET'
) }}

WITH client_metrics AS (
    -- 1. Calcul des métriques de base par client
    SELECT 
        id_client,
        code_client,
        -- Récence : Nombre de jours depuis le dernier achat
        date_diff('day', CAST(MAX(updated_at) AS DATE), CURRENT_DATE) as recency_days,
        -- Fréquence : Nombre total de commandes
        COUNT(sales_id) as frequency,
        -- Montant : Chiffre d'affaires total
        SUM(total) as monetary_value
    FROM {{ ref('marts_sales') }}
    GROUP BY 1, 2
),

rfm_scores AS (
    -- 2. Attribution d'un score de 1 à 5 (NTILE) pour chaque métrique
    SELECT 
        *,
        -- Pour la récence, le score 5 est attribué au chiffre le plus bas (achat récent)
        NTILE(5) OVER (ORDER BY recency_days DESC) as r_score,
        NTILE(5) OVER (ORDER BY frequency ASC) as f_score,
        NTILE(5) OVER (ORDER BY monetary_value ASC) as m_score
    FROM client_metrics
)

SELECT 
    *,
    -- Score global concaténé (ex: 555 est un client parfait)
    (r_score * 100 + f_score * 10 + m_score) as rfm_combined,
    -- Segmentation textuelle simplifiée
    CASE 
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'CHAMPIONS'
        WHEN r_score >= 4 AND f_score >= 2 THEN 'CLIENTS FIDELES'
        WHEN r_score <= 2 AND f_score >= 3 THEN 'A RISQUE - NE PAS PERDRE'
        WHEN r_score <= 2 AND f_score <= 2 THEN 'HIBERNATION / PERDUS'
        ELSE 'AUTRES'
    END as segment
FROM rfm_scores
