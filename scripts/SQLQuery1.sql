-- ================================================================
-- Script to perform exploratory data analysis (EDA) on a data warehouse.
-- It extracts schema metadata, explores dimensions and facts,
-- calculates descriptive statistics and aggregates, 
-- performs magnitude and revenue analysis, and ranks key entities.
-- ================================================================

-- View all tables in the current database
USE DataWareHouse
SELECT * FROM INFORMATION_SCHEMA.TABLES

-- View all columns in all tables
SELECT * FROM INFORMATION_SCHEMA.COLUMNS

-- View columns specifically from the 'crm_cust_info' table
SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'crm_cust_info'

-- Get unique countries from customers
SELECT DISTINCT country FROM gold.dim_customers

-- Get unique category, subcategory, and product names
SELECT DISTINCT category, subcategory, product_name FROM gold.dim_product

-- ========== Date Analysis ==========

-- Determine range of order dates
SELECT MIN(order_date) AS lowest_order_dt,
       MAX(order_date) AS higest_order_dt,
       DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS order_range
FROM gold.dim_sales 

-- Age distribution based on customer birth dates
SELECT MIN(birth_date) AS oldest_birthdate,
       DATEDIFF(YEAR, MIN(birth_date), GETDATE()) AS oldest_age,
       MAX(birth_date) AS youngest_birthdate,
       DATEDIFF(YEAR, MAX(birth_date), GETDATE()) AS youngest_age,
       DATEDIFF(YEAR, MIN(birth_date), MAX(birth_date)) AS birthdate_range
FROM gold.dim_customers 

-- Preview data
SELECT * FROM gold.dim_customers
SELECT * FROM gold.dim_sales

-- ========== Sales Summary Metrics ==========

-- Total revenue
SELECT SUM(sales_amount) AS total_sales FROM gold.dim_sales

-- Total items sold
SELECT SUM(quantity) AS total_items_sold FROM gold.dim_sales

-- Average transaction amount
SELECT AVG(sales_amount) AS avg_selling_price FROM gold.dim_sales

-- Total and unique orders
SELECT COUNT(order_number) AS total_orders,
       COUNT(DISTINCT order_number) AS unique_total_orders
FROM gold.dim_sales

-- Total and unique product count in sales
SELECT COUNT(product_key) AS total_products,
       COUNT(DISTINCT product_key) AS unique_total_products 
FROM gold.dim_sales

-- Count of customers
SELECT COUNT(DISTINCT customer_key) AS total_customers 
FROM gold.dim_customers

-- Count of customers who placed orders
SELECT COUNT(DISTINCT customer_key) AS total_customers
FROM gold.dim_sales

-- ========== Consolidated Business Metrics Report ==========

SELECT 'Total Sales' AS measure_name, 
       SUM(sales_amount) AS measure_value 
FROM gold.dim_sales
UNION ALL
SELECT 'Total Quantity', SUM(quantity) FROM gold.dim_sales
UNION ALL 
SELECT 'Average Amount', AVG(sales_amount) FROM gold.dim_sales
UNION ALL 
SELECT 'Total Order', COUNT(DISTINCT order_number) FROM gold.dim_sales
UNION ALL 
SELECT 'Total Products', COUNT(DISTINCT product_key) FROM gold.dim_sales
UNION ALL 
SELECT 'Total Customers', COUNT(DISTINCT customer_key) FROM gold.dim_customers
UNION ALL 
SELECT 'Total Customers Who Placed Order', COUNT(DISTINCT customer_key) FROM gold.dim_sales

-- ========== Magnitude Analysis ==========

-- Customer distribution by country
SELECT country, COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY total_customers DESC

-- Customer distribution by gender
SELECT gender, COUNT(customer_id) AS total_customers
FROM gold.dim_customers 
GROUP BY gender
ORDER BY total_customers DESC

-- Product distribution by category
SELECT category, COUNT(product_name) AS total_product
FROM gold.dim_product
GROUP BY category
ORDER BY total_product DESC

-- Average product cost by category
SELECT category, AVG(cost) AS average_cost 
FROM gold.dim_product
GROUP BY category
ORDER BY average_cost DESC

-- Revenue breakdown by product category
SELECT pr.category,
       SUM(sa.sales_amount) AS total_revenue
FROM gold.dim_sales sa
LEFT JOIN gold.dim_product pr ON sa.product_key = pr.product_key
GROUP BY pr.category
ORDER BY total_revenue DESC

-- Revenue breakdown by customer
SELECT cu.customer_key,
       cu.first_name,
       cu.last_name,
       SUM(sa.sales_amount) AS total_revenue
FROM gold.dim_sales sa
LEFT JOIN gold.dim_customers cu ON sa.customer_key = cu.customer_key
GROUP BY cu.customer_key, cu.first_name, cu.last_name
ORDER BY total_revenue DESC

-- Quantity sold by customer country
SELECT c.country,
       SUM(s.quantity) AS total_sold_items
FROM gold.dim_sales s
LEFT JOIN gold.dim_customers c ON c.customer_key = s.customer_key
GROUP BY c.country
ORDER BY total_sold_items DESC

-- ========== Product Revenue Rankings ==========

-- Top 5 highest revenue-generating products
SELECT TOP 5
       p.product_name,
       SUM(s.sales_amount) AS total_revenue
FROM gold.dim_sales s
LEFT JOIN gold.dim_product p ON s.product_key = p.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC

-- Alternate with ranking
SELECT p.product_name,
       SUM(s.sales_amount) AS total_revenue,
       ROW_NUMBER() OVER (ORDER BY SUM(s.sales_amount) DESC) AS rank_products
FROM gold.dim_sales s
LEFT JOIN gold.dim_product p ON s.product_key = p.product_key
GROUP BY p.product_name

-- Top 5 lowest revenue-generating products
SELECT TOP 5
       p.product_name,
       SUM(s.sales_amount) AS total_amount
FROM gold.dim_sales s
LEFT JOIN gold.dim_product p ON s.product_key = p.product_key
GROUP BY p.product_name
ORDER BY total_amount

-- Alternate with ranking
SELECT p.product_name,
       SUM(s.sales_amount) AS total_revenue,
       ROW_NUMBER() OVER (ORDER BY SUM(s.sales_amount)) AS rank_products
FROM gold.dim_sales s
LEFT JOIN gold.dim_product p ON s.product_key = p.product_key
GROUP BY p.product_name
