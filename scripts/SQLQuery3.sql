-- ==============================================================================
-- Product Sales Yearly Performance Analysis
-- This query compares yearly product sales to:
-- (1) the product's average yearly performance,
-- (2) the product's sales in the previous year.
-- The result helps identify trends and growth patterns.
-- ==============================================================================

-- Step 1: Create a CTE to calculate yearly sales per product
WITH yearly_product_sales AS (
    SELECT 
        YEAR(s.order_date) AS order_year,         -- Extract year from order date
        p.product_name,
        SUM(s.sales_amount) AS current_sales      -- Total sales of the product for that year
    FROM gold.dim_sales s
    LEFT JOIN gold.dim_product p
        ON p.product_key = s.product_key
    WHERE s.order_date IS NOT NULL
    GROUP BY 
        YEAR(s.order_date), 
        p.product_name
)

-- Step 2: Compare current year sales to average and previous year
SELECT 
    order_year,
    product_name,
    current_sales,

    -- Calculate average sales of the product across all years
    AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,

    -- Difference from average sales
    current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,

    -- Classification based on average comparison
    CASE 
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above the Average'
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below the Average'
        ELSE 'Avg'
    END AS average_change,

    -- Previous year's sales using LAG window function
    LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS previous_sales,

    -- Difference from previous year
    current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_previous_year,

    -- Classification based on year-over-year comparison
    CASE 
        WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
        WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
        ELSE 'No Change'
    END AS yearly_change

FROM yearly_product_sales
ORDER BY product_name, order_year;
