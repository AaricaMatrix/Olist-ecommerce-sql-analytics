-- ============================================================
-- OLIST E-COMMERCE SALES & CUSTOMER ANALYTICS
-- Advanced SQL Analysis
-- PostgreSQL
-- ============================================================

-- ============================================================
-- 1. CTE: MONTHLY REVENUE WITH GROWTH
-- ============================================================

WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', o.order_purchase_timestamp)::date AS month,
        SUM(oi.price) AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY 1
),
monthly_growth AS (
    SELECT
        month,
        revenue,
        LAG(revenue) OVER (ORDER BY month) AS previous_month_revenue
    FROM monthly_revenue
)
SELECT
    month,
    ROUND(revenue, 2) AS revenue,
    ROUND(previous_month_revenue, 2) AS previous_month_revenue,
    ROUND(
        100.0 * (revenue - previous_month_revenue)
        / NULLIF(previous_month_revenue, 0),
        2
    ) AS growth_percent
FROM monthly_growth
ORDER BY month;


-- ============================================================
-- 2. WINDOW FUNCTION: TOP CATEGORY BY MONTH
-- ============================================================

WITH monthly_category_sales AS (
    SELECT
        DATE_TRUNC('month', o.order_purchase_timestamp)::date AS month,
        COALESCE(
            t.product_category_name_english,
            p.product_category_name,
            'Unknown'
        ) AS category,
        SUM(oi.price) AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    JOIN products p
        ON oi.product_id = p.product_id
    LEFT JOIN product_category_translation t
        ON p.product_category_name = t.product_category_name
    WHERE o.order_status = 'delivered'
    GROUP BY 1, 2
),
ranked_categories AS (
    SELECT
        month,
        category,
        revenue,
        RANK() OVER (
            PARTITION BY month
            ORDER BY revenue DESC
        ) AS category_rank
    FROM monthly_category_sales
)
SELECT
    month,
    category,
    ROUND(revenue, 2) AS revenue
FROM ranked_categories
WHERE category_rank = 1
ORDER BY month;


-- ============================================================
-- 3. CUSTOMER SEGMENTATION BY ORDER FREQUENCY
-- ============================================================

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count,
        COALESCE(SUM(oi.price), 0) AS revenue
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    LEFT JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id
)
SELECT
    CASE
        WHEN order_count = 1 THEN 'One-time Customer'
        WHEN order_count BETWEEN 2 AND 3 THEN 'Repeat Customer'
        ELSE 'Loyal Customer'
    END AS customer_segment,
    COUNT(*) AS customers,
    ROUND(SUM(revenue), 2) AS revenue,
    ROUND(AVG(revenue), 2) AS avg_customer_revenue
FROM customer_orders
GROUP BY 1
ORDER BY revenue DESC;


-- ============================================================
-- 4. CUSTOMER RANKING BY REVENUE
-- ============================================================

WITH customer_revenue AS (
    SELECT
        c.customer_unique_id,
        SUM(oi.price) AS revenue
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id
)
SELECT
    customer_unique_id,
    ROUND(revenue, 2) AS revenue,
    DENSE_RANK() OVER (ORDER BY revenue DESC) AS revenue_rank
FROM customer_revenue
ORDER BY revenue_rank
LIMIT 20;


-- ============================================================
-- 5. SELLER RANKING WITH REVENUE SHARE
-- ============================================================

WITH seller_revenue AS (
    SELECT
        seller_id,
        SUM(price) AS revenue
    FROM order_items
    GROUP BY seller_id
)
SELECT
    seller_id,
    ROUND(revenue, 2) AS revenue,
    ROUND(
        100.0 * revenue / SUM(revenue) OVER (),
        2
    ) AS revenue_share_percent,
    DENSE_RANK() OVER (ORDER BY revenue DESC) AS seller_rank
FROM seller_revenue
ORDER BY seller_rank
LIMIT 20;


-- ============================================================
-- 6. PARETO ANALYSIS: SELLERS CONTRIBUTING TO 80% OF REVENUE
-- ============================================================

WITH seller_revenue AS (
    SELECT
        seller_id,
        SUM(price) AS revenue
    FROM order_items
    GROUP BY seller_id
),
ranked AS (
    SELECT
        seller_id,
        revenue,
        SUM(revenue) OVER (
            ORDER BY revenue DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_revenue,
        SUM(revenue) OVER () AS total_revenue
    FROM seller_revenue
)
SELECT
    seller_id,
    ROUND(revenue, 2) AS revenue,
    ROUND(
        100.0 * cumulative_revenue / total_revenue,
        2
    ) AS cumulative_revenue_percent
FROM ranked
WHERE cumulative_revenue <= total_revenue * 0.80
ORDER BY revenue DESC;


-- ============================================================
-- 7. COHORT-STYLE CUSTOMER ANALYSIS
-- ============================================================

WITH customer_first_order AS (
    SELECT
        c.customer_unique_id,
        MIN(DATE_TRUNC('month', o.order_purchase_timestamp)::date) AS first_order_month
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
),
customer_months AS (
    SELECT DISTINCT
        c.customer_unique_id,
        DATE_TRUNC('month', o.order_purchase_timestamp)::date AS order_month
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
),
cohort AS (
    SELECT
        cm.order_month,
        cfo.first_order_month,
        COUNT(DISTINCT cm.customer_unique_id) AS customers
    FROM customer_months cm
    JOIN customer_first_order cfo
        ON cm.customer_unique_id = cfo.customer_unique_id
    GROUP BY cm.order_month, cfo.first_order_month
)
SELECT
    first_order_month,
    order_month,
    customers,
    (
        (EXTRACT(YEAR FROM order_month) - EXTRACT(YEAR FROM first_order_month)) * 12
        + EXTRACT(MONTH FROM order_month) - EXTRACT(MONTH FROM first_order_month)
    )::int AS months_since_first_order
FROM cohort
ORDER BY first_order_month, order_month;


-- ============================================================
-- 8. LATE DELIVERY RANKING BY STATE
-- ============================================================

WITH state_delivery AS (
    SELECT
        c.customer_state,
        COUNT(*) AS delivered_orders,
        COUNT(*) FILTER (
            WHERE o.order_delivered_customer_date > o.order_estimated_delivery_date
        ) AS late_orders
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
      AND o.order_estimated_delivery_date IS NOT NULL
    GROUP BY c.customer_state
)
SELECT
    customer_state,
    delivered_orders,
    late_orders,
    ROUND(
        100.0 * late_orders / NULLIF(delivered_orders, 0),
        2
    ) AS late_delivery_rate,
    RANK() OVER (
        ORDER BY late_orders::numeric / NULLIF(delivered_orders, 0) DESC
    ) AS late_rate_rank
FROM state_delivery
WHERE delivered_orders >= 100
ORDER BY late_rate_rank;


-- ============================================================
-- 9. REVIEW SCORE RANKING BY CATEGORY
-- ============================================================

WITH category_reviews AS (
    SELECT
        COALESCE(
            t.product_category_name_english,
            p.product_category_name,
            'Unknown'
        ) AS category,
        AVG(r.review_score) AS avg_score,
        COUNT(*) AS reviews
    FROM order_reviews r
    JOIN orders o
        ON r.order_id = o.order_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    JOIN products p
        ON oi.product_id = p.product_id
    LEFT JOIN product_category_translation t
        ON p.product_category_name = t.product_category_name
    GROUP BY 1
)
SELECT
    category,
    ROUND(avg_score, 2) AS avg_review_score,
    reviews,
    RANK() OVER (ORDER BY avg_score DESC) AS score_rank
FROM category_reviews
WHERE reviews >= 50
ORDER BY score_rank;


-- ============================================================
-- 10. PAYMENT INSTALLMENT ANALYSIS
-- ============================================================

SELECT
    payment_type,
    payment_installments,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(SUM(payment_value), 2) AS payment_value,
    ROUND(AVG(payment_value), 2) AS avg_payment
FROM order_payments
GROUP BY payment_type, payment_installments
ORDER BY payment_type, payment_installments;


-- ============================================================
-- 11. ORDER VALUE SEGMENTATION
-- ============================================================

WITH order_values AS (
    SELECT
        order_id,
        SUM(price) AS order_value
    FROM order_items
    GROUP BY order_id
)
SELECT
    CASE
        WHEN order_value < 50 THEN 'Under 50'
        WHEN order_value < 100 THEN '50-99'
        WHEN order_value < 250 THEN '100-249'
        WHEN order_value < 500 THEN '250-499'
        ELSE '500+'
    END AS order_value_segment,
    COUNT(*) AS orders,
    ROUND(SUM(order_value), 2) AS revenue,
    ROUND(AVG(order_value), 2) AS average_order_value
FROM order_values
GROUP BY 1
ORDER BY MIN(order_value);


-- ============================================================
-- 12. DELIVERY TIME BUCKETS
-- ============================================================

WITH delivery_times AS (
    SELECT
        order_id,
        EXTRACT(
            EPOCH FROM
            (order_delivered_customer_date - order_purchase_timestamp)
        ) / 86400 AS delivery_days
    FROM orders
    WHERE order_status = 'delivered'
      AND order_delivered_customer_date IS NOT NULL
)
SELECT
    CASE
        WHEN delivery_days < 5 THEN 'Under 5 days'
        WHEN delivery_days < 10 THEN '5-9 days'
        WHEN delivery_days < 20 THEN '10-19 days'
        WHEN delivery_days < 30 THEN '20-29 days'
        ELSE '30+ days'
    END AS delivery_bucket,
    COUNT(*) AS orders,
    ROUND(AVG(delivery_days), 2) AS avg_delivery_days
FROM delivery_times
GROUP BY 1
ORDER BY MIN(delivery_days);


-- ============================================================
-- 13. CUSTOMER LIFETIME VALUE STYLE METRIC
-- ============================================================

WITH customer_value AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS orders,
        SUM(oi.price) AS revenue
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id
)
SELECT
    ROUND(AVG(revenue), 2) AS average_customer_revenue,
    ROUND(
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY revenue),
        2
    ) AS median_customer_revenue,
    ROUND(MAX(revenue), 2) AS highest_customer_revenue
FROM customer_value;


-- ============================================================
-- 14. REVENUE CONCENTRATION: TOP 10% CUSTOMERS
-- ============================================================

WITH customer_revenue AS (
    SELECT
        c.customer_unique_id,
        SUM(oi.price) AS revenue
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id
),
ranked AS (
    SELECT
        *,
        NTILE(10) OVER (ORDER BY revenue DESC) AS decile
    FROM customer_revenue
)
SELECT
    ROUND(SUM(revenue) FILTER (WHERE decile = 1), 2) AS top_10_percent_revenue,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(
        100.0 * SUM(revenue) FILTER (WHERE decile = 1)
        / SUM(revenue),
        2
    ) AS top_10_percent_revenue_share
FROM ranked;


-- ============================================================
-- 15. QUALITY CHECKS
-- ============================================================

-- Orders without a matching customer
SELECT COUNT(*) AS orders_without_customer
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


-- Order items without a matching order
SELECT COUNT(*) AS items_without_order
FROM order_items oi
LEFT JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;


-- Products without a category
SELECT COUNT(*) AS products_without_category
FROM products
WHERE product_category_name IS NULL;


-- Reviews outside valid score range
SELECT COUNT(*) AS invalid_review_scores
FROM order_reviews
WHERE review_score NOT BETWEEN 1 AND 5;
