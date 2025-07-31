-- ==============================================================================
-- View: gold.report_products
-- Purpose:
-- This view builds a product performance report that summarizes each product's 
-- sales history, segmentation, popularity, and profitability across key metrics.
-- ==============================================================================

-- Drop the view if it already exists
IF OBJECT_ID('gold.report_products', 'V') IS NOT NULL
    DROP VIEW gold.report_products;
GO

-- Create the product performance report view
CREATE VIEW gold.report_products AS

-- ======================
-- Step 1: Base Query
-- Join sales and product details
-- ======================
WITH base_query AS (
    SELECT
        f.order_number,
        f.order_date,
        f.customer_key,
        f.sales_amount,
        f.quantity,
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost
    FROM gold.dim_sales f
    LEFT JOIN gold.dim_product p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
),

-- ======================
-- Step 2: Aggregate Product Metrics
-- Calculate performance statistics for each product
-- ======================
product_aggregations AS (
    SELECT
        product_key,
        product_name,
        category,
        subcategory,
        cost,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,      -- Product active span in months
        MAX(order_date) AS last_sale_date,
        COUNT(DISTINCT order_number) AS total_orders,                       -- Unique orders including the product
        COUNT(DISTINCT customer_key) AS total_customers,                   -- Number of distinct buyers
        SUM(sales_amount) AS total_sales,                                  -- Total revenue
        SUM(quantity) AS total_quantity,                                   -- Total units sold
        ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)), 1) AS avg_selling_price -- Per-unit average
    FROM base_query
    GROUP BY
        product_key,
        product_name,
        category,
        subcategory,
        cost
)

-- ======================
-- Step 3: Final Output
-- Add product segmentation and derived metrics
-- ======================
SELECT 
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    last_sale_date,

    -- Recency in months: how long since the product was last sold
    DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency_in_months,

    -- Segment products based on revenue performance
    CASE
        WHEN total_sales > 50000 THEN 'High-Performer'
        WHEN total_sales >= 10000 THEN 'Mid-Range'
        ELSE 'Low-Performer'
    END AS product_segment,

    lifespan,
    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    avg_selling_price,

    -- Average revenue per order containing the product
    CASE 
        WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders
    END AS avg_order_revenue,

    -- Average monthly revenue across the product’s lifespan
    CASE
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan
    END AS avg_monthly_revenue

FROM product_aggregations;
