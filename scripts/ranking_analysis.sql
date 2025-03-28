/*
===============================================================================
Ranking Analysis
===============================================================================
Purpose:
    - To rank items (e.g., products, customers) based on performance or other metrics.
    - To identify top performers or laggards.

MySQL Functions Used:
    - Window Ranking Functions: ROW_NUMBER(), LIMIT
    - Clauses: GROUP BY, ORDER BY
===============================================================================
*/

-- Which 5 products Generating the Highest Revenue?
-- Simple Ranking
SELECT
 p.product_name, 
 SUM(sales_amount) AS total_revenue 
 FROM gold.fact_sales s 
 LEFT JOIN gold.dim_products p 
 ON s.product_key = p.product_key 
 GROUP BY product_name 
 ORDER BY total_revenue DESC
 LIMIT 5
;

-- Complex but Flexibly Ranking Using Window Functions
SELECT *
FROM
	(SELECT
	p.product_name, 
	SUM(sales_amount) AS total_revenue,
	ROW_NUMBER() OVER (ORDER BY  SUM(sales_amount) DESC) AS rank_products
	FROM gold.fact_sales s 
	LEFT JOIN gold.dim_products p 
	ON s.product_key = p.product_key 
	GROUP BY product_name) t
 WHERE rank_products <= 5
;

-- What are the 5 worst-performing products in terms of sales?
SELECT 
 p.product_name, 
 SUM(sales_amount) AS total_revenue 
 FROM gold.fact_sales s 
 LEFT JOIN gold.dim_products p 
 ON s.product_key = p.product_key 
 GROUP BY product_name 
 ORDER BY total_revenue ASC
 LIMIT 5
;

-- Find the top 10 customers who have generated the highest revenue
SELECT
    c.customer_key,
    c.first_name,
    c.last_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
GROUP BY 
    c.customer_key,
    c.first_name,
    c.last_name
ORDER BY total_revenue DESC
LIMIT 10
;

-- The 3 customers with the fewest orders placed
SELECT
    c.customer_key,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
GROUP BY 
    c.customer_key,
    c.first_name,
    c.last_name
ORDER BY total_orders
LIMIT 3
;
