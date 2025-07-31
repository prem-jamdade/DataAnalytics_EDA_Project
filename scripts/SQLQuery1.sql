USE DataWareHouse
SELECT * FROM INFORMATION_SCHEMA.TABLES

SELECT * FROM INFORMATION_SCHEMA.COLUMNS

SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'crm_cust_info'

SELECT DISTINCT country FROM gold.dim_customers

SELECT DISTINCT category, subcategory, product_name FROM gold.dim_product

-- Exploring dates
SELECT MIN(order_date) AS lowest_order_dt
, MAX(order_date) AS higest_order_dt 
, DAtEDIFF(MONTH, MIN(order_date),MAX(order_date)) as order_range
FROM gold.dim_sales 

SELECT MIN(birth_date) AS oldest_birthdate
, DAtEDIFF(YEAR, MIN(birth_date),GETDATE()) as oldest_age
, MAX(birth_date) AS youngest_birthdate 
, DAtEDIFF(YEAR, MAX(birth_date),GETDATE()) as youngest_age
, DAtEDIFF(YEAR, MIN(birth_date),MAX(birth_date)) as birthdate_range
FROM gold.dim_customers 

SELECT * FROM gold.dim_customers

SELECT * FROM gold.dim_sales

-- Total sales
SELECT SUM(sales_amount) AS total_sales FROM gold.dim_sales
-- Items Sold
SELECT SUM(quantity) AS total_Items_sold FROM gold.dim_sales
-- Average selling price
SELECT AVG(sales_amount) AS avg_selling_price FROM gold.dim_sales

-- Total number of orders 
SELECT COUNT(order_number) AS total_orders
,COUNT(DISTINCT(order_number)) AS unique_total_orders
FROM gold.dim_sales

-- Total number of products
SELECT COUNT(product_key) AS total_products
,COUNT(DISTINCT(product_key)) AS unique_total_products 
FROM gold.dim_sales

-- Total number of customers 
SELECT COUNT(DISTINCT(customer_key)) AS total_customers 
FROM gold.dim_customers

-- Total number of customers who has placed an order
SELECT COUNT(DISTINCT(customer_key)) AS total_customers
FROM gold.dim_sales

-- Generate the report that shows all key metrics of the business
SELECT 'Total Sales' AS measure_name 
,SUM(sales_amount) AS measure_value FROM gold.dim_sales
UNION ALL
SELECT 'Total Quantity' AS measure_name 
,SUM(quantity) AS measure_value FROM gold.dim_sales
UNION ALL 
SELECT 'Average Amount' AS measure_name 
,AVG(sales_amount) AS measure_value FROM gold.dim_sales
UNION ALL 
SELECT 'Total Order' AS measure_name 
,COUNT(DISTINCT(order_number)) AS measure_value
FROM gold.dim_sales
UNION ALL 
SELECT 'Tota Products' AS measure_name
,COUNT(DISTINCT(product_key)) AS measure_value
FROM gold.dim_sales
UNION ALL 
SELECT 'Total Customers' AS measure_name
,COUNT(DISTINCT(customer_key)) AS measure_value
FROM gold.dim_customers
UNION ALL 
SELECT 'Total Customers Who placed order' AS measure_name 
,COUNT(DISTINCT(customer_key)) AS measure_value
FROM gold.dim_sales

-- Magnitude Analysis 
-- Country and total customers
SELECT country 
, COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY total_customers DESC

-- genter and total customers 
SELECT gender 
, COUNT(customer_id) AS total_customers
FROM gold.dim_customers 
GROUP BY gender
ORDER BY total_customers DESC

-- category and product
SELECT category
, COUNT(product_name) AS total_product
FROM gold.dim_product
GROUP BY category
ORDER BY total_product DESC

-- category and avg_cost
SELECT category
, AVG(cost) AS average_cost 
FROM gold.dim_product
GROUP BY category
ORDER BY average_cost DESC

-- Total revenue and category 
SELECT pr.category
,SUM(sa.sales_amount) AS total_revenue
FROM gold.dim_sales sa
LEFT JOIN gold.dim_product pr ON  
sa.product_key = pr.product_key
GROUP BY pr.category
ORDER BY total_revenue DESC

-- Total revenue and customer 
SELECT cu.customer_key
,cu.first_name
,cu.last_name
,SUM(sa.sales_amount) AS total_revenue
FROM gold.dim_sales sa
LEFT JOIN gold.dim_customers cu ON  
sa.customer_key = cu.customer_key
GROUP BY cu.customer_key, first_name, last_name
ORDER BY total_revenue DESC

-- Distribution of sold Items accros countrys (quanty by country)
SELECT c.country
, SUM(s.quantity) AS total_sold_items
FROM gold.dim_sales s
LEFT JOIN gold.dim_customers c
ON c.customer_key = s.customer_key
GROUP BY c.country
ORDER BY total_sold_items DESC

-- Ranking 

-- Top 5 product generating higest revenue
SELECT  TOP 5
p.product_name
,SUM(s.sales_amount) AS total_revenue
FROM gold.dim_sales s
LEFT JOIN gold.dim_product p
ON s.product_key = p.product_key
GROUP BY product_name
ORDER BY total_revenue DESC

-- OR
SELECT
p.product_name
,SUM(s.sales_amount) AS total_revenue
,ROW_NUMBER() OVER(ORDER BY SUM(s.sales_amount) DESC) AS rank_products
FROM gold.dim_sales s
LEFT JOIN gold.dim_product p
ON s.product_key = p.product_key
GROUP BY p.product_name

-- Top 5 product generating lowest revenue
SELECT  TOP 5
p.product_name
,SUM(s.sales_amount) AS total_amount
FROM gold.dim_sales s
LEFT JOIN gold.dim_product p
ON s.product_key = p.product_key
GROUP BY product_name
ORDER BY total_amount 

-- OR
SELECT
p.product_name
,SUM(s.sales_amount) AS total_revenue
,ROW_NUMBER() OVER(ORDER BY SUM(s.sales_amount)) AS rank_products
FROM gold.dim_sales s
LEFT JOIN gold.dim_product p
ON s.product_key = p.product_key
GROUP BY p.product_name
