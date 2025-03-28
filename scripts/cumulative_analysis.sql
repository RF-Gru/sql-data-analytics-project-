/*
===============================================================================
Cumulative Analysis
===============================================================================
Purpose:
    - To calculate running totals or moving averages for key metrics.
    - To track performance over time cumulatively.
    - Useful for growth analysis or identifying long-term trends.

SQL Functions Used:
    - Window Functions: SUM() OVER(), AVG() OVER()
===============================================================================
*/

-- Calculate the total sales per month 
-- and the running total of sales over time
With sales_summary AS (
  SELECT 
		DATE_FORMAT(order_date, '%Y-%m-01') as order_month,
		SUM(sales_amount) as total_sales,
        AVG(price) as running_avg
        
	FROM fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY order_month)
    -- ORDER BY DATE_FORMAT(order_date, '%Y-%m-01')) 
    
SELECT 
		order_month,
    total_sales,
    SUM(total_sales) OVER (ORDER BY order_month) AS running_total, -- cumulative values where the running total doesnt spill over the next year
		running_avg 
FROM sales_summary
;


-- Running total by year
SELECT 
  total_sales, 
  date, 
  SUM(total_sales) OVER (ORDER BY date) as running_total
FROM
	(SELECT SUM(sales_amount) as total_sales, YEAR(order_date) as date
	FROM fact_sales
	WHERE YEAR(order_date) IN (2010, 2011, 2012, 2013, 2014)
	GROUP BY YEAR(order_date)
	ORDER BY YEAR(order_date)
) as sales_summary
; 


-- Running total by month
SELECT 
	  total_sales, 
    month_date, 
    SUM(total_sales) OVER (ORDER BY month_date) as running_total
FROM
	(SELECT SUM(sales_amount) as total_sales, MONTH(order_date) as month_date
	FROM fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY MONTH(order_date)
	ORDER BY MONTH(order_date)
) as sales_summary
  ; 
