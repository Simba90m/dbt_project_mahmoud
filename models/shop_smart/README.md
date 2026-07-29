# Shop Smart Sales Insights — Project Reflection

## What business problem does this dbt model solve?

The analytics team had three problems: raw data with inconsistent naming (`order_item_id`, `total_amount`, etc. spread across separate tables), analysts re-writing the same manual joins for every report, and no shared definition of "revenue." This project builds a layered dbt pipeline — staging, prep, and marts — so the cleaning happens once, the business logic (like the definition of revenue) is calculated once and agreed on, and any analyst or BI tool can query one trusted summary table instead of rebuilding the same joins from scratch.

## Which models did I build, and what does each do?

- **Staging models** (`staging_orders`, `staging_order_items`, `staging_products`): each pulls from one raw table in the `shop_smart` schema, casts types (dates to `DATE`, prices to `NUMERIC`), and standardizes column names. `staging_products` also renames the raw `category` column to `category_name` for clarity downstream.
- **Prep model** (`prep_sales`): joins the three staging models on `order_id` and `product_id`, and calculates `revenue` as `unit_price * quantity * (1 - discount)` per order line, along with `order_year` and `order_month` extracted from the order date.
- **Mart model** (`mart_sales_performance`): aggregates `prep_sales` by year, month, and category into `total_revenue`, `total_orders` (distinct order count), and `avg_revenue_per_order`. This is the table a BI dashboard would query directly.

I also added `schema.yml` with `not_null` tests on every mart column, so a broken join or missing source data would fail loudly with `dbt test` instead of silently producing an incomplete report.

## What insights can this mart provide to Shop Smart?

The mart shows how each category performs over time — which categories are growing or shrinking month over month, and whether there's seasonality in ordering. It also separates two things that are easy to conflate: total revenue and average revenue per order. A category can have high total revenue purely from a high volume of small orders, while another earns the same total from fewer, larger orders — that distinction matters for deciding whether to focus on customer acquisition (more orders) or basket size (bigger orders) for a given category.

## What was my biggest learning moment in this project?

The real dataset (`shop_smart`) turned out to be structured differently from the generic project brief — there's no separate `categories` table (category is just a column on `products`), and the raw table is called `order_items`, not `order_details`. That was a useful lesson in not blindly copying a sample solution: I had to actually inspect the schema with `SELECT * FROM shop_smart.orders LIMIT 5` before writing staging models, rather than assuming the brief's table shapes matched reality.

The more interesting discovery was that `orders` already has a `total_amount` column, separate from the `revenue` I calculate from `order_items`. This is a live example of the exact problem the brief opens with — "everyone calculates revenue differently." I deliberately chose to build `prep_sales.revenue` from the line-item data (`unit_price * quantity * (1 - discount)`) rather than trust the pre-existing `total_amount`, since the line-item calculation is transparent and auditable — anyone can see exactly how it was derived, whereas `total_amount` might already include shipping, tax, or a different discount logic I can't verify. That's the kind of judgment call a real analytics team has to make, and building the pipeline made it obvious rather than theoretical.
