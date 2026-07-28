# Northwind Sales Insights — Project Reflection

## What business problem does this dbt model solve?

Northwind Trading's analytics team had three concrete problems: raw data with inconsistent column names and types, dashboards that were slow because every analyst wrote their own long manual joins, and no shared definition of "revenue" or "profit" across the team. This project builds a layered dbt pipeline that fixes all three — data is cleaned once in staging, joined and calculated once in prep, and aggregated once in the mart. Any analyst or BI tool downstream can now query one trusted table instead of reinventing the same SQL every time.

## Which models did I build, and what does each do?

- **Staging models** (`staging_orders`, `staging_order_details`, `staging_products`, `staging_categories`): each one pulls from a single raw source table, renames columns to snake_case, casts dates and numbers to proper types, and drops columns that aren't needed downstream. This is the layer that absorbs all the messiness of the raw data so nothing later has to deal with it.
- **Prep model** (`prep_sales`): joins the cleaned staging tables together on `order_id` and `product_id`, brings in `category_name` with a `LEFT JOIN` (so orders aren't dropped if a product's category is missing), and calculates `revenue` as `unit_price * quantity * (1 - discount)`. It also extracts `order_year` and `order_month` from the order date. This is the layer where the shared, agreed-upon definition of revenue lives.
- **Mart model** (`mart_sales_performance`): aggregates `prep_sales` by year, month, and category to produce total revenue, total number of distinct orders, and average revenue per order. This is the table a BI dashboard would actually query.

## What insights can this mart provide to Northwind?

The mart makes it possible to see, at a glance, how each product category performs over time — which categories are growing or shrinking month over month, whether there's seasonality in ordering patterns, and how categories compare not just on total revenue but on order volume and average order value. A category with high total revenue but a low average revenue per order tells a different story (lots of small orders) than one with the same total revenue from fewer, larger orders — and that distinction matters for how Northwind might target promotions or restocking.

## What was my biggest learning moment in this project?

The clearest "click" moment was understanding why the layers exist at all, rather than just writing one big query with every join and calculation in it. Splitting cleaning (staging), business logic (prep), and aggregation (marts) into separate models means each one is easy to test and debug on its own, and `{{ ref() }}` lets dbt track exactly how everything depends on everything else. The other concrete lesson was thinking carefully about `JOIN` vs `LEFT JOIN` — realizing that a regular join can silently drop rows (and therefore revenue) if a related row is missing on the other side, which isn't something that shows up as an error, just as quietly wrong numbers.
