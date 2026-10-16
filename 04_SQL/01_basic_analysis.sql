-- Total orders
USE smart_demand_intelligence;

SELECT 
    COUNT(*) AS total_orders
FROM orders;


-- Orders by status
SELECT
    order_status,
    COUNT(*) AS order_count
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;


-- Total customers
SELECT
    COUNT(*) AS total_customers
FROM customers;


-- Unique customers
SELECT
    COUNT(*) AS total_customers
FROM customers;


-- Total product
SELECT
    COUNT(*) AS total_products
FROM products;


-- Total sellers
SELECT
    COUNT(*) AS total_products
FROM products;

-- Total revenue
SELECT
    ROUND(SUM(price), 2) AS total_revenue
FROM order_items;


-- Total freight
SELECT
    ROUND(SUM(freight_value), 2) AS total_freight
FROM order_items;


-- Total product units sold
SELECT
    COUNT(*) AS total_items_sold
FROM order_items;


-- Average Order Value
SELECT
    ROUND(AVG(order_revenue), 2) AS average_order_value
FROM (
    SELECT
        order_id,
        SUM(price) AS order_revenue
    FROM order_items
    GROUP BY order_id
) AS order_totals;


-- Revenue by year
SELECT
    YEAR(o.order_purchase_timestamp) AS purchase_year,
    ROUND(SUM(oi.price), 2) AS revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY YEAR(o.order_purchase_timestamp)
ORDER BY purchase_year;


-- monthly revenue
SELECT
    YEAR(o.order_purchase_timestamp) AS purchase_year,
    MONTH(o.order_purchase_timestamp) AS purchase_month,
    ROUND(SUM(oi.price), 2) AS revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY
    YEAR(o.order_purchase_timestamp),
    MONTH(o.order_purchase_timestamp)
ORDER BY
    purchase_year,
    purchase_month;
    

-- Orders by customer state
SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_state
ORDER BY total_orders DESC;


-- Payment method distribution
SELECT
    payment_type,
    COUNT(*) AS payment_count,
    ROUND(SUM(payment_value), 2) AS payment_value
FROM payments
GROUP BY payment_type
ORDER BY payment_value DESC;


-- Avg review 
SELECT
    ROUND(AVG(review_score), 2) AS average_review_score
FROM reviews;