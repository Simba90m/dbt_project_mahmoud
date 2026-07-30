# Northwind Sales Insights — Data Analysis Highlights

A dbt analytics pipeline built on the Northwind dataset, transforming raw order data into a trusted sales performance mart, then analyzed for real business insight. This document summarizes what the data actually shows.

**Stack:** dbt, SQL (PostgreSQL), Python (pandas, matplotlib, seaborn)
**Period analyzed:** July 1996 through May 1998 (23 months)
**Scope:** 8 product categories, built from `orders`, `order_details`, `products`, and `categories`

---

## The Headline Numbers

- **€1,265,793** in total revenue analyzed across the full period
- **Beverages** is the top category by revenue at **€267,868**, 21.2% of all revenue on its own
- **Beverages and Dairy Products together account for 39.7%** of total revenue, essentially two categories driving four in ten euros earned
- **Meat and Poultry has the highest average order value at €1,012.56**, more than double Seafood's €451.07 average, a 2.24x gap between the two
- Comparing the same four months year over year, **revenue grew 120.7%** from January through April 1997 (€191,322) to January through April 1998 (€422,290)
- **April 1998 was the single highest revenue month** in the dataset at €123,799

## Category Breakdown

| Category | Revenue | % of Total | Orders | Avg Order Value |
|---|---:|---:|---:|---:|
| Beverages | €267,868 | 21.2% | 354 | €756.69 |
| Dairy Products | €234,507 | 18.5% | 303 | €773.95 |
| Confections | €167,357 | 13.2% | 295 | €567.31 |
| Meat/Poultry | €163,022 | 12.9% | 161 | **€1,012.56** |
| Seafood | €131,262 | 10.4% | 291 | €451.07 |
| Condiments | €106,047 | 8.4% | 193 | €549.47 |
| Produce | €99,985 | 7.9% | 129 | €775.07 |
| Grains/Cereals | €95,745 | 7.6% | 182 | €526.07 |

## What the Numbers Say

**Revenue is concentrated, not evenly spread.** The top two categories, Beverages and Dairy Products, generate close to forty percent of total revenue between them, while the bottom two, Produce and Grains and Cereals, combine for under sixteen percent. A category strategy built around "treat every category the same" would be missing where the actual leverage is.

**Order volume and order value tell two different stories.** Meat and Poultry sits fourth in total revenue, but has by far the fewest orders (161) and by far the highest average order value (€1,012.56). Compare that to Seafood, which has nearly double the order count (291) but the lowest average order value in the dataset (€451.07), less than half of Meat and Poultry's average. That's not a coincidence, it's two different customer behaviors: a smaller base of high spending buyers driving Meat and Poultry, versus a larger base of smaller, more frequent purchases driving Seafood. Those two categories need different strategies, upselling and bundling would likely do more for Seafood's revenue than trying to add more orders, while retention and account growth would matter more for Meat and Poultry's smaller customer base.

**Growth accelerated sharply into 1998.** Revenue for January through April more than doubled year over year, up 120.7% from 1997 to 1998. April 1998 alone brought in more revenue than any other single month in the dataset. That kind of jump is worth investigating further, whether it reflects a new customer, a promotion, seasonality, or genuine business growth, but the mart makes the signal visible in the first place, which is the whole point of building it.

## How These Numbers Were Produced

Every figure above traces back to a tested dbt pipeline, not a one off spreadsheet calculation:

1. **Staging models** clean and standardize the raw `orders`, `order_details`, `products`, and `categories` tables
2. **A prep model** joins them and calculates `revenue` as `unit_price * quantity * (1 - discount)`, applied consistently to every order line
3. **A mart model** aggregates that into `total_revenue`, `total_orders`, and `avg_revenue_per_order` by year, month, and category
4. **Automated tests** (`not_null` on every mart column) confirm no missing or broken data reaches the final numbers

Because the revenue definition lives in one place in the pipeline instead of being recalculated ad hoc, every number in this document is reproducible and auditable, not a one time export that can't be checked.

## Visuals

The full chart set (revenue by category, monthly trend, order volume vs order value, and year over year comparison) is available in [`Northwind_Analysis.ipynb`](./Northwind_Analysis.ipynb), built with pandas, matplotlib, and seaborn directly from the mart output.

---

*Part of the Northwind Sales Insights project, a dbt mini project for a Data Analytics and AI bootcamp.*
