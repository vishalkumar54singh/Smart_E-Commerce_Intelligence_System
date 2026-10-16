-- Executive KPI Summary
USE smart_demand_intelligence;

SELECT
    (SELECT COUNT(*)
     FROM orders) AS total_orders,
    (SELECT ROUND(SUM(price), 2)
     FROM order_items) AS total_revenue,
    (SELECT ROUND(SUM(freight_value), 2)
     FROM order_items) AS total_freight,
    (SELECT COUNT(*)
     FROM customers) AS total_customer_records,
    (SELECT COUNT(DISTINCT customer_unique_id)
     FROM customers) AS unique_customers,
    (SELECT ROUND(AVG(order_revenue), 2)
     FROM (
        SELECT order_id, SUM(price) AS order_revenue
        FROM order_items
        GROUP BY order_id
     ) AS order_totals) AS average_order_value,
    (SELECT ROUND(AVG(review_score), 2)
     FROM reviews) AS average_review_score;
     
	
-- Cancellaltion rate
SELECT
    COUNT(*) AS total_orders,

    SUM(
        CASE
            WHEN order_status = 'canceled' THEN 1
            ELSE 0
        END
    ) AS canceled_orders,

    ROUND(
        SUM(
            CASE
                WHEN order_status = 'canceled' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS cancellation_rate_percent

FROM orders;


-- Repeat customer rate
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
        ) * 100.0 / COUNT(*),
        2
    ) AS repeat_customer_rate_percent

FROM (
    SELECT
        customer_unique_id,
        COUNT(*) AS order_count
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY customer_unique_id
) AS customer_orders;


-- Revenue by year
SELECT
    YEAR(o.order_purchase_timestamp) AS purchase_year,
    ROUND(SUM(oi.price), 2) AS revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY YEAR(o.order_purchase_timestamp)
ORDER BY purchase_year;


-- Year-over-Year Revenue Growth
WITH yearly_revenue AS (
    SELECT
        YEAR(o.order_purchase_timestamp) AS purchase_year,
        SUM(oi.price) AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY YEAR(o.order_purchase_timestamp)
)

SELECT
    purchase_year,
    ROUND(revenue, 2) AS revenue,

    ROUND(
        (
            revenue
            - LAG(revenue) OVER (ORDER BY purchase_year)
        )
        * 100.0
        / NULLIF(
            LAG(revenue) OVER (ORDER BY purchase_year),
            0
        ),
        2
    ) AS yoy_growth_percent

FROM yearly_revenue
ORDER BY purchase_year;


-- Monthly business performance
SELECT
    DATE_FORMAT(
        o.order_purchase_timestamp,
        '%Y-%m'
    ) AS purchase_month,

    COUNT(DISTINCT o.order_id) AS orders,

    ROUND(SUM(oi.price), 2) AS revenue,

    ROUND(SUM(oi.freight_value), 2) AS freight,

    ROUND(
        SUM(oi.price + oi.freight_value),
        2
    ) AS total_order_value

FROM orders o

JOIN order_items oi
    ON o.order_id = oi.order_id

GROUP BY
    DATE_FORMAT(
        o.order_purchase_timestamp,
        '%Y-%m'
    )

ORDER BY purchase_month;


-- Monthly order growth
WITH monthly_orders AS (
    SELECT
        DATE_FORMAT(
            order_purchase_timestamp,
            '%Y-%m'
        ) AS purchase_month,

        COUNT(*) AS order_count

    FROM orders

    GROUP BY
        DATE_FORMAT(
            order_purchase_timestamp,
            '%Y-%m'
        )
)

SELECT
    purchase_month,
    order_count,

    ROUND(
        (
            order_count
            - LAG(order_count) OVER (
                ORDER BY purchase_month
            )
        ) * 100.0
        /
        NULLIF(
            LAG(order_count) OVER (
                ORDER BY purchase_month
            ),
            0
        ),
        2
    ) AS mon_growth_percent

FROM monthly_orders
ORDER BY purchase_month;


-- Revenue per customer
SELECT
    COUNT(DISTINCT c.customer_unique_id) AS unique_customers,

    ROUND(
        SUM(oi.price)
        /
        COUNT(DISTINCT c.customer_unique_id),
        2
    ) AS revenue_per_customer

FROM orders o

JOIN customers c
    ON o.customer_id = c.customer_id

JOIN order_items oi
    ON o.order_id = oi.order_id;
    
    
-- Avg review score by order state
SELECT
    o.order_status,

    COUNT(DISTINCT o.order_id) AS orders,

    ROUND(
        AVG(r.review_score),
        2
    ) AS average_review_score

FROM orders o

LEFT JOIN reviews r
    ON o.order_id = r.order_id

GROUP BY o.order_status

ORDER BY orders DESC;


