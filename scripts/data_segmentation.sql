/*
===============================================================================
Data Segmentation Analysis
===============================================================================
Purpose:
    - To group data into meaningful categories for targeted insights.
    - For customer segmentation, product categorization, or regional analysis.

SQL Functions Used:
    - CASE: Defines custom segmentation logic.
    - GROUP BY: Groups data into segments.
===============================================================================
*/

/*Segment products into cost ranges and 
count how many products fall into each segment*/

WITH product_segments AS (
  SELECT 
	  product_key,
    product_name,
    cost,
    CASE 
		WHEN cost < 100 THEN 'Below 100'
        WHEN cost BETWEEN 100 AND 500 THEN '100 -500'
        WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
        ELSE 'Above 1000'
	END cost_range
  FROM dim_products)
 
 SELECT 
	cost_range,
    COUNT(product_key) AS total_products
 FROM product_segments
 GROUP BY cost_range
 ORDER BY total_products DESC;

/*Group customers into three segments based on their spending behavior:
	- VIP: Customers with at least 12 months of history and spending more than €5,000.
	- Regular: Customers with at least 12 months of history but spending €5,000 or less.
	- New: Customers with a lifespan less than 12 months.
And find the total number of customers by each group
*/

WITH cust_spending AS
	(SELECT 
		cust.customer_key,
		SUM(f.sales_amount) as total_spend,
		MIN(order_date) AS first_order,
		MAX(order_date) AS last_order,
		TIMESTAMPDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
	FROM fact_sales AS f
	LEFT JOIN dim_customers AS cust
		ON f.customer_key = cust.customer_key
	GROUP BY cust.customer_key)

SELECT
	  COUNT(customer_key) AS total_customers,
    cust_segment
FROM      
	(SELECT 
		customer_key,
		CASE
			WHEN lifespan >= 12 AND total_spend > 5000 THEN 'VIP'
			WHEN lifespan >= 12 AND total_spend <= 5000 THEN 'Regular'
			ELSE 'New' 
		END  AS cust_segment
	FROM cust_spending) AS CS   
GROUP BY cust_segment;  
