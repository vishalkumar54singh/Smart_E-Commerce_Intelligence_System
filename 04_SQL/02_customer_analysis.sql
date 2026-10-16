-- Orders per customer
USE smart_demand_intelligence;

SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id
ORDER BY total_orders DESC;


-- New vs repeat customers
SELECT
    customer_order_count,
    COUNT(*) AS customer_count
FROM (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS customer_order_count
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
) AS customer_orders
GROUP BY customer_order_count
ORDER BY customer_order_count;


-- Repeat customer rate
SELECT
    ROUND(
        100.0 * SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS repeat_customer_rate_percent
FROM (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
) AS customer_orders;


-- Customer revenue
SELECT
    c.customer_unique_id,
    ROUND(SUM(oi.price), 2) AS customer_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_unique_id
ORDER BY customer_revenue DESC;


-- Top 20 customer by revenue
SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS customer_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_unique_id
ORDER BY customer_revenue DESC
LIMIT 20;


-- Avg customer revenue
SELECT
    ROUND(AVG(customer_revenue), 2) AS average_customer_revenue
FROM (
    SELECT
        c.customer_unique_id,
        SUM(oi.price) AS customer_revenue
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id
) AS customer_value;


-- Customer order frequency
SELECT
    ROUND(AVG(total_orders), 2) AS average_orders_per_customer
FROM (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
) AS customer_frequency;


-- First order date
SELECT
    c.customer_unique_id,
    MIN(o.order_purchase_timestamp) AS first_purchase_date
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id;


-- Last order date
SELECT
    c.customer_unique_id,
    MAX(o.order_purchase_timestamp) AS last_purchase_date
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id;


-- Customer lifetime span
SELECT
    customer_unique_id,
    DATEDIFF(
        DATE(last_purchase_date),
        DATE(first_purchase_date)
    ) AS customer_lifetime_days
FROM (
    SELECT
        c.customer_unique_id,
        MIN(o.order_purchase_timestamp) AS first_purchase_date,
        MAX(o.order_purchase_timestamp) AS last_purchase_date
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
) AS customer_dates
ORDER BY customer_lifetime_days DESC;


/*RFM preparation
  R — Recency: How recently did the customer purchase?
  F — Frequency: How often did the customer purchase?
  M — Monetary: How much did the customer spend?*/
  
SELECT
    c.customer_unique_id,
    MAX(o.order_purchase_timestamp) AS last_purchase_date,
    COUNT(DISTINCT o.order_id) AS frequency,
    ROUND(SUM(oi.price), 2) AS monetary_value
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_unique_id;


-- Calculate recency
SELECT
    customer_unique_id,
    DATEDIFF(
        reference_date,
        DATE(last_purchase_date)
    ) AS recency_days,
    frequency,
    monetary_value
FROM (
    SELECT
        c.customer_unique_id,
        MAX(o.order_purchase_timestamp) AS last_purchase_date,
        COUNT(DISTINCT o.order_id) AS frequency,
        ROUND(SUM(oi.price), 2) AS monetary_value,
        (
            SELECT MAX(order_purchase_timestamp)
            FROM orders
        ) AS reference_date
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id
) AS rfm_base;


-- RFM score
WITH rfm_base AS (
    SELECT
        c.customer_unique_id,

        DATEDIFF(
            (SELECT MAX(order_purchase_timestamp) FROM orders),
            MAX(DATE(o.order_purchase_timestamp))
        ) AS recency_days,

        COUNT(DISTINCT o.order_id) AS frequency,

        SUM(oi.price) AS monetary_value

    FROM customers c

    JOIN orders o
        ON c.customer_id = o.customer_id

    JOIN order_items oi
        ON o.order_id = oi.order_id

    GROUP BY c.customer_unique_id
),

rfm_scores AS (
    SELECT
        customer_unique_id,
        recency_days,
        frequency,
        monetary_value,

        NTILE(5) OVER (
            ORDER BY recency_days DESC, customer_unique_id ASC
        ) AS recency_score,

        NTILE(5) OVER (
            ORDER BY frequency ASC, customer_unique_id ASC
        ) AS frequency_score,

        NTILE(5) OVER (
            ORDER BY monetary_value ASC, customer_unique_id ASC
        ) AS monetary_score

    FROM rfm_base
),

segmented_customers AS (
    SELECT
        *,
        CASE
            WHEN recency_score >= 4
                 AND frequency_score >= 4
                 AND monetary_score >= 4
                THEN 'Champions'

            WHEN recency_score >= 3
                 AND frequency_score >= 4
                THEN 'Loyal Customers'

            WHEN recency_score >= 4
                 AND frequency_score BETWEEN 2 AND 3
                THEN 'Potential Loyalists'

            WHEN recency_score <= 2
                 AND frequency_score >= 3
                THEN 'At Risk'

            WHEN recency_score <= 2
                 AND frequency_score <= 2
                THEN 'Lost Customers'

            ELSE 'Other'
        END AS customer_segment

    FROM rfm_scores
)

SELECT
    customer_segment,
    COUNT(*) AS customer_count,
    ROUND(AVG(monetary_value), 2) AS avg_customer_value,
    ROUND(AVG(frequency), 2) AS avg_orders,
    ROUND(AVG(recency_days), 2) AS avg_recency_days

FROM segmented_customers

GROUP BY customer_segment

ORDER BY customer_count DESC;