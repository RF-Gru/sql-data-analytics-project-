/*
===============================================================================
Performance Analysis (Year-over-Year, Month-over-Month)
===============================================================================
Purpose:
    - To measure the performance of products, customers, or regions over time.
    - For benchmarking and identifying high-performing entities.
    - To track yearly trends and growth.

SQL Functions Used:
    - LAG(): Accesses data from previous rows.
    - AVG() OVER(): Computes average values within partitions.
    - CASE: Defines conditional logic for trend analysis.
===============================================================================
*/

/* Analyze the yearly performance of products by comparing their sales 
to both the average sales performance of the product and the previous year's sales */
With yearly_current_sales AS (
  SELECT 
    YEAR(fs.order_date) AS order_year, 
		dp.product_name, 
    SUM(fs.sales_amount) AS current_sales
	FROM fact_sales AS fs
	LEFT JOIN dim_products AS dp
		ON fs.product_key = dp.product_key
	WHERE order_date IS NOT NULL
  GROUP BY YEAR(order_date), product_name
	ORDER BY product_name, order_year
)
        
-- QUERIED FOR TOTAL SALES AND AVERAGE SALES FOR EACH PRODUCT PER YEAR
 
SELECT 
	  order_year, 
    product_name, 
    current_sales, 
    (current_sales) - (ROUND(AVG(current_sales) OVER (PARTITION BY product_name))) AS diff_avg,
    ROUND(AVG(current_sales) OVER (PARTITION BY product_name)) as avg_sales,
    CASE 
		WHEN (current_sales) - (ROUND(AVG(current_sales) OVER (PARTITION BY product_name))) > 0  THEN 'Above Avg'
        WHEN (current_sales) - (ROUND(AVG(current_sales) OVER (PARTITION BY product_name))) < 0 THEN 'Below Avg'
        ELSE 'Avg'
    END as avg_change,   
   
   
 -- YEAR-OVER-YEAR ANALYSIS	
    
  LAG(current_sales) OVER (Partition by product_name ORDER BY order_year) AS py_sales,
  (current_sales) - (LAG(current_sales) OVER (Partition by product_name ORDER BY order_year)) AS diff_py,
  CASE 
    WHEN (current_sales) - (LAG(current_sales) OVER (Partition by product_name ORDER BY order_year)) > 0  THEN 'Increase'
    WHEN (current_sales) - (LAG(current_sales) OVER (Partition by product_name ORDER BY order_year)) < 0 THEN 'Decrease'
    ELSE 'No Change' 
  END as py_change
  FROM yearly_current_sales
  ORDER BY product_name, order_year; 
