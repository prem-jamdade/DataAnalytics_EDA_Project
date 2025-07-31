-- ==============================================================================
-- Data Segmentation: Product Distribution by Cost Range
-- This query segments products into predefined cost ranges to analyze 
-- the distribution of product pricing in the catalog.
-- ==============================================================================

-- Step 1: Categorize each product into a cost range using a CASE expression
WITH product_segmentation AS (
    SELECT 
        product_key,
        product_name,
        cost,

        -- Assign each product to a cost range category
        CASE 
            WHEN cost < 100 THEN 'Below 100'
            WHEN cost BETWEEN 100 AND 500 THEN 'Between 100-500'
            WHEN cost BETWEEN 500 AND 1000 THEN 'Between 500-1000'
            ELSE 'Above 1000'
        END AS cost_range
    FROM gold.dim_product
)

-- Step 2: Aggregate number of products in each cost segment
SELECT 
    cost_range,
    COUNT(product_key) AS total_products
FROM product_segmentation
GROUP BY cost_range
ORDER BY total_products DESC; -- Show most common price segments first
