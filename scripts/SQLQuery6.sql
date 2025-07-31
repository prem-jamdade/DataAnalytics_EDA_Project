-- ==============================================================================
-- Customer Segmentation Based on Spending Behavior
-- This query classifies customers into three segments (VIP, Regular, New)
-- based on their purchase history (lifespan in months) and total spending.
-- It then counts the number of customers in each segment.
-- ==============================================================================

-- Step 1: Aggregate customer lifetime and spending
WITH customer_spending AS (
    SELECT 
        c.customer_key,
        SUM(s.sales_amount) AS total_spending,                  -- Total money spent by the customer
        MIN(order_date) AS first_order,                         -- First purchase date
        MAX(order_date) AS last_order,                          -- Last purchase date
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS life_span -- Customer lifespan in months
    FROM gold.dim_sales s
    LEFT JOIN gold.dim_customers c
        ON s.customer_key = c.customer_key
    GROUP BY c.customer_key
)

-- Step 2: Assign customer to segment based on lifespan and spending
SELECT
    customer_segments,
    COUNT(customer_key) AS total_customers
FROM (
    SELECT
        customer_key,

        -- Categorize customer into VIP, Regular, or New
        CASE 
            WHEN life_span >= 12 AND total_spending > 5000 THEN 'VIP'
            WHEN life_span >= 12 AND total_spending <= 5000 THEN 'Regular'
            ELSE 'New'
        END AS customer_segments

    FROM customer_spending
) t
GROUP BY customer_segments
ORDER BY total_customers DESC; -- Show segment with most customers first
