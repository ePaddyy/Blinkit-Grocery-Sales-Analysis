# Blinkit Grocery Sales Analysis

SQL analysis and an interactive Power BI dashboard on **8,523 grocery items sold across 10 Blinkit outlets**, breaking down sales by item category, fat content, outlet size, outlet type and city tier.

**Tools:** PostgreSQL · Power BI (DAX) · Excel

---

## Business questions

1. What are total sales, average sales per item, item count and average customer rating?
2. Which item categories drive revenue?
3. How do sales split between Low Fat and Regular products, and does that change by city tier?
4. Which outlet sizes, types and locations contribute most to sales?

## Key findings

| KPI | Value |
| --- | --- |
| Total sales | **1.20 M** |
| Average sales per item | **140.99** |
| Items sold | **8,523** |
| Average rating | **3.97 / 5** |

- **Fruits & Vegetables (178K) and Snack Foods (175K)** are the top two categories, ahead of Household (136K). Together these three account for about 41% of sales.
- **Low Fat products bring in 65% of sales** (776K vs 425K), and the pattern holds across every city tier.
- **Tier 3 cities generate the most sales (39%)**, ahead of Tier 2 (33%) and Tier 1 (28%).
- **Supermarket Type 1 outlets account for 66% of sales.** Medium-sized outlets lead by size (42%).
- **Average rating barely moves (3.92–4.02) across categories and outlets**, so ratings don't differentiate performance here. Volume and outlet type do.

## What I did

### 1. Data cleaning (SQL)
The `item_fat_content` column had **five spellings for two categories** (`Low Fat`, `low fat`, `LF`, `Regular`, `reg`). I standardised them with an `UPDATE … CASE` so every later aggregate is correct.

### 2. Analysis (SQL)
[`sql/blinkit_analysis.sql`](sql/blinkit_analysis.sql) contains every query, in order:
- Headline KPIs, overall and for outlets established in 2022
- Sales by fat content and the top 10 item types
- Fat content by outlet tier (pivot via conditional aggregation)
- Sales by outlet establishment year
- Share of sales by outlet size, type and location, using a window function (`SUM(SUM(total_sales)) OVER ()`) to compute percentages of the grand total

### 3. Dashboard (Power BI)
[`dashboard/blinkit_dashboard.pbix`](dashboard/blinkit_dashboard.pbix): a one-page interactive dashboard built on a dedicated DAX **measures table** (Total Sales, Average Sales, Number of Items, Average Rating).

- **KPI cards** for the four headline measures
- **Metric switcher** (field-parameter slicer) to change which measure the charts show
- **Fat content** (donut) and **fat content by outlet tier** (clustered bar)
- **Sales by item type** (bar)
- **Outlet establishment year** trend (line)
- **Outlet size** (donut) and **outlet location** (funnel)
- **Outlet type** matrix with sales, items, average sales, rating and visibility
- **Slicers** for outlet location, outlet size and outlet type

A second page holds the exploratory charts used while building it.

> Open the `.pbix` file in [Power BI Desktop](https://powerbi.microsoft.com/desktop/) (free) to explore it.

## Repository structure

```
├── data/
│   └── blinkit_grocery_data.csv     raw dataset (8,523 rows, 12 columns)
├── sql/
│   └── blinkit_analysis.sql         cleaning + analysis queries (PostgreSQL)
├── dashboard/
│   └── blinkit_dashboard.pbix       Power BI dashboard
└── README.md
```

## Reproduce the SQL analysis

1. Create a PostgreSQL table `blinkit_data` with snake_case columns: `item_fat_content`, `item_identifier`, `item_type`, `outlet_establishment_year`, `outlet_identifier`, `outlet_location_type`, `outlet_size`, `outlet_type`, `item_visibility`, `item_weight`, `total_sales`, `rating`.
2. Import `data/blinkit_grocery_data.csv` into it.
3. Run `sql/blinkit_analysis.sql` top to bottom.

## Data

A public sample dataset of Blinkit (Indian quick-commerce grocery) sales, widely used for analytics practice. Sales figures are shown as given in the dataset, without currency conversion.

---

**Author:** [Emmanuel Paddy Adams](https://epaddyy.github.io), Machine Learning Engineer, Accra, Ghana
