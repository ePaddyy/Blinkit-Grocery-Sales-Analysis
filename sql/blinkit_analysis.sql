-- =============================================================================
-- Blinkit Grocery Sales Analysis
-- Dialect: PostgreSQL. Table: blinkit_data (loaded from data/blinkit_grocery_data.csv)
-- =============================================================================


-- -----------------------------------------------------------------------------
-- 1. Data cleaning
-- The fat-content column uses five spellings for two categories
-- ('Low Fat', 'low fat', 'LF', 'Regular', 'reg'). Standardise them.
-- -----------------------------------------------------------------------------
UPDATE blinkit_data
SET item_fat_content =
    CASE
        WHEN item_fat_content IN ('low fat', 'LF') THEN 'Low Fat'
        WHEN item_fat_content = 'reg'              THEN 'Regular'
        ELSE item_fat_content
    END;

-- Check: should return exactly 'Low Fat' and 'Regular'
SELECT DISTINCT item_fat_content FROM blinkit_data;


-- -----------------------------------------------------------------------------
-- 2. Headline KPIs (all outlets)
-- -----------------------------------------------------------------------------
SELECT
    CAST(SUM(total_sales) / 1000000 AS DECIMAL(10, 2)) AS total_sales_millions,
    CAST(AVG(total_sales)           AS DECIMAL(10, 2)) AS avg_sales,
    COUNT(*)                                           AS no_of_items,
    CAST(AVG(rating)                AS DECIMAL(10, 2)) AS avg_rating
FROM blinkit_data;

-- Same KPIs for outlets established in 2022
SELECT
    CAST(SUM(total_sales) / 1000000 AS DECIMAL(10, 2)) AS total_sales_millions,
    CAST(AVG(total_sales)           AS DECIMAL(10, 2)) AS avg_sales,
    COUNT(*)                                           AS no_of_items,
    CAST(AVG(rating)                AS DECIMAL(10, 2)) AS avg_rating
FROM blinkit_data
WHERE outlet_establishment_year = 2022;


-- -----------------------------------------------------------------------------
-- 3. Sales by fat content
-- -----------------------------------------------------------------------------
SELECT
    item_fat_content,
    CAST(SUM(total_sales) / 1000 AS DECIMAL(10, 2)) AS total_sales_thousands,
    CAST(AVG(total_sales)        AS DECIMAL(10, 2)) AS avg_sales,
    COUNT(*)                                        AS no_of_items,
    CAST(AVG(rating)             AS DECIMAL(10, 2)) AS avg_rating
FROM blinkit_data
GROUP BY item_fat_content
ORDER BY total_sales_thousands DESC;


-- -----------------------------------------------------------------------------
-- 4. Top 10 item types by sales
-- -----------------------------------------------------------------------------
SELECT
    item_type,
    CAST(SUM(total_sales) / 1000 AS DECIMAL(10, 2)) AS total_sales_thousands,
    CAST(AVG(total_sales)        AS DECIMAL(10, 2)) AS avg_sales,
    COUNT(*)                                        AS no_of_items,
    CAST(AVG(rating)             AS DECIMAL(10, 2)) AS avg_rating
FROM blinkit_data
GROUP BY item_type
ORDER BY total_sales_thousands DESC
LIMIT 10;


-- -----------------------------------------------------------------------------
-- 5. Fat content by outlet tier (pivot with conditional aggregation)
-- -----------------------------------------------------------------------------
SELECT
    outlet_location_type,
    CAST(COALESCE(SUM(CASE WHEN item_fat_content = 'Low Fat' THEN total_sales END), 0) AS DECIMAL(10, 2)) AS low_fat,
    CAST(COALESCE(SUM(CASE WHEN item_fat_content = 'Regular' THEN total_sales END), 0) AS DECIMAL(10, 2)) AS regular
FROM blinkit_data
GROUP BY outlet_location_type
ORDER BY outlet_location_type;


-- -----------------------------------------------------------------------------
-- 6. Sales by outlet establishment year
-- -----------------------------------------------------------------------------
SELECT
    outlet_establishment_year,
    CAST(SUM(total_sales) AS DECIMAL(10, 2)) AS total_sales,
    CAST(AVG(total_sales) AS DECIMAL(10, 2)) AS avg_sales,
    COUNT(*)                                 AS no_of_items,
    CAST(AVG(rating)      AS DECIMAL(10, 2)) AS avg_rating
FROM blinkit_data
GROUP BY outlet_establishment_year
ORDER BY outlet_establishment_year;


-- -----------------------------------------------------------------------------
-- 7. Share of sales by outlet size (window function over the grouped totals)
-- -----------------------------------------------------------------------------
SELECT
    outlet_size,
    CAST(SUM(total_sales) AS DECIMAL(10, 2))                                   AS total_sales,
    ROUND(CAST(SUM(total_sales) * 100.0 / SUM(SUM(total_sales)) OVER () AS NUMERIC), 2) AS sales_percentage
FROM blinkit_data
GROUP BY outlet_size
ORDER BY sales_percentage DESC;


-- -----------------------------------------------------------------------------
-- 8. Sales by outlet type
-- -----------------------------------------------------------------------------
SELECT
    outlet_type,
    CAST(SUM(total_sales) AS DECIMAL(10, 2))                                   AS total_sales,
    ROUND(CAST(SUM(total_sales) * 100.0 / SUM(SUM(total_sales)) OVER () AS NUMERIC), 2) AS sales_percentage,
    CAST(AVG(total_sales) AS DECIMAL(10, 2))                                   AS avg_sales,
    COUNT(*)                                                                   AS no_of_items,
    CAST(AVG(rating)      AS DECIMAL(10, 2))                                   AS avg_rating
FROM blinkit_data
GROUP BY outlet_type
ORDER BY sales_percentage DESC;


-- -----------------------------------------------------------------------------
-- 9. Sales by outlet location tier
-- -----------------------------------------------------------------------------
SELECT
    outlet_location_type,
    CAST(SUM(total_sales) AS DECIMAL(10, 2))                                   AS total_sales,
    ROUND(CAST(SUM(total_sales) * 100.0 / SUM(SUM(total_sales)) OVER () AS NUMERIC), 2) AS sales_percentage,
    CAST(AVG(total_sales) AS DECIMAL(10, 2))                                   AS avg_sales,
    COUNT(*)                                                                   AS no_of_items,
    CAST(AVG(rating)      AS DECIMAL(10, 2))                                   AS avg_rating
FROM blinkit_data
GROUP BY outlet_location_type
ORDER BY sales_percentage DESC;
