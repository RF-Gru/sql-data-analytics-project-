/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - lifespan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)
       - average monthly revenue
===============================================================================
*/
-- =============================================================================
-- Create Report: gold.report_products
-- =============================================================================
CREATE VIEW gold.report_products AS

WITH base_query AS (
/*---------------------------------------------------------------------------
1) Base Query: Retrieves core columns from fact_sales and dim_products
---------------------------------------------------------------------------*/
  SELECT 
		f.customer_key,
		f.order_number,
		f.order_date,
		f.sales_amount,
		f.quantity,
        p.product_key,
		p.category,
		p.subcategory,
        p.product_name,
		p.cost
	FROM fact_sales AS f
	JOIN dim_products AS p ON f.product_key = p.product_key
    WHERE order_date IS NOT NULL  -- only consider valid sales dates
),

product_aggregate AS (
/*---------------------------------------------------------------------------
2) Product Aggregations: Summarizes key metrics at the product level. 
---------------------------------------------------------------------------*/
SELECT 
		
		product_key,
		category,
		subcategory,
    product_name,
		cost,
    MAX(order_date) AS last_sale_date,
    SUM(sales_amount) AS total_sales,
		COUNT(DISTINCT order_number) AS total_orders,
		SUM(quantity) AS total_quantity,
    ROUND(AVG(sales_amount) / NULLIF (quantity,0)) AS avg_sell_price,
		COUNT(DISTINCT customer_key) AS total_cust,
		TIMESTAMPDIFF(Month, MIN(order_date), MAX(order_date)) AS lifespan,
		TIMESTAMPDIFF(month, MAX(order_date), CURRENT_DATE()) AS recency_months      
	FROM base_query 
  GROUP BY
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    quantity
)

/*---------------------------------------------------------------------------
  3) Final Query: Combines all product results into one output
---------------------------------------------------------------------------*/
SELECT 
	product_key,
	product_name,
	category,
	subcategory,
	cost,
  last_sale_date,
  total_sales,
	total_orders,
	total_quantity,
  avg_sell_price,
	total_cust,
	lifespan,
	recency_months,
	CASE
		WHEN total_sales > 50000 THEN 'High-Performer'
		WHEN total_sales >= 10000 THEN 'Mid-Range'
		ELSE 'Low-Performer'
	END AS product_segment,
  
	-- Average Monthly/Order Revenue (AOR)
	CASE 
		WHEN total_orders = 0 THEN 0
		ELSE total_sales / total_orders
	END AS avg_order_revenue
FROM product_aggregate
