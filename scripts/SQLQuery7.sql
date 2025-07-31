
CREATE VIEW gold.report_customer AS 
WITH base_query AS (
SELECT 
order_number
, s.order_date
, s.product_key
, s.sales_amount
, s.quantity
, c.customer_key
, c.customer_number
, CONCAT (c.first_name, ' ', c.last_name) AS name
, DATEDIFF(YEAR, c.birth_date, GETDATE()) AS age 
FROM	gold.dim_sales s
LEFT JOIN gold.dim_customers c
ON s.customer_key = c.customer_key
WHERE order_date IS NOT NULL
) 

, customer_aggregation AS(
SELECT
customer_key
, customer_number
, name
,age
,COUNT(DISTINCT order_number) AS total_orders
, SUM(sales_amount ) AS total_sales
, SUM(quantity) AS total_quantity
, COUNT(DISTINCT(product_key)) AS total_products
, MAX(order_date) AS last_order_date
, DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS life_span
FROM base_query
GROUP BY customer_key, customer_number, name, age
)

SELECT 
customer_key
, customer_number
, name
, age 
, CASE WHEN age < 20 THEN 'under 20'
       WHEN age BETWEEN 20 AND 30 THEN '20-30'
	   WHEN age BETWEEN 30 AND 40 THEN '30-40'
	   WHEN age BETWEEN 40 AND 50 THEN '40-50'
	   ELSE 'Above 50'
  END AS age_group   
,CASE 
	WHEN life_span >=12 AND total_sales > 5000 THEN 'VIP'
	WHEN life_span >=12 AND total_sales <= 5000 THEN 'Regular'
	ELSE 'New'
 END AS customer_segments
, last_order_date
, DATEDIFF(MONTH, last_order_date, GETDATE()) AS recency
, total_orders
, total_sales
, total_quantity
, total_products
, life_span
, CASE WHEN total_orders = 0 THEN 0
	   ELSE total_sales / total_orders 
  END AS avg_order_value
, 
CASE WHEN life_span = 0 THEN 0
	   ELSE total_sales / life_span 
  END AS avg_monthyl_spend
  
FROM customer_aggregation
