-- Average delivery time
USE smart_demand_intelligence;
SELECT
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
WHERE order_delivered_customer_date IS NOT NULL;


-- Delivery time distribution
SELECT
    CASE
        WHEN delivery_days <= 3 THEN '0-3 days'
        WHEN delivery_days BETWEEN 4 AND 7 THEN '4-7 days'
        WHEN delivery_days BETWEEN 8 AND 14 THEN '8-14 days'
        WHEN delivery_days BETWEEN 15 AND 30 THEN '15-30 days'
        ELSE '30+ days'
    END AS delivery_band,
    COUNT(*) AS order_count
FROM (
    SELECT
        order_id,
        DATEDIFF(
            DATE(order_delivered_customer_date),
            DATE(order_purchase_timestamp)
        ) AS delivery_days
    FROM orders
    WHERE order_delivered_customer_date IS NOT NULL
) AS delivery_data
GROUP BY
    CASE
        WHEN delivery_days <= 3 THEN '0-3 days'
        WHEN delivery_days BETWEEN 4 AND 7 THEN '4-7 days'
        WHEN delivery_days BETWEEN 8 AND 14 THEN '8-14 days'
        WHEN delivery_days BETWEEN 15 AND 30 THEN '15-30 days'
        ELSE '30+ days'
    END ORDER BY MIN(delivery_days);


-- SLA performance
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

    END AS delivery_status,

    COUNT(*) AS order_count

FROM orders

WHERE order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL

GROUP BY
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

    END ORDER BY order_count DESC;
    

-- delivery delay rate
SELECT
    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN DATE(order_delivered_customer_date)
                     > DATE(order_estimated_delivery_date)
                THEN 1
                ELSE 0
            END
        )
        / COUNT(*),
        2
    ) AS delivery_delay_rate_percent

FROM orders

WHERE order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL;
  
  
-- Avg delivery delay
SELECT
    ROUND(
        AVG(
            DATEDIFF(
                DATE(order_delivered_customer_date),
                DATE(order_estimated_delivery_date)
            )
        ),
        2
    ) AS average_delay_days

FROM orders

WHERE order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL
  AND DATE(order_delivered_customer_date)
      > DATE(order_estimated_delivery_date);
      
      
-- Delivery performance by customer state
SELECT
    c.customer_state,

    COUNT(DISTINCT o.order_id) AS delivered_orders,

    ROUND(
        AVG(
            DATEDIFF(
                DATE(o.order_delivered_customer_date),
                DATE(o.order_purchase_timestamp)
            )
        ),
        2
    ) AS avg_delivery_days,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN DATE(o.order_delivered_customer_date)
                     > DATE(o.order_estimated_delivery_date)
                THEN 1
                ELSE 0
            END
        )
        / COUNT(*),
        2
    ) AS delay_rate_percent

FROM orders o

JOIN customers c
    ON o.customer_id = c.customer_id

WHERE o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL

GROUP BY c.customer_state

ORDER BY delay_rate_percent DESC;


-- State with highest avg delivery time
SELECT
    c.customer_state,

    COUNT(DISTINCT o.order_id) AS delivered_orders,

    ROUND(
        AVG(
            DATEDIFF(
                DATE(o.order_delivered_customer_date),
                DATE(o.order_purchase_timestamp)
            )
        ),
        2
    ) AS avg_delivery_days

FROM orders o

JOIN customers c
    ON o.customer_id = c.customer_id

WHERE o.order_delivered_customer_date IS NOT NULL

GROUP BY c.customer_state

HAVING COUNT(DISTINCT o.order_id) >= 100

ORDER BY avg_delivery_days DESC;


-- Seller delivery performance
SELECT
    oi.seller_id,
    s.seller_state,
    COUNT(DISTINCT oi.order_id) AS delivered_orders,

    ROUND(
        AVG(
            DATEDIFF(
                DATE(o.order_delivered_customer_date),
                DATE(o.order_purchase_timestamp)
            )
        ),
        2
    ) AS avg_delivery_days

FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
JOIN sellers s
    ON oi.seller_id = s.seller_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY
    oi.seller_id,
    s.seller_state
HAVING COUNT(DISTINCT oi.order_id) >= 20
ORDER BY avg_delivery_days DESC;


