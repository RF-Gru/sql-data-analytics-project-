/*
===============================================================================
Part-to-Whole Analysis
===============================================================================
Purpose:
    - To compare performance or metrics across dimensions or time periods.
    - To evaluate differences between categories.
    - Useful for A/B testing or regional comparisons.

SQL Functions Used:
    - SUM(), AVG(): Aggregates values for comparison.
    - Window Functions: SUM() OVER() for total calculations.
===============================================================================
*/
-- Which categories contribute the most to overall sales?

WITH cat_sales AS (
  SELECT 
	category, 
	SUM(sales_amount) AS total_sales
	FROM fact_sales AS fs
	LEFT JOIN dim_products AS dp
		ON fs.product_key = dp.product_key
	GROUP BY category
)
    
SELECT 
	category,
    	total_sales,
    	SUM(total_sales) OVER () AS overall_sales,
    	CONCAT(ROUND((total_sales / SUM(total_sales) OVER ()) * 100,2), '%') AS percentage_of_total
FROM cat_sales
GROUP BY category
ORDER BY total_sales DESC;    
