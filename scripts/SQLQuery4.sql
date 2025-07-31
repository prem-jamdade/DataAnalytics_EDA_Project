-- ==============================================================================
-- Part-to-Whole Analysis: Category Contribution to Total Sales
-- This query identifies how much each product category contributes to the overall sales,
-- calculates the percentage share, and ranks categories by total revenue.
-- ==============================================================================

-- Step 1: Calculate total sales by category using a CTE
WITH category_sales AS (
    SELECT  
        category,
        SUM(s.sales_amount) AS total_sales -- Total revenue per category
    FROM gold.dim_sales s
    LEFT JOIN gold.dim_product p 
        ON s.product_key = p.product_key
    GROUP BY category
)

-- Step 2: Compute overall sales and percentage share per category
SELECT 
    category,
    total_sales,

    -- Calculate overall sales using window function (same value repeated for each row)
    SUM(total_sales) OVER() AS overall_sales,

    -- Calculate share of total as a percentage (rounded to 2 decimal places and concatenated with % symbol)
    CONCAT(ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER()) * 100, 2), '%') AS percentage_of_total

FROM category_sales
ORDER BY total_sales DESC; -- Rank categories from highest to lowest contribution