-- Order processing time
SELECT
    ROUND(
        AVG(
            TIMESTAMPDIFF(
                HOUR,
                order_purchase_timestamp,
                order_approved_at
            )
        ),
        2
    ) AS avg_purchase_to_approval_hours

FROM orders
WHERE order_purchase_timestamp IS NOT NULL
  AND order_approved_at IS NOT NULL;
  
  
-- Purchase to carrier handsoff
SELECT
    ROUND(
        AVG(
            TIMESTAMPDIFF(
                HOUR,
                order_purchase_timestamp,
                order_delivered_carrier_date
            )
        ),
        2
    ) AS avg_purchase_to_carrier_hours

FROM orders
WHERE order_purchase_timestamp IS NOT NULL
  AND order_delivered_carrier_date IS NOT NULL;
  
  
-- carrier to customer delivery
SELECT
    ROUND(
        AVG(
            TIMESTAMPDIFF(
                HOUR,
                order_delivered_carrier_date,
                order_delivered_customer_date
            )
        ),
        2
    ) AS avg_carrier_to_customer_hours
FROM orders
WHERE order_delivered_carrier_date IS NOT NULL
  AND order_delivered_customer_date IS NOT NULL;
  

-- Freight vs delivery time
SELECT
    CASE
        WHEN oi.freight_value < 10 THEN 'Under 10'
        WHEN oi.freight_value >= 10 AND oi.freight_value < 25 THEN '10-24'
        WHEN oi.freight_value >= 25 AND oi.freight_value < 50 THEN '25-49'
        WHEN oi.freight_value >= 50 AND oi.freight_value < 100 THEN '50-99'
        ELSE '100+'
    END AS freight_band,

    COUNT(DISTINCT oi.order_id) AS order_count,

    ROUND(
        AVG(
            DATEDIFF(
                DATE(o.order_delivered_customer_date),
                DATE(o.order_purchase_timestamp)
            )
        ),
        2
    ) AS avg_delivery_days,

    ROUND(AVG(oi.freight_value), 2) AS avg_freight

FROM order_items oi

JOIN orders o
    ON oi.order_id = o.order_id

WHERE o.order_delivered_customer_date IS NOT NULL

GROUP BY
    CASE
        WHEN oi.freight_value < 10 THEN 'Under 10'
        WHEN oi.freight_value >= 10 AND oi.freight_value < 25 THEN '10-24'
        WHEN oi.freight_value >= 25 AND oi.freight_value < 50 THEN '25-49'
        WHEN oi.freight_value >= 50 AND oi.freight_value < 100 THEN '50-99'
        ELSE '100+'
    END ORDER BY MIN(oi.freight_value);
    

-- Review score by delivery status
SELECT
    CASE

        WHEN DATE(o.order_delivered_customer_date)
             < DATE(o.order_estimated_delivery_date)
            THEN 'Early'

        WHEN DATE(o.order_delivered_customer_date)
             = DATE(o.order_estimated_delivery_date)
            THEN 'On Time'

        WHEN DATE(o.order_delivered_customer_date)
             > DATE(o.order_estimated_delivery_date)
            THEN 'Delayed'

    END AS delivery_status,

    COUNT(DISTINCT r.review_id) AS review_count,

    ROUND(AVG(r.review_score), 2) AS average_review_score

FROM orders o

JOIN reviews r
    ON o.order_id = r.order_id

WHERE o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL

GROUP BY
    CASE

        WHEN DATE(o.order_delivered_customer_date)
             < DATE(o.order_estimated_delivery_date)
            THEN 'Early'

        WHEN DATE(o.order_delivered_customer_date)
             = DATE(o.order_estimated_delivery_date)
            THEN 'On Time'

        WHEN DATE(o.order_delivered_customer_date)
             > DATE(o.order_estimated_delivery_date)
            THEN 'Delayed'

    END ORDER BY average_review_score DESC;
    
    
-- Overall operation KPIs
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
    ) AS avg_delivery_days,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN DATE(order_delivered_customer_date)
                     > DATE(order_estimated_delivery_date)
                THEN 1
                ELSE 0
            END
        )
        / COUNT(*),
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
    ) AS avg_estimated_delivery_days

FROM orders

WHERE order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL;