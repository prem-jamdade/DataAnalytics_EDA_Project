-- Advanced Data Analytics
-- Change over time
SELECT YEAR(order_date) AS order_year
, MONTH(order_date) AS order_month
, SUM(sales_amount) AS total_amount
, COUNT(customer_key) AS toltal_customers
, SUM(quantity) AS total_quantity
FROM  gold.dim_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date)

-- Cumulative Analysis	
-- Calculate the total orders per month
SELECT 
DATETRUNC(MONTH,order_date)AS order_date
, COUNT(order_number) AS total_order
FROM gold.dim_sales
WHERE DATETRUNC(MONTH,order_date) IS NOT NULL
GROUP BY DATETRUNC(MONTH,order_date)
ORDER BY DATETRUNC(MONTH,order_date)

-- Calculate the total sales per month
-- the running total sales per month
-- Over the months
SELECT order_date
,total_sales
,SUM(total_sales) OVER (PARTITION BY order_date ORDER BY order_date) AS running_total_sales
,AVG(average_price) OVER (ORDER BY order_date) AS moving_avg_price
FROM(
SELECT 
DATETRUNC(MONTH,order_date) AS order_date
, SUM(sales_amount) AS total_sales
, AVG(price) AS average_price
FROM gold.dim_sales
WHERE MONTH(order_date) IS NOT NULL
GROUP BY DATETRUNC(MONTH,order_date)
--ORDER BY DATETRUNC(MONTH,order_date)
)t

-- Over the years
SELECT order_date
,total_sales
,SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales
,AVG(average_price) OVER (ORDER BY order_date) AS moving_avg_price
FROM(
SELECT 
DATETRUNC(YEAR,order_date) AS order_date
, SUM(sales_amount) AS total_sales
, AVG(price) AS average_price
FROM gold.dim_sales
WHERE YEAR(order_date) IS NOT NULL
GROUP BY DATETRUNC(YEAR,order_date)
)t


