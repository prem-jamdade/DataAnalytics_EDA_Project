-- Data Segmentation

WITH product_segmentation AS (
SELECT product_key
, product_name
, cost
,CASE WHEN cost < 100 THEN 'Below 100'
	 WHEN cost BETWEEN 100 AND 500  THEN 'Between 100-500'
	 WHEN cost BETWEEN 500 AND 1000  THEN 'Between 500-1000'
	 ELSE 'Above 1000'
END AS cost_range
FROM gold.dim_product
)
SELECT 
cost_range
, COUNT(product_key) AS total_products
FROM product_segmentation
GROUP BY cost_range
ORDER BY total_products DESC	;

