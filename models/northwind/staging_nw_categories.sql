WITH source_data AS (
    SELECT *
    FROM {{ source('northwind', 'categories') }}
)
SELECT
    category_id
    ,category_name
FROM source_data