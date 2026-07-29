# Northwind Sales Insights — Project Reflection

## What business problem does this dbt model solve?

The same three problems as the original brief: raw Northwind data spread across separate tables with inconsistent naming, analysts writing repeated manual joins to answer sales questions, and no single agreed definition of "revenue." This project builds a second, independent dbt pipeline — staging, prep, and mart — against the real `northwind` schema, so the cleaning and the revenue calculation happen once and produce one trusted table anyone can query.

## Which models did I build, and what does each do?

- **Staging models** (`staging_nw_orders`, `staging_nw_order_details`, `staging_nw_products`, `staging_nw_categories`): each pulls from one raw table in the `northwind` schema and casts dates to `DATE` and prices/quantities to numeric types. Unlike the `shop_smart` version, this schema already had a genuine `categories` table with its own `category_id`/`category_name`, so `staging_nw_categories` stayed close to the original assignment's sample solution rather than needing a workaround.
- **Prep model** (`prep_nw_sales`): joins the four staging models on `order_id`, `product_id`, and `category_id`, calculates `revenue` as `unit_price * quantity * (1 - discount)` per order line, and extracts `order_year` / `order_month` from the order date. It uses a `LEFT JOIN` to `categories` specifically because a product could in principle have a missing category match, and a plain `JOIN` would silently drop that revenue.
- **Mart model** (`mart_nw_sales_performance`): aggregates `prep_nw_sales` by year, month, and category into `total_revenue`, `total_orders`, and `avg_revenue_per_order` — the table a BI tool would query directly.

I also added a `schema.yml` with `not_null` tests on the mart's key columns, which passed cleanly against this dataset.

## What insights can this mart provide to Northwind?

The output covers July 1996 through May 1998, split across eight categories (Beverages, Condiments, Confections, Dairy Products, Grains/Cereals, Meat/Poultry, Produce, Seafood). A few patterns are visible directly in the mart: **Beverages** consistently produces some of the largest monthly revenue figures and the widest swings in `avg_revenue_per_order` (e.g. January 1997 averaged over €2,190 per order versus roughly €237 the following month) — driven by a handful of high-unit-price items like Côte de Blaye at ~€210–263 a bottle. Comparing `total_orders` against `total_revenue` across categories also separates "high volume, lower ticket" categories (like Condiments, with more frequent but smaller orders) from "lower volume, higher ticket" ones — exactly the kind of distinction that shapes whether a category's growth strategy should focus on order volume or basket size.

## What was my biggest learning moment in this project?

Running the same layered pipeline twice — once against `shop_smart` and once against `northwind` — made it obvious how much of the original assignment's sample SQL was written for one specific version of the schema and not a universal template. The `northwind` upload turned out to already use snake_case columns (`order_id` instead of `orderid`), which broke my first run with a `column "categoryid" does not exist` error until I actually queried `LIMIT 1` on each raw table and rewrote the staging models to match reality. The other concrete lesson was naming: because both projects shared one dbt project and one `models/` tree, reusing the same filenames (`staging_orders.sql`, `prep_sales.sql`, etc.) across two source schemas caused a duplicate-model-name compile error — solved by prefixing every northwind file with `nw_`. Both issues reinforced the same idea: dbt's layered structure is only as reliable as the assumptions baked into the staging layer, so verifying the raw schema before writing a single line of staging SQL is not optional.