-- Delivery KPI
SELECT
    COUNT(*) AS delivered_orders,
    ROUND(
        AVG(
            DATEDIFF(
                DATE(order_delivered_customer_date),
                DATE(order_purchase_timestamp)
            )
        ),
        2
    ) AS average_delivery_days,

    ROUND(
        AVG(
            CASE
                WHEN DATE(order_delivered_customer_date)
                     > DATE(order_estimated_delivery_date)
                THEN 1
                ELSE 0
            END
        ) * 100,
        2
    ) AS delay_rate_percent,

    ROUND(
        AVG(
            DATEDIFF(
                DATE(order_estimated_delivery_date),
                DATE(order_purchase_timestamp)
            )
        ),
        2
    ) AS average_estimated_delivery_days
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;


-- Revenue by customer state
SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS orders,
    COUNT(DISTINCT c.customer_unique_id) AS customers,
    ROUND(SUM(oi.price), 2) AS revenue,
    ROUND(
        SUM(oi.price)
        /
        COUNT(DISTINCT o.order_id),
        2
    ) AS revenue_per_order
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY revenue DESC;


-- Top revenue categories
SELECT
    COALESCE(
        ct.product_category_name_english,
        p.product_category_name,
        'Unknown'
    ) AS category,
    ROUND(SUM(oi.price), 2) AS revenue,
    COUNT(DISTINCT oi.order_id) AS orders,
    COUNT(*) AS units_sold
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
GROUP BY
    COALESCE(
        ct.product_category_name_english,
        p.product_category_name,
        'Unknown'
    )
ORDER BY revenue DESC
LIMIT 10;


-- Business KPI snapshot
SELECT
    ROUND(SUM(oi.price), 2) AS total_revenue,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT c.customer_unique_id) AS unique_customers,
    ROUND(
        SUM(oi.price)
        / COUNT(DISTINCT o.order_id),
        2
    ) AS average_order_value,
    ROUND(
        SUM(oi.freight_value),
        2
    ) AS total_freight,
    ROUND(
        AVG(r.review_score),
        2
    ) AS average_review_score
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
LEFT JOIN reviews r
    ON o.order_id = r.order_id;
    
    
-- Final Operations + Customer KP
SELECT
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT c.customer_unique_id) AS unique_customers,
    ROUND(
        SUM(oi.price),
        2
    ) AS total_revenue,
    ROUND(
        SUM(oi.price)
        /
        COUNT(DISTINCT o.order_id),
        2
    ) AS average_order_value,

    ROUND(
        SUM(oi.freight_value),
        2
    ) AS total_freight,
    ROUND(
        SUM(
            CASE
                WHEN o.order_status = 'canceled'
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(DISTINCT o.order_id),
        2
    ) AS cancellation_rate_percent
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id;
    
    
-- Management KPI summary
SELECT
    total_orders,
    total_revenue,
    total_freight,
    unique_customers,
    average_order_value,
    average_review_score,
    cancellation_rate_percent,
    repeat_customer_rate_percent,
    average_delivery_days,
    delay_rate_percent

FROM
(
    SELECT
        COUNT(*) AS total_orders,

        (
            SELECT ROUND(SUM(price), 2)
            FROM order_items
        ) AS total_revenue,

        (
            SELECT ROUND(SUM(freight_value), 2)
            FROM order_items
        ) AS total_freight,

        (
            SELECT COUNT(DISTINCT customer_unique_id)
            FROM customers
        ) AS unique_customers,

        (
            SELECT ROUND(AVG(order_revenue), 2)
            FROM (
                SELECT order_id, SUM(price) AS order_revenue
                FROM order_items
                GROUP BY order_id
            ) AS order_totals
        ) AS average_order_value,

        (
            SELECT ROUND(AVG(review_score), 2)
            FROM reviews
        ) AS average_review_score,

        (
            SELECT ROUND(
                SUM(
                    CASE
                        WHEN order_status = 'canceled'
                        THEN 1
                        ELSE 0
                    END
                ) * 100.0 / COUNT(*),
                2
            )
            FROM orders
        ) AS cancellation_rate_percent,

        (
            SELECT ROUND(
                SUM(
                    CASE
                        WHEN order_count > 1
                        THEN 1
                        ELSE 0
                    END
                ) * 100.0 / COUNT(*),
                2
            )
            FROM (
                SELECT
                    c.customer_unique_id,
                    COUNT(*) AS order_count
                FROM customers c
                JOIN orders o
                    ON c.customer_id = o.customer_id
                GROUP BY c.customer_unique_id
            ) AS customer_orders
        ) AS repeat_customer_rate_percent,

        (
            SELECT ROUND(
                AVG(
                    DATEDIFF(
                        DATE(order_delivered_customer_date),
                        DATE(order_purchase_timestamp)
                    )
                ),
                2
            )
            FROM orders
            WHERE order_delivered_customer_date IS NOT NULL
        ) AS average_delivery_days,

        (
            SELECT ROUND(
                AVG(
                    CASE
                        WHEN DATE(order_delivered_customer_date)
                             > DATE(order_estimated_delivery_date)
                        THEN 1
                        ELSE 0
                    END
                ) * 100,
                2
            )
            FROM orders
            WHERE order_delivered_customer_date IS NOT NULL
        ) AS delay_rate_percent

    FROM orders
) AS kpi_summary;