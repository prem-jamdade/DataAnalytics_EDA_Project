/* Group customeers into three segments based on their spending behaiver:
	- VIP: customers with atleast 12 monthof history and spending more than €5,000.
	- Regular: customers with atleast 12 monthof history and spending more than €5,000 or less.
	- New: customers with a lifespan less than 12 months.
And find the total number of customers by each group*/

WITH customer_spending AS(
SELECT 
c.customer_key
, SUM(s.sales_amount) AS total_spending
, MIN(order_date) AS first_order
, MAX(order_date) AS last_order
, DATEDIFF(month,  MIN(order_date), MAX(order_date)) AS life_span
FROM gold.dim_sales s
LEFT JOIN gold.dim_customers c
ON s.customer_key = c.customer_key
GROUP BY c.customer_key
)

SELECT
customer_segments
,COUNT(customer_key) AS total_customers
	FROM (
		SELECT
		customer_key
		,CASE WHEN life_span >=12 AND total_spending > 5000 THEN 'VIP'
			   WHEN life_span >=12 AND total_spending <= 5000 THEN 'Regular'
			   ELSE 'New'
		  END AS customer_segments
		FROM customer_spending
	)t
GROUP BY customer_segments
ORDER BY total_customers DESC