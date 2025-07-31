-- ==============================================================================
-- Advanced Data Analytics: Time-based and Cumulative Trend Analysis
-- This script analyzes sales performance over time by month and year,
-- providing insight into trends, cumulative metrics, and moving averages.
-- ==============================================================================

-- ================================
-- Monthly sales trend analysis
-- Tracks changes in sales amount, quantity, and customer volume over time
-- ================================
SELECT 
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    SUM(sales_amount) AS total_amount,
    COUNT(customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.dim_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date);

-- ================================
-- Cumulative Analysis: Total orders per month
-- DATETRUNC(MONTH, order_date) extracts the first day of each month for grouping
-- ================================
SELECT 
    DATETRUNC(MONTH, order_date) AS order_date,
    COUNT(order_number) AS total_order
FROM gold.dim_sales
WHERE DATETRUNC(MONTH, order_date) IS NOT NULL
GROUP BY DATETRUNC(MONTH, order_date)
ORDER BY DATETRUNC(MONTH, order_date);

-- ================================
-- Cumulative and Moving Average Analysis (Monthly)
-- Tracks sales and pricing trends over months
-- running_total_sales: Cumulative sum of sales
-- moving_avg_price: Smoothed trend of average price
-- ================================
SELECT 
    order_date,
    total_sales,
    SUM(total_sales) OVER (PARTITION BY order_date ORDER BY order_date) AS running_total_sales,
    AVG(average_price) OVER (ORDER BY order_date) AS moving_avg_price
FROM (
    SELECT 
        DATETRUNC(MONTH, order_date) AS order_date,
        SUM(sales_amount) AS total_sales,
        AVG(price) AS average_price
    FROM gold.dim_sales
    WHERE MONTH(order_date) IS NOT NULL
    GROUP BY DATETRUNC(MONTH, order_date)
) t;

-- ================================
-- Cumulative and Moving Average Analysis (Yearly)
-- Similar to the monthly version but aggregated by year
-- ================================
SELECT 
    order_date,
    total_sales,
    SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,
    AVG(average_price) OVER (ORDER BY order_date) AS moving_avg_price
FROM (
    SELECT 
        DATETRUNC(YEAR, order_date) AS order_date,
        SUM(sales_amount) AS total_sales,
        AVG(price) AS average_price
    FROM gold.dim_sales
    WHERE YEAR(order_date) IS NOT NULL
    GROUP BY DATETRUNC(YEAR, order_date)
) t;
