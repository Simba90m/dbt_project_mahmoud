WITH source_data AS (
    SELECT * FROM {{ source('shop_smart', 'products') }}
)
SELECT
    product_id,
    product_name,
    category AS category_name,
    unit_price::NUMERIC AS unit_price
FROM source_data