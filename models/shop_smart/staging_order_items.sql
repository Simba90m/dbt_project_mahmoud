WITH source_data AS (
    SELECT * FROM {{ source('shop_smart', 'order_items') }}
)
SELECT
    order_item_id,
    order_id,
    product_id,
    quantity::INT AS quantity,
    unit_price::NUMERIC AS unit_price,
    discount::NUMERIC AS discount
FROM source_data