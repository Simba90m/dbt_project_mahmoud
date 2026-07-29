WITH orders AS (
    SELECT * FROM {{ ref('staging_orders') }}
),
order_items AS (
    SELECT * FROM {{ ref('staging_order_items') }}
),
products AS (
    SELECT * FROM {{ ref('staging_products') }}
),
joined AS (
    SELECT
        o.order_id,
        o.customer_id,
        p.product_name,
        p.category_name,
        oi.unit_price,
        oi.quantity,
        oi.discount,
        (oi.unit_price * oi.quantity * (1 - oi.discount)) AS revenue,
        EXTRACT(year FROM o.order_date) AS order_year,
        EXTRACT(month FROM o.order_date) AS order_month
    FROM orders o
    JOIN order_items oi USING (order_id)
    JOIN products p USING (product_id)
)
SELECT * FROM joined