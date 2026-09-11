-- ============================================================
-- OLIST E-COMMERCE SALES & CUSTOMER ANALYTICS
-- Basic Business Analysis
-- PostgreSQL
-- ============================================================

-- ============================================================
-- 1. DATA OVERVIEW
-- ============================================================

-- 1.1 Total customers, orders, products, sellers
SELECT
    (SELECT COUNT(*) FROM customers) AS customers,
    (SELECT COUNT(*) FROM orders) AS orders,
    (SELECT COUNT(*) FROM products) AS products,
    (SELECT COUNT(*) FROM sellers) AS sellers;


-- 1.2 Order status distribution
SELECT
    order_status,
    COUNT(*) AS order_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;


-- 1.3 Order date range
SELECT
    MIN(order_purchase_timestamp) AS first_order,
    MAX(order_purchase_timestamp) AS last_order
FROM orders;


-- ============================================================
-- 2. SALES & REVENUE ANALYSIS
-- ============================================================

-- 2.1 Total product sales revenue
SELECT
    ROUND(SUM(price), 2) AS total_product_revenue
FROM order_items;


-- 2.2 Total freight revenue/cost recorded in order items
SELECT
    ROUND(SUM(freight_value), 2) AS total_freight_value
FROM order_items;


-- 2.3 Product revenue + freight value
SELECT
    ROUND(SUM(price + freight_value), 2) AS total_order_item_value
FROM order_items;


-- 2.4 Average order value based on product prices
SELECT
    ROUND(SUM(price) / COUNT(DISTINCT order_id), 2) AS average_order_value
FROM order_items;


-- 2.5 Monthly revenue
SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp)::date AS month,
    ROUND(SUM(oi.price), 2) AS revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY 1
ORDER BY 1;


-- 2.6 Monthly orders
SELECT
    DATE_TRUNC('month', order_purchase_timestamp)::date AS month,
    COUNT(*) AS total_orders
FROM orders
GROUP BY 1
ORDER BY 1;


-- 2.7 Monthly revenue and orders together
SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp)::date AS month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS revenue,
    ROUND(SUM(oi.price) / COUNT(DISTINCT o.order_id), 2) AS average_order_value
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY 1
ORDER BY 1;


-- ============================================================
-- 3. PRODUCT & CATEGORY ANALYSIS
-- ============================================================

-- 3.1 Revenue by product category
SELECT
    COALESCE(t.product_category_name_english, p.product_category_name, 'Unknown') AS category,
    ROUND(SUM(oi.price), 2) AS revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_translation t
    ON p.product_category_name = t.product_category_name
GROUP BY 1
ORDER BY revenue DESC;


-- 3.2 Top 10 categories by revenue
SELECT
    COALESCE(t.product_category_name_english, p.product_category_name, 'Unknown') AS category,
    ROUND(SUM(oi.price), 2) AS revenue,
    COUNT(DISTINCT oi.order_id) AS orders
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_translation t
    ON p.product_category_name = t.product_category_name
GROUP BY 1
ORDER BY revenue DESC
LIMIT 10;


-- 3.3 Top 10 products by revenue
SELECT
    oi.product_id,
    COALESCE(t.product_category_name_english, p.product_category_name, 'Unknown') AS category,
    ROUND(SUM(oi.price), 2) AS revenue,
    COUNT(*) AS units_sold
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_translation t
    ON p.product_category_name = t.product_category_name
GROUP BY oi.product_id, category
ORDER BY revenue DESC
LIMIT 10;


-- 3.4 Top categories by units sold
SELECT
    COALESCE(t.product_category_name_english, p.product_category_name, 'Unknown') AS category,
    COUNT(*) AS units_sold
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_translation t
    ON p.product_category_name = t.product_category_name
GROUP BY 1
ORDER BY units_sold DESC
LIMIT 10;


-- ============================================================
-- 4. SELLER ANALYSIS
-- ============================================================

-- 4.1 Top 10 sellers by revenue
SELECT
    oi.seller_id,
    s.seller_city,
    s.seller_state,
    ROUND(SUM(oi.price), 2) AS revenue,
    COUNT(DISTINCT oi.order_id) AS orders
FROM order_items oi
JOIN sellers s
    ON oi.seller_id = s.seller_id
GROUP BY oi.seller_id, s.seller_city, s.seller_state
ORDER BY revenue DESC
LIMIT 10;


-- 4.2 Top 10 sellers by order volume
SELECT
    oi.seller_id,
    s.seller_city,
    s.seller_state,
    COUNT(DISTINCT oi.order_id) AS orders,
    ROUND(SUM(oi.price), 2) AS revenue
FROM order_items oi
JOIN sellers s
    ON oi.seller_id = s.seller_id
GROUP BY oi.seller_id, s.seller_city, s.seller_state
ORDER BY orders DESC
LIMIT 10;


-- 4.3 Seller performance by state
SELECT
    s.seller_state,
    COUNT(DISTINCT oi.seller_id) AS sellers,
    COUNT(DISTINCT oi.order_id) AS orders,
    ROUND(SUM(oi.price), 2) AS revenue
FROM sellers s
JOIN order_items oi
    ON s.seller_id = oi.seller_id
GROUP BY s.seller_state
ORDER BY revenue DESC;


-- ============================================================
-- 5. CUSTOMER ANALYSIS
-- ============================================================

-- 5.1 Orders by customer state
SELECT
    c.customer_state,
    COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_state
ORDER BY total_orders DESC;


-- 5.2 Unique customers by state
SELECT
    customer_state,
    COUNT(DISTINCT customer_unique_id) AS unique_customers
FROM customers
GROUP BY customer_state
ORDER BY unique_customers DESC;


-- 5.3 Customer order frequency
SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS order_count
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id
ORDER BY order_count DESC
LIMIT 20;


-- 5.4 Repeat customer rate
WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)
SELECT
    COUNT(*) AS total_unique_customers,
    COUNT(*) FILTER (WHERE order_count > 1) AS repeat_customers,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE order_count > 1) / COUNT(*),
        2
    ) AS repeat_customer_rate
FROM customer_orders;


-- 5.5 Customer revenue
SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(oi.price), 2) AS revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_unique_id
ORDER BY revenue DESC
LIMIT 20;


-- ============================================================
-- 6. PAYMENT ANALYSIS
-- ============================================================

-- 6.1 Payment method usage
SELECT
    payment_type,
    COUNT(*) AS payment_records,
    ROUND(SUM(payment_value), 2) AS payment_value
FROM order_payments
GROUP BY payment_type
ORDER BY payment_value DESC;


-- 6.2 Payment method share
SELECT
    payment_type,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(SUM(payment_value), 2) AS payment_value,
    ROUND(
        100.0 * SUM(payment_value) / SUM(SUM(payment_value)) OVER (),
        2
    ) AS value_share_percent
FROM order_payments
GROUP BY payment_type
ORDER BY payment_value DESC;


-- 6.3 Installment distribution
SELECT
    payment_installments,
    COUNT(*) AS payment_records,
    ROUND(SUM(payment_value), 2) AS payment_value
FROM order_payments
GROUP BY payment_installments
ORDER BY payment_installments;


-- 6.4 Average payment value by payment type
SELECT
    payment_type,
    ROUND(AVG(payment_value), 2) AS average_payment_value
FROM order_payments
GROUP BY payment_type
ORDER BY average_payment_value DESC;


-- ============================================================
-- 7. DELIVERY PERFORMANCE
-- ============================================================

-- 7.1 Delivered orders: average delivery time
SELECT
    ROUND(
        AVG(
            EXTRACT(EPOCH FROM
                (order_delivered_customer_date - order_purchase_timestamp)
            ) / 86400
        ),
        2
    ) AS average_delivery_days
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL;


-- 7.2 On-time vs late deliveries
SELECT
    CASE
        WHEN order_delivered_customer_date <= order_estimated_delivery_date
            THEN 'On Time'
        ELSE 'Late'
    END AS delivery_status,
    COUNT(*) AS orders,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL
GROUP BY 1
ORDER BY orders DESC;


-- 7.3 Average days early/late
SELECT
    ROUND(
        AVG(
            EXTRACT(EPOCH FROM
                (order_delivered_customer_date - order_estimated_delivery_date)
            ) / 86400
        ),
        2
    ) AS average_days_vs_estimate
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL;


-- 7.4 Delivery performance by customer state
SELECT
    c.customer_state,
    COUNT(o.order_id) AS delivered_orders,
    ROUND(
        AVG(
            EXTRACT(EPOCH FROM
                (o.order_delivered_customer_date - o.order_purchase_timestamp)
            ) / 86400
        ),
        2
    ) AS avg_delivery_days,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE o.order_delivered_customer_date <= o.order_estimated_delivery_date
        ) / COUNT(*),
        2
    ) AS on_time_rate
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL
GROUP BY c.customer_state
HAVING COUNT(o.order_id) >= 100
ORDER BY on_time_rate DESC;


-- ============================================================
-- 8. REVIEW ANALYSIS
-- ============================================================

-- 8.1 Review score distribution
SELECT
    review_score,
    COUNT(*) AS review_count,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM order_reviews
GROUP BY review_score
ORDER BY review_score;


-- 8.2 Average review score
SELECT
    ROUND(AVG(review_score), 2) AS average_review_score
FROM order_reviews;


-- 8.3 Review score vs delivery status
SELECT
    CASE
        WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date
            THEN 'On Time'
        ELSE 'Late'
    END AS delivery_status,
    ROUND(AVG(r.review_score), 2) AS average_review_score,
    COUNT(*) AS reviews
FROM orders o
JOIN order_reviews r
    ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL
GROUP BY 1
ORDER BY average_review_score DESC;


-- ============================================================
-- 9. GEOGRAPHIC ANALYSIS
-- ============================================================

-- 9.1 Orders by customer state with revenue
SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(oi.price), 2) AS revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY revenue DESC;


-- 9.2 Seller state revenue
SELECT
    s.seller_state,
    COUNT(DISTINCT s.seller_id) AS sellers,
    ROUND(SUM(oi.price), 2) AS revenue
FROM sellers s
JOIN order_items oi
    ON s.seller_id = oi.seller_id
GROUP BY s.seller_state
ORDER BY revenue DESC;


-- ============================================================
-- 10. BUSINESS KPI SUMMARY
-- ============================================================

SELECT
    (SELECT COUNT(*) FROM orders) AS total_orders,
    (SELECT COUNT(DISTINCT customer_unique_id) FROM customers) AS unique_customers,
    (SELECT ROUND(SUM(price), 2) FROM order_items) AS product_revenue,
    (SELECT ROUND(SUM(freight_value), 2) FROM order_items) AS freight_value,
    (SELECT ROUND(AVG(review_score), 2) FROM order_reviews) AS avg_review_score,
    (SELECT COUNT(*) FROM orders WHERE order_status = 'delivered') AS delivered_orders;
