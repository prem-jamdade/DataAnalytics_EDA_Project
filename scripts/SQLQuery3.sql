/* Analyse the yearly performance of the products by comparing  theirsales to the both
the average sales performance of the product and the previous years	sales */

WITH yearly_product_sales AS (
    SELECT 
        YEAR(s.order_date) AS order_year,
        p.product_name,
        SUM(s.sales_amount) AS current_sales
    FROM gold.dim_sales s
    LEFT JOIN gold.dim_product p
        ON p.product_key = s.product_key
    WHERE s.order_date IS NOT NULL
    GROUP BY 
        YEAR(s.order_date), 
        p.product_name
)
SELECT order_year
,product_name
, current_sales
, AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales
, current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg
, CASE WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above the Average'
	   WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below the Average'
	   ELSE 'Avg'
  END AS average_change
, LAG (current_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS previous_sales
, current_sales - LAG (current_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS diff_previoua_year
,CASE WHEN current_sales - LAG (current_sales) OVER(PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
	  WHEN current_sales - LAG (current_sales) OVER(PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
	  ELSE 'No Change'
 END AS yearly_change
FROM yearly_product_sales
ORDER BY product_name,order_year;

