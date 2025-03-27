/*
===============================================================================
Date Range Exploration 
===============================================================================
Purpose:
    - To determine the temporal boundaries of key data points.
    - To understand the range of historical data.

MySQL Functions Used:
    - MIN(), MAX(), TIMESTAMPDIFF()
===============================================================================
*/

-- Determine the first and last order date and the total duration in months
SELECT 
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    MAX(order_date) - MIN(order_date) AS order_range_years,
    TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date)) AS exact_months_elapsed -- number of whole months between the two dates
FROM gold.fact_sales;

-- Find the youngest and oldest customer based on birthdate

SELECT 
    MIN(birthdate) AS oldest,
    MAX(birthdate) AS youngest,
    TIMESTAMPDIFF(year, MIN(birthdate), CURRENT_TIMESTAMP) AS oldest_age,
    TIMESTAMPDIFF(year, MAX(birthdate), CURRENT_TIMESTAMP) AS youngest_age
FROM gold.dim_customers2;

