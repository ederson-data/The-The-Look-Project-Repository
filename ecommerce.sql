-- Revenue per product category

SELECT 
    p.category, 
    SUM(oi.sale_price) AS total_revenue
FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi
JOIN `bigquery-public-data.thelook_ecommerce.products` AS p ON oi.product_id = p.id
WHERE oi.created_at BETWEEN '2025-10-01' AND '2025-12-31'
  AND oi.sale_price > 0 
GROUP BY 1
ORDER BY total_revenue DESC;

-- Top 5 customers by total spend
SELECT 
    u.id, 
    u.first_name, 
    u.last_name, 
    SUM(oi.sale_price) AS total_spent
FROM `bigquery-public-data.thelook_ecommerce.users` AS u
JOIN `bigquery-public-data.thelook_ecommerce.order_items` AS oi ON u.id = oi.user_id
WHERE oi.sale_price > 0
GROUP BY 1, 2, 3
ORDER BY total_spent DESC
LIMIT 5;

-- Monthly sales trend over the past year (2025)
SELECT 
    FORMAT_DATE('%Y-%m', created_at) AS month,
    SUM(sale_price) AS monthly_revenue
FROM `bigquery-public-data.thelook_ecommerce.order_items`
WHERE created_at BETWEEN '2025-01-01' AND '2025-12-31'
GROUP BY 1
ORDER BY 1 ASC;

-- Countries with highest average order value
SELECT 
    u.country, 
    AVG(oi.sale_price) AS average_order_value
FROM `bigquery-public-data.thelook_ecommerce.users` AS u
JOIN `bigquery-public-data.thelook_ecommerce.order_items` AS oi ON u.id = oi.user_id
GROUP BY 1
ORDER BY average_order_value DESC;


-- Count of orders missing product categories
SELECT 
    COUNT(*) AS missing_category_count
FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi
LEFT JOIN `bigquery-public-data.thelook_ecommerce.products` AS p ON oi.product_id = p.id
WHERE p.category IS NULL;

-- Products that have never been sold
SELECT 
    p.id, 
    p.name, 
    p.category
FROM `bigquery-public-data.thelook_ecommerce.products` AS p
LEFT JOIN `bigquery-public-data.thelook_ecommerce.order_items` AS oi ON p.id = oi.product_id
WHERE oi.product_id IS NULL;


-- Percentage of customers with > 3 purchases in last 12 months
WITH customer_orders AS (
  SELECT user_id, COUNT(DISTINCT order_id) AS order_count
  FROM `bigquery-public-data.thelook_ecommerce.orders`
  WHERE created_at >= '2025-01-28' -- Adjust to 1 year ago from current date
  GROUP BY 1
)
SELECT 
  (COUNTIF(order_count > 3) / COUNT(*)) * 100 AS percent_loyal_customers
FROM customer_orders;

-- Average delivery time (Order to Shipment)
SELECT 
    AVG(TIMESTAMP_DIFF(shipped_at, created_at, DAY)) AS avg_delivery_days
FROM `bigquery-public-data.thelook_ecommerce.orders`
WHERE status = 'Shipped' OR status = 'Complete';


-- Q9: Marketing channels bringing high-value customers
SELECT 
    e.traffic_source, 
    SUM(oi.sale_price) AS total_revenue
FROM `bigquery-public-data.thelook_ecommerce.events` AS e
JOIN `bigquery-public-data.thelook_ecommerce.order_items` AS oi 
    ON e.user_id = oi.user_id
WHERE oi.sale_price > 0
GROUP BY 1
ORDER BY total_revenue DESC;


-- Traffic sources for orders over $500
SELECT 
    DISTINCT e.traffic_source, 
    oi.order_id, 
    oi.sale_price
FROM `bigquery-public-data.thelook_ecommerce.events` AS e
JOIN `bigquery-public-data.thelook_ecommerce.order_items` AS oi 
    ON e.user_id = oi.user_id
WHERE oi.sale_price > 500;