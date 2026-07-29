WITH source_data AS (
    SELECT * FROM {{ source('shop_smart', 'orders') }}
)
SELECT
    order_id,
    customer_id,
    order_date::DATE AS order_date,
    total_amount::NUMERIC AS total_amount
FROM source_data