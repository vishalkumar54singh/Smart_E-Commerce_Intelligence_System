/*We need to create a clean Power BI-ready dataset layer.
Do not directly import every raw/clean CSV into Power BI.
Instead, Power BI should primarily consume the analytical tables we already created.*/

-- Monthly demand view
USE smart_demand_intelligence;

CREATE OR REPLACE VIEW vw_monthly_demand AS
SELECT
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m-01') AS month,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(SUM(order_revenue), 2) AS revenue
FROM (
    SELECT
        o.order_id,
        o.order_purchase_timestamp,
        SUM(oi.price) AS order_revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        o.order_id,
        o.order_purchase_timestamp
) AS order_level
GROUP BY
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m-01')
ORDER BY
    month;
    
    
-- State performance view
CREATE OR REPLACE VIEW vw_state_performance AS
SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS orders,
    COUNT(DISTINCT c.customer_unique_id) AS customers,
    ROUND(SUM(oi.price), 2) AS revenue,
    ROUND(
        SUM(oi.price) /
        COUNT(DISTINCT o.order_id),
        2
    ) AS revenue_per_order
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY
    c.customer_state;
    
    
-- Category performance view
CREATE OR REPLACE VIEW vw_category_performance AS
SELECT
    COALESCE(
        ct.product_category_name_english,
        p.product_category_name,
        'Unknown'
    ) AS category,
    ROUND(SUM(oi.price), 2) AS revenue,
    ROUND(SUM(oi.freight_value), 2) AS freight,
    COUNT(*) AS units_sold,
    COUNT(DISTINCT oi.order_id) AS unique_orders,
    COUNT(DISTINCT oi.product_id) AS unique_products,
    ROUND(AVG(oi.price), 2) AS average_selling_price,
    ROUND(
        SUM(oi.freight_value) /
        NULLIF(SUM(oi.price), 0) * 100,
        2
    ) AS freight_to_revenue_percent
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation ct
    ON p.product_category_name =
       ct.product_category_name
GROUP BY
    COALESCE(
        ct.product_category_name_english,
        p.product_category_name,
        'Unknown'
    );
    
    
-- Payment performance view
CREATE OR REPLACE VIEW vw_payment_performance AS
SELECT
    payment_type,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(SUM(payment_value), 2) AS payment_value,
    ROUND(AVG(payment_value), 2) AS average_payment_value
FROM payments
GROUP BY
    payment_type;


-- Delivery performance view
CREATE OR REPLACE VIEW vw_delivery_performance AS
SELECT
    CASE
        WHEN DATE(order_delivered_customer_date)
             < DATE(order_estimated_delivery_date)
            THEN 'Early'

        WHEN DATE(order_delivered_customer_date)
             = DATE(order_estimated_delivery_date)
            THEN 'On Time'

        WHEN DATE(order_delivered_customer_date)
             > DATE(order_estimated_delivery_date)
            THEN 'Delayed'
    END AS sla_status,

    COUNT(DISTINCT order_id) AS orders,

    ROUND(
        AVG(
            DATEDIFF(
                DATE(order_delivered_customer_date),
                DATE(order_purchase_timestamp)
            )
        ),
        2
    ) AS average_delivery_days

FROM orders

WHERE
    order_delivered_customer_date IS NOT NULL
    AND order_estimated_delivery_date IS NOT NULL

GROUP BY(
    CASE
        WHEN DATE(order_delivered_customer_date)
             < DATE(order_estimated_delivery_date)
            THEN 'Early'

        WHEN DATE(order_delivered_customer_date)
             = DATE(order_estimated_delivery_date)
            THEN 'On Time'

        WHEN DATE(order_delivered_customer_date)
             > DATE(order_estimated_delivery_date)
            THEN 'Delayed'
    END);
    

-- Review performance view
CREATE OR REPLACE VIEW vw_review_performance AS
SELECT
    review_score,
    COUNT(*) AS review_count,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS review_percentage
FROM reviews
GROUP BY
    review_score
ORDER BY
    review_score;
    
    
-- Executive KPI view
CREATE OR REPLACE VIEW vw_executive_kpis AS
SELECT
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT c.customer_unique_id) AS total_customers,
    COUNT(DISTINCT oi.product_id) AS total_products,
    COUNT(DISTINCT oi.seller_id) AS total_sellers,

    ROUND(SUM(oi.price), 2) AS total_revenue,
    ROUND(SUM(oi.freight_value), 2) AS total_freight,

    ROUND(
        SUM(oi.price) / COUNT(DISTINCT o.order_id),
        2
    ) AS average_order_value,

    (
        SELECT ROUND(AVG(review_score), 2)
        FROM reviews
    ) AS average_review_score

FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id;
    
    
-- Order status KPI view
CREATE OR REPLACE VIEW vw_order_status AS
SELECT
    order_status,
    COUNT(*) AS orders,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM orders
GROUP BY
    order_status;
    
    
-- Seller performance view
CREATE OR REPLACE VIEW vw_seller_performance AS
SELECT
    s.seller_id,
    s.seller_state,

    COUNT(DISTINCT oi.order_id) AS orders,

    COUNT(oi.order_item_id) AS units_sold,

    ROUND(SUM(oi.price), 2) AS revenue,

    ROUND(SUM(oi.freight_value), 2) AS freight,

    ROUND(
        SUM(oi.price) /
        NULLIF(COUNT(DISTINCT oi.order_id), 0),
        2
    ) AS revenue_per_order

FROM sellers s

JOIN order_items oi
    ON s.seller_id = oi.seller_id

GROUP BY
    s.seller_id,
    s.seller_state;
    
    
-- Daily demand view
CREATE OR REPLACE VIEW vw_daily_demand AS
SELECT
    DATE(order_purchase_timestamp) AS order_date,

    COUNT(DISTINCT order_id) AS orders,

    ROUND(
        SUM(order_revenue),
        2
    ) AS revenue

FROM (
    SELECT
        o.order_id,
        o.order_purchase_timestamp,
        SUM(oi.price) AS order_revenue

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    GROUP BY
        o.order_id,
        o.order_purchase_timestamp
) AS order_level

GROUP BY
    DATE(order_purchase_timestamp)

ORDER BY
    order_date;
    
    
-- Customer KPI view
CREATE OR REPLACE VIEW vw_customer_kpis AS
SELECT
    COUNT(*) AS total_customers,

    SUM(
        CASE
            WHEN order_count > 1 THEN 1
            ELSE 0
        END
    ) AS repeat_customers,

    ROUND(
        SUM(
            CASE
                WHEN order_count > 1 THEN 1
                ELSE 0
            END
        ) * 100.0 /
        COUNT(*),
        2
    ) AS repeat_customer_rate,

    ROUND(
        AVG(customer_revenue),
        2
    ) AS average_customer_revenue,

    ROUND(
        AVG(order_count),
        2
    ) AS average_orders_per_customer

FROM (
    SELECT
        c.customer_unique_id,

        COUNT(DISTINCT o.order_id) AS order_count,

        ROUND(
            SUM(oi.price),
            2
        ) AS customer_revenue

    FROM customers c

    JOIN orders o
        ON c.customer_id = o.customer_id

    JOIN order_items oi
        ON o.order_id = oi.order_id

    GROUP BY
        c.customer_unique_id
) AS customer_summary;


-- day_of_week_demand
CREATE OR REPLACE VIEW vw_day_of_week_demand AS
SELECT
    DAYOFWEEK(order_purchase_timestamp) AS day_number,

    DAYNAME(order_purchase_timestamp) AS day_name,

    COUNT(DISTINCT order_id) AS orders

FROM orders

GROUP BY
    DAYOFWEEK(order_purchase_timestamp),
    DAYNAME(order_purchase_timestamp)

ORDER BY
    day_number;
    
    
-- vw_hourly_demand
CREATE OR REPLACE VIEW vw_hourly_demand AS
SELECT
    HOUR(order_purchase_timestamp) AS purchase_hour,
    COUNT(DISTINCT order_id) AS orders

FROM orders

GROUP BY
    HOUR(order_purchase_timestamp)

ORDER BY
    purchase_hour;
    
    
-- vw_customer_segments
USE smart_demand_intelligence;

CREATE OR REPLACE VIEW vw_customer_segments AS

WITH customer_base AS (
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

    GROUP BY c.customer_unique_id
),

reference_date AS (
    SELECT
        MAX(order_purchase_timestamp) AS max_purchase_date
    FROM orders
),

rfm_base AS (
    SELECT
        cb.customer_unique_id,

        DATEDIFF(
            DATE(rd.max_purchase_date),
            DATE(cb.last_purchase_date)
        ) AS recency_days,

        cb.frequency,
        cb.monetary_value

    FROM customer_base cb

    CROSS JOIN reference_date rd
),

rfm_scores AS (
    SELECT
        *,

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
)

SELECT
    customer_unique_id,
    recency_days,
    frequency,
    monetary_value,

    recency_score,
    frequency_score,
    monetary_score,

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

FROM rfm_scores;


SELECT
    customer_segment,
    COUNT(*) AS customers,
    ROUND(AVG(monetary_value), 2) AS average_customer_value,
    ROUND(AVG(frequency), 2) AS average_orders,
    ROUND(AVG(recency_days), 2) AS average_recency
FROM vw_customer_segments
GROUP BY customer_segment
ORDER BY customers DESC;


-- vw_state_operations
CREATE OR REPLACE VIEW vw_state_operations AS
SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,

    COUNT(
        DISTINCT CASE
            WHEN o.order_delivered_customer_date IS NOT NULL
             AND o.order_estimated_delivery_date IS NOT NULL
             AND DATE(o.order_delivered_customer_date)
                 > DATE(o.order_estimated_delivery_date)
            THEN o.order_id
        END
    ) AS delayed_orders,

    ROUND(
        COUNT(
            DISTINCT CASE
                WHEN o.order_delivered_customer_date IS NOT NULL
                 AND o.order_estimated_delivery_date IS NOT NULL
                 AND DATE(o.order_delivered_customer_date)
                     > DATE(o.order_estimated_delivery_date)
                THEN o.order_id
            END
        ) * 100.0 /
        NULLIF(
            COUNT(
                DISTINCT CASE
                    WHEN o.order_delivered_customer_date IS NOT NULL
                     AND o.order_estimated_delivery_date IS NOT NULL
                    THEN o.order_id
                END
            ),
            0
        ),
        2
    ) AS delay_rate,

    ROUND(
        AVG(
            CASE
                WHEN o.order_delivered_customer_date IS NOT NULL
                 AND o.order_purchase_timestamp IS NOT NULL
                THEN DATEDIFF(
                    DATE(o.order_delivered_customer_date),
                    DATE(o.order_purchase_timestamp)
                )
            END
        ),
        2
    ) AS average_delivery_days

FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id

GROUP BY c.customer_state;

SELECT *
FROM vw_state_operations
ORDER BY delay_rate DESC;


use smart_demand_intelligence;
SHOW FULL TABLES
WHERE TABLE_TYPE = 'VIEW';

SELECT *
FROM vw_executive_kpis;