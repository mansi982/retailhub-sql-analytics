/*
=======================================================================
 File        : 03_analysis_queries_documented.sql
 Database    : MySQL 8.0+
 Project     : E-commerce Sales, Inventory & Customer Analytics
 Purpose     : Portfolio-ready SQL analysis queries for Data Analyst roles
 Run Order   : Run after schema and insert files:
               01_schema_fully_documented.sql
               02_insert_data_documented.sql
=======================================================================

WHAT THIS FILE SHOWS
--------------------
This file contains 25 business-focused SQL queries. Each query includes:
1. Business question
2. Why the query is useful
3. SQL skills used
4. Expected output description
5. Easy explanation of important SQL logic
6. Learning takeaway

TOPICS COVERED
--------------
- SELECT, WHERE, ORDER BY
- GROUP BY and HAVING
- Aggregate functions: COUNT, SUM, AVG
- CASE statements for business labels
- INNER JOIN and LEFT JOIN
- Self joins for employee-manager hierarchy
- Subqueries and NOT EXISTS
- Common Table Expressions (CTEs)
- Window functions: LAG, RANK, NTILE, FIRST_VALUE, LAST_VALUE
- Running totals and percentage calculations
- Date functions: DATE_FORMAT, DATEDIFF, TIMESTAMPDIFF
- String functions: CONCAT, UPPER, SUBSTRING_INDEX

IMPORTANT NOTE
--------------
These queries are written for MySQL 8.0 or newer because they use
window functions such as LAG(), RANK(), NTILE(), FIRST_VALUE(), and
LAST_VALUE().
=======================================================================
*/

USE retailhub_db;

-- Quick check before running analysis:
-- These queries confirm that the main tables contain data.
-- If any count is 0, run the schema and insert-data files first.
SELECT 'customers' AS table_name, COUNT(*) AS total_rows FROM customers
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'products', COUNT(*) FROM products;


-- #####################################################################
-- SECTION: SALES ANALYSIS
-- #####################################################################

-- =====================================================================
-- Q1. SALES OVERVIEW
-- Difficulty: Beginner
--
-- Business Question:
-- What are total orders, valid orders, total revenue, and average order value?
--
-- Why this is useful:
-- This gives a quick KPI summary for management and is useful for dashboards.
--
-- Skills Used:
-- aggregate functions, CASE, WHERE
--
-- Expected Output:
-- Shows one row with total_orders, valid_orders, total_revenue, avg_order_value.
--
-- Easy Explanation:
-- Aggregate functions summarize many rows into one result; CASE excludes cancelled orders from revenue calculations.
--
-- Learning Takeaway:
-- This query turns raw transactional data into a business metric that
-- can be used in reports, dashboards, or interview discussions.
-- =====================================================================
SELECT
    COUNT(*) AS total_orders,
    SUM(CASE WHEN order_status <> 'Cancelled' THEN 1 ELSE 0 END) AS valid_orders,
    ROUND(SUM(CASE WHEN order_status <> 'Cancelled' THEN total_amount ELSE 0 END), 2) AS total_revenue,
    ROUND(AVG(CASE WHEN order_status <> 'Cancelled' THEN total_amount END), 2)        AS avg_order_value
FROM orders;

-- =====================================================================
-- Q2. MONTHLY REVENUE TREND
-- Difficulty: Beginner
--
-- Business Question:
-- How much revenue is generated every month?
--
-- Why this is useful:
-- Helps identify seasonality, growth periods, and slow months.
--
-- Skills Used:
-- DATE_FORMAT, GROUP BY, ORDER BY
--
-- Expected Output:
-- Shows month, number of orders, and monthly revenue.
--
-- Easy Explanation:
-- DATE_FORMAT groups dates by year-month so trends are easier to analyze.
--
-- Learning Takeaway:
-- This query turns raw transactional data into a business metric that
-- can be used in reports, dashboards, or interview discussions.
-- =====================================================================
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS order_month,
    COUNT(DISTINCT order_id)         AS orders_count,
    ROUND(SUM(total_amount), 2)      AS monthly_revenue
FROM orders
WHERE order_status <> 'Cancelled'
GROUP BY order_month
ORDER BY order_month;

-- =====================================================================
-- Q3. MONTH-OVER-MONTH REVENUE GROWTH %
-- Difficulty: Advanced
--
-- Business Question:
-- How much did revenue grow or decline compared with the previous month?
--
-- Why this is useful:
-- Helps measure business momentum and detect revenue drops early.
--
-- Skills Used:
-- Window function LAG(), CTE
--
-- Expected Output:
-- Shows current revenue, previous month revenue, and growth percentage.
--
-- Easy Explanation:
-- LAG reads the previous row; NULLIF prevents division-by-zero errors.
--
-- Learning Takeaway:
-- This query turns raw transactional data into a business metric that
-- can be used in reports, dashboards, or interview discussions.
-- =====================================================================
WITH monthly AS (
    SELECT DATE_FORMAT(order_date, '%Y-%m') AS order_month,
           SUM(total_amount) AS revenue
    FROM orders
    WHERE order_status <> 'Cancelled'
    GROUP BY order_month
)
SELECT
    order_month,
    ROUND(revenue, 2) AS revenue,
    ROUND(LAG(revenue) OVER (ORDER BY order_month), 2) AS prev_month_revenue,
    ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY order_month))
          / NULLIF(LAG(revenue) OVER (ORDER BY order_month), 0), 2) AS mom_growth_pct
FROM monthly
ORDER BY order_month;

-- =====================================================================
-- Q4. RUNNING TOTAL REVENUE BY MONTH
-- Difficulty: Advanced
--
-- Business Question:
-- What is cumulative revenue over time?
--
-- Why this is useful:
-- Useful for tracking progress toward yearly revenue targets.
--
-- Skills Used:
-- Window function SUM() OVER with ORDER BY (running total)
--
-- Expected Output:
-- Shows monthly revenue and cumulative running total.
--
-- Easy Explanation:
-- SUM() OVER keeps the monthly rows while calculating a cumulative total.
--
-- Learning Takeaway:
-- This query turns raw transactional data into a business metric that
-- can be used in reports, dashboards, or interview discussions.
-- =====================================================================
WITH monthly AS (
    SELECT DATE_FORMAT(order_date, '%Y-%m') AS order_month,
           SUM(total_amount) AS revenue
    FROM orders
    WHERE order_status <> 'Cancelled'
    GROUP BY order_month
)
SELECT
    order_month,
    ROUND(revenue, 2) AS monthly_revenue,
    ROUND(SUM(revenue) OVER (ORDER BY order_month
          ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2) AS running_total_revenue
FROM monthly
ORDER BY order_month;

-- #####################################################################
-- SECTION: PRODUCT & CATEGORY ANALYSIS
-- #####################################################################

-- =====================================================================
-- Q5. TOP 10 BEST-SELLING PRODUCTS BY REVENUE
-- Difficulty: Intermediate
--
-- Business Question:
-- Which products generate the highest revenue?
--
-- Why this is useful:
-- Helps with inventory planning, promotions, and product strategy.
--
-- Skills Used:
-- JOIN, GROUP BY, ORDER BY, LIMIT
--
-- Expected Output:
-- Shows product, category, units sold, and revenue.
--
-- Easy Explanation:
-- JOIN connects orders, items, products, and categories to answer a business question.
--
-- Learning Takeaway:
-- This query turns raw transactional data into a business metric that
-- can be used in reports, dashboards, or interview discussions.
-- =====================================================================
SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    SUM(oi.quantity)              AS units_sold,
    ROUND(SUM(oi.subtotal), 2)    AS total_revenue
FROM order_items oi
JOIN orders o        ON o.order_id = oi.order_id
JOIN products p       ON p.product_id = oi.product_id
JOIN subcategories sc ON sc.subcategory_id = p.subcategory_id
JOIN categories c     ON c.category_id = sc.category_id
WHERE o.order_status <> 'Cancelled'
GROUP BY p.product_id, p.product_name, c.category_name
ORDER BY total_revenue DESC
LIMIT 10;

-- =====================================================================
-- Q6. RANK PRODUCTS WITHIN EACH CATEGORY BY REVENUE
-- Difficulty: Advanced
--
-- Business Question:
-- What are the top 3 products inside each category?
--
-- Why this is useful:
-- Helps compare products fairly within the same category.
--
-- Skills Used:
-- Window function RANK() PARTITION BY, CTE chaining
--
-- Expected Output:
-- Shows category, product, revenue, and category rank.
--
-- Easy Explanation:
-- RANK() with PARTITION BY creates separate rankings inside each category.
--
-- Learning Takeaway:
-- This query turns raw transactional data into a business metric that
-- can be used in reports, dashboards, or interview discussions.
-- =====================================================================
WITH product_rev AS (
    SELECT
        c.category_name,
        p.product_name,
        SUM(oi.subtotal) AS revenue
    FROM order_items oi
    JOIN orders o ON o.order_id = oi.order_id
    JOIN products p ON p.product_id = oi.product_id
    JOIN subcategories sc ON sc.subcategory_id = p.subcategory_id
    JOIN categories c ON c.category_id = sc.category_id
    WHERE o.order_status <> 'Cancelled'
    GROUP BY c.category_name, p.product_name
),
ranked AS (
    SELECT *, RANK() OVER (PARTITION BY category_name ORDER BY revenue DESC) AS rank_in_category
    FROM product_rev
)
SELECT category_name, product_name, ROUND(revenue,2) AS revenue, rank_in_category
FROM ranked
WHERE rank_in_category <= 3
ORDER BY category_name, rank_in_category;

-- =====================================================================
-- Q7. CATEGORY-WISE REVENUE CONTRIBUTION %
-- Difficulty: Intermediate
--
-- Business Question:
-- What percentage of total sales comes from each category?
--
-- Why this is useful:
-- Helps management see which categories drive the business.
--
-- Skills Used:
-- subquery in SELECT, aggregate, percentage calc
--
-- Expected Output:
-- Shows category revenue and percent of total revenue.
--
-- Easy Explanation:
-- A subquery calculates total revenue so each category can be compared against it.
--
-- Learning Takeaway:
-- This query turns raw transactional data into a business metric that
-- can be used in reports, dashboards, or interview discussions.
-- =====================================================================
SELECT
    c.category_name,
    ROUND(SUM(oi.subtotal), 2) AS category_revenue,
    ROUND(100.0 * SUM(oi.subtotal) /
        (SELECT SUM(oi2.subtotal)
         FROM order_items oi2
         JOIN orders o2 ON o2.order_id = oi2.order_id
         WHERE o2.order_status <> 'Cancelled'), 2) AS pct_of_total_revenue
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
JOIN products p ON p.product_id = oi.product_id
JOIN subcategories sc ON sc.subcategory_id = p.subcategory_id
JOIN categories c ON c.category_id = sc.category_id
WHERE o.order_status <> 'Cancelled'
GROUP BY c.category_name
ORDER BY category_revenue DESC;

-- #####################################################################
-- SECTION: CUSTOMER ANALYSIS
-- #####################################################################

-- =====================================================================
-- Q8. CUSTOMER SEGMENTATION — RFM ANALYSIS
-- Difficulty: Advanced
--
-- Business Question:
-- Who are the most valuable, loyal, or at-risk customers?
--
-- Why this is useful:
-- RFM is a common marketing analytics method for customer segmentation.
--
-- Skills Used:
-- CTE, DATEDIFF, NTILE(), multiple joins
--
-- Expected Output:
-- Shows recency, frequency, monetary value, scores, and customer tag.
--
-- Easy Explanation:
-- NTILE divides customers into score groups; CASE converts scores into business labels.
--
-- Learning Takeaway:
-- This query turns raw transactional data into a business metric that
-- can be used in reports, dashboards, or interview discussions.
-- =====================================================================
WITH customer_orders AS (
    SELECT
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        c.customer_segment,
        DATEDIFF(CURDATE(), MAX(o.order_date))  AS recency_days,
        COUNT(o.order_id)                       AS frequency,
        SUM(o.total_amount)                     AS monetary
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    WHERE o.order_status <> 'Cancelled'
    GROUP BY c.customer_id, customer_name, c.customer_segment
),
rfm_scores AS (
    SELECT
        *,
        NTILE(4) OVER (ORDER BY recency_days DESC) AS r_score,  -- lower recency_days = better = higher score handled by DESC
        NTILE(4) OVER (ORDER BY frequency ASC)      AS f_score,
        NTILE(4) OVER (ORDER BY monetary ASC)       AS m_score
    FROM customer_orders
)
SELECT
    customer_id, customer_name, customer_segment,
    recency_days, frequency, ROUND(monetary,2) AS monetary,
    r_score, f_score, m_score,
    (r_score + f_score + m_score) AS rfm_total,
    CASE
        WHEN (r_score + f_score + m_score) >= 10 THEN 'Champion'
        WHEN (r_score + f_score + m_score) >= 7  THEN 'Loyal Customer'
        WHEN (r_score + f_score + m_score) >= 4  THEN 'At Risk'
        ELSE 'Needs Attention'
    END AS rfm_tag
FROM rfm_scores
ORDER BY rfm_total DESC
LIMIT 20;

-- =====================================================================
-- Q9. REPEAT CUSTOMER RATE
-- Difficulty: Intermediate
--
-- Business Question:
-- What percentage of customers placed more than one order?
--
-- Why this is useful:
-- Repeat rate is an important customer loyalty metric.
--
-- Skills Used:
-- subquery + aggregate, HAVING
--
-- Expected Output:
-- Shows total customers with orders, repeat customers, and repeat rate percentage.
--
-- Easy Explanation:
-- The subquery counts orders per customer; the outer query summarizes repeat behavior.
--
-- Learning Takeaway:
-- This query turns raw transactional data into a business metric that
-- can be used in reports, dashboards, or interview discussions.
-- =====================================================================
SELECT
    COUNT(*) AS total_customers_with_orders,
    SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) AS repeat_customers,
    ROUND(100.0 * SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS repeat_rate_pct
FROM (
    SELECT customer_id, COUNT(*) AS order_count
    FROM orders
    GROUP BY customer_id
) t;

-- =====================================================================
-- Q10. CUSTOMER LIFETIME VALUE — TOP 15 CUSTOMERS
-- Difficulty: Intermediate
--
-- Business Question:
-- Which customers have generated the most lifetime revenue?
--
-- Why this is useful:
-- Helps identify VIP customers and high-value segments.
--
-- Skills Used:
-- JOIN, GROUP BY, ORDER BY, string function (CONCAT)
--
-- Expected Output:
-- Shows customer name, total orders, lifetime value, and average order value.
--
-- Easy Explanation:
-- GROUP BY customer rolls order-level data into customer-level metrics.
--
-- Learning Takeaway:
-- This query turns raw transactional data into a business metric that
-- can be used in reports, dashboards, or interview discussions.
-- =====================================================================
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.customer_segment,
    COUNT(o.order_id)              AS total_orders,
    ROUND(SUM(o.total_amount), 2)  AS lifetime_value,
    ROUND(AVG(o.total_amount), 2)  AS avg_order_value
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_status <> 'Cancelled'
GROUP BY c.customer_id, customer_name, c.customer_segment
ORDER BY lifetime_value DESC
LIMIT 15;

-- #####################################################################
-- SECTION: EMPLOYEE & OPERATIONS ANALYSIS
-- #####################################################################

-- =====================================================================
-- Q11. EMPLOYEE SALES PERFORMANCE RANKING
-- Difficulty: Advanced
--
-- Business Question:
-- Which sales employees generated the most revenue?
--
-- Why this is useful:
-- Useful for performance tracking, incentives, and sales management.
--
-- Skills Used:
-- JOIN, RANK() OVER, self-join for manager name
--
-- Expected Output:
-- Shows employee, manager, orders handled, revenue generated, and rank.
--
-- Easy Explanation:
-- Self join gets manager names; RANK assigns performance position.
--
-- Learning Takeaway:
-- This query turns raw transactional data into a business metric that
-- can be used in reports, dashboards, or interview discussions.
-- =====================================================================
SELECT
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name)  AS employee_name,
    CONCAT(m.first_name, ' ', m.last_name)  AS manager_name,
    COUNT(o.order_id)                       AS orders_handled,
    ROUND(SUM(o.total_amount), 2)           AS revenue_generated,
    RANK() OVER (ORDER BY SUM(o.total_amount) DESC) AS sales_rank
FROM employees e
LEFT JOIN employees m ON m.employee_id = e.manager_id
JOIN orders o ON o.employee_id = e.employee_id AND o.order_status <> 'Cancelled'
WHERE e.department_id = 1
GROUP BY e.employee_id, employee_name, manager_name
ORDER BY sales_rank;

-- #####################################################################
-- SECTION: INVENTORY ANALYSIS
-- #####################################################################

-- =====================================================================
-- Q12. WAREHOUSE INVENTORY HEALTH
-- Difficulty: Beginner
--
-- Business Question:
-- Which products are below reorder level?
--
-- Why this is useful:
-- Helps prevent stockouts and supports inventory replenishment decisions.
--
-- Skills Used:
-- JOIN, WHERE, CASE (flagging)
--
-- Expected Output:
-- Shows warehouse, product, stock quantity, reorder level, and stock status.
--
-- Easy Explanation:
-- CASE creates easy status labels like OUT OF STOCK and REORDER NOW.
--
-- Learning Takeaway:
-- This query turns raw transactional data into a business metric that
-- can be used in reports, dashboards, or interview discussions.
-- =====================================================================
SELECT
    w.warehouse_name,
    p.product_name,
    i.stock_quantity,
    i.reorder_level,
    CASE
        WHEN i.stock_quantity = 0 THEN 'OUT OF STOCK'
        WHEN i.stock_quantity < i.reorder_level THEN 'REORDER NOW'
        ELSE 'OK'
    END AS stock_status
FROM inventory i
JOIN products p ON p.product_id = i.product_id
JOIN warehouses w ON w.warehouse_id = i.warehouse_id
WHERE i.stock_quantity < i.reorder_level
ORDER BY i.stock_quantity ASC;

-- #####################################################################
-- SECTION: RETURNS & QUALITY ANALYSIS
-- #####################################################################

-- =====================================================================
-- Q13. RETURN RATE BY CATEGORY
-- Difficulty: Intermediate
--
-- Business Question:
-- Which categories have the highest return rate?
--
-- Why this is useful:
-- Helps find product quality, sizing, or customer satisfaction problems.
--
-- Skills Used:
-- multiple JOINs, LEFT JOIN, aggregate ratio
--
-- Expected Output:
-- Shows items sold, items returned, and return rate by category.
--
-- Easy Explanation:
-- LEFT JOIN includes sold items even when they were not returned.
--
-- Learning Takeaway:
-- This query turns raw transactional data into a business metric that
-- can be used in reports, dashboards, or interview discussions.
-- =====================================================================
SELECT
    c.category_name,
    COUNT(DISTINCT oi.order_item_id)  AS items_sold,
    COUNT(DISTINCT r.return_id)       AS items_returned,
    ROUND(100.0 * COUNT(DISTINCT r.return_id) / COUNT(DISTINCT oi.order_item_id), 2) AS return_rate_pct
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
JOIN products p ON p.product_id = oi.product_id
JOIN subcategories sc ON sc.subcategory_id = p.subcategory_id
JOIN categories c ON c.category_id = sc.category_id
LEFT JOIN returns r ON r.order_item_id = oi.order_item_id
WHERE o.order_status <> 'Cancelled'
GROUP BY c.category_name
ORDER BY return_rate_pct DESC;

-- #####################################################################
-- SECTION: SHIPPING & LOGISTICS ANALYSIS
-- #####################################################################

-- =====================================================================
-- Q14. AVERAGE DELIVERY TIME BY DELIVERY AGENT
-- Difficulty: Intermediate
--
-- Business Question:
-- Which delivery agents are fastest on average?
--
-- Why this is useful:
-- Supports logistics performance tracking and SLA improvement.
--
-- Skills Used:
-- DATEDIFF/TIMESTAMPDIFF, JOIN, HAVING
--
-- Expected Output:
-- Shows agent, vehicle type, completed deliveries, and average delivery days.
--
-- Easy Explanation:
-- TIMESTAMPDIFF calculates time between shipped and delivered dates.
--
-- Learning Takeaway:
-- This query turns raw transactional data into a business metric that
-- can be used in reports, dashboards, or interview discussions.
-- =====================================================================
SELECT
    da.agent_id,
    da.agent_name,
    da.vehicle_type,
    COUNT(s.shipment_id) AS deliveries_completed,
    ROUND(AVG(TIMESTAMPDIFF(HOUR, s.shipped_date, s.delivery_date)) / 24.0, 2) AS avg_delivery_days
FROM shipments s
JOIN delivery_agents da ON da.agent_id = s.agent_id
WHERE s.shipment_status = 'Delivered'
GROUP BY da.agent_id, da.agent_name, da.vehicle_type
HAVING COUNT(s.shipment_id) >= 3
ORDER BY avg_delivery_days ASC;

-- #####################################################################
-- SECTION: MARKETING ANALYSIS
-- #####################################################################

-- =====================================================================
-- Q15. COUPON EFFECTIVENESS
-- Difficulty: Intermediate
--
-- Business Question:
-- Which coupons are used most and how much discount do they give?
--
-- Why this is useful:
-- Helps evaluate marketing campaigns and discount strategy.
--
-- Skills Used:
-- JOIN, GROUP BY, aggregate
--
-- Expected Output:
-- Shows coupon code, usage count, total discount, and average order value.
--
-- Easy Explanation:
-- JOIN connects coupon usage to orders and coupon details.
--
-- Learning Takeaway:
-- This query turns raw transactional data into a business metric that
-- can be used in reports, dashboards, or interview discussions.
-- =====================================================================
SELECT
    cp.coupon_code,
    cp.discount_percent,
    COUNT(oc.order_id)                 AS times_used,
    ROUND(SUM(oc.discount_applied), 2) AS total_discount_given,
    ROUND(AVG(o.total_amount), 2)      AS avg_order_value_with_coupon
FROM order_coupons oc
JOIN coupons cp ON cp.coupon_id = oc.coupon_id
JOIN orders o   ON o.order_id = oc.order_id
GROUP BY cp.coupon_code, cp.discount_percent
ORDER BY times_used DESC;

-- #####################################################################
-- SECTION: CUSTOMER FEEDBACK ANALYSIS
-- #####################################################################

-- =====================================================================
-- Q16. TOP-RATED PRODUCTS
-- Difficulty: Intermediate
--
-- Business Question:
-- Which products have the best customer ratings?
--
-- Why this is useful:
-- Helps highlight popular products and identify quality winners.
--
-- Skills Used:
-- JOIN, HAVING, ROUND, ORDER BY multiple columns
--
-- Expected Output:
-- Shows product, review count, and average rating.
--
-- Easy Explanation:
-- HAVING filters grouped results after counting reviews.
--
-- Learning Takeaway:
-- This query turns raw transactional data into a business metric that
-- can be used in reports, dashboards, or interview discussions.
-- =====================================================================
SELECT
    p.product_name,
    COUNT(r.review_id)          AS review_count,
    ROUND(AVG(r.rating), 2)     AS avg_rating
FROM reviews r
JOIN products p ON p.product_id = r.product_id
GROUP BY p.product_name
HAVING COUNT(r.review_id) >= 3
ORDER BY avg_rating DESC, review_count DESC
LIMIT 10;

-- #####################################################################
-- SECTION: CUSTOMER SUPPORT ANALYSIS
-- #####################################################################

-- =====================================================================
-- Q17. SUPPORT TICKET RESOLUTION TIME BY ISSUE TYPE
-- Difficulty: Intermediate
--
-- Business Question:
-- Which support issues take longest to resolve?
--
-- Why this is useful:
-- Helps improve customer support staffing and processes.
--
-- Skills Used:
-- TIMESTAMPDIFF, CASE, GROUP BY
--
-- Expected Output:
-- Shows issue type, total tickets, resolved tickets, and average resolution hours.
--
-- Easy Explanation:
-- CASE counts only resolved/closed tickets; TIMESTAMPDIFF measures resolution time.
--
-- Learning Takeaway:
-- This query turns raw transactional data into a business metric that
-- can be used in reports, dashboards, or interview discussions.
-- =====================================================================
SELECT
    issue_type,
    COUNT(*)                                                          AS total_tickets,
    SUM(CASE WHEN ticket_status IN ('Resolved','Closed') THEN 1 ELSE 0 END) AS resolved_tickets,
    ROUND(AVG(CASE WHEN resolved_at IS NOT NULL
              THEN TIMESTAMPDIFF(HOUR, created_at, resolved_at) END), 1)    AS avg_resolution_hours
FROM support_tickets
GROUP BY issue_type
ORDER BY avg_resolution_hours DESC;

-- #####################################################################
-- SECTION: EMPLOYEE & OPERATIONS ANALYSIS
-- #####################################################################

-- =====================================================================
-- Q18. EMPLOYEE-MANAGER HIERARCHY
-- Difficulty: Beginner
--
-- Business Question:
-- Who reports to whom in each department?
--
-- Why this is useful:
-- Helps understand organization structure and reporting lines.
--
-- Skills Used:
-- self join, LEFT JOIN for top-level managers
--
-- Expected Output:
-- Shows employee, job title, department, and manager.
--
-- Easy Explanation:
-- A self join connects an employee row to another employee row as manager.
--
-- Learning Takeaway:
-- This query turns raw transactional data into a business metric that
-- can be used in reports, dashboards, or interview discussions.
-- =====================================================================
SELECT
    e.employee_id,
    CONCAT(e.first_name,' ',e.last_name)  AS employee_name,
    e.job_title,
    d.department_name,
    COALESCE(CONCAT(m.first_name,' ',m.last_name), 'No Manager (Dept Head)') AS reports_to
FROM employees e
JOIN departments d ON d.department_id = e.department_id
LEFT JOIN employees m ON m.employee_id = e.manager_id
ORDER BY d.department_name, reports_to;

-- #####################################################################
-- SECTION: SUPPLIER ANALYSIS
-- #####################################################################

-- =====================================================================
-- Q19. SUPPLIER PERFORMANCE — REVENUE GENERATED
-- Difficulty: Intermediate
--
-- Business Question:
-- Which suppliers generate the most revenue through their products?
--
-- Why this is useful:
-- Supports supplier evaluation, negotiation, and purchasing decisions.
--
-- Skills Used:
-- multi-table JOIN, subquery, ranking
--
-- Expected Output:
-- Shows supplier, country, rating, products supplied, and revenue generated.
--
-- Easy Explanation:
-- Multi-table JOIN connects suppliers to products and sales.
--
-- Learning Takeaway:
-- This query turns raw transactional data into a business metric that
-- can be used in reports, dashboards, or interview discussions.
-- =====================================================================
SELECT
    s.supplier_name,
    s.country,
    s.rating,
    COUNT(DISTINCT p.product_id)   AS products_supplied,
    ROUND(SUM(oi.subtotal), 2)     AS revenue_generated
FROM suppliers s
JOIN products p ON p.supplier_id = s.supplier_id
JOIN order_items oi ON oi.product_id = p.product_id
JOIN orders o ON o.order_id = oi.order_id AND o.order_status <> 'Cancelled'
GROUP BY s.supplier_id, s.supplier_name, s.country, s.rating
ORDER BY revenue_generated DESC
LIMIT 10;

-- #####################################################################
-- SECTION: CUSTOMER ANALYSIS
-- #####################################################################

-- =====================================================================
-- Q20. CUSTOMERS WHO NEVER ORDERED
-- Difficulty: Intermediate
--
-- Business Question:
-- Which signed-up customers have not placed any order?
--
-- Why this is useful:
-- Useful for activation campaigns and onboarding follow-up.
--
-- Skills Used:
-- correlated subquery / NOT EXISTS, anti-join pattern
--
-- Expected Output:
-- Shows customer id, name, and signup date for non-buyers.
--
-- Easy Explanation:
-- NOT EXISTS is an anti-join pattern used to find missing related records.
--
-- Learning Takeaway:
-- This query turns raw transactional data into a business metric that
-- can be used in reports, dashboards, or interview discussions.
-- =====================================================================
SELECT c.customer_id, CONCAT(c.first_name,' ',c.last_name) AS customer_name, c.signup_date
FROM customers c
WHERE NOT EXISTS (
    SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id
);

-- =====================================================================
-- Q21. CHURN ANALYSIS — CUSTOMERS INACTIVE FOR 90+ DAYS
-- Difficulty: Intermediate
--
-- Business Question:
-- Which customers may be inactive or churned?
--
-- Why this is useful:
-- Helps target win-back campaigns and retention offers.
--
-- Skills Used:
-- subquery, DATEDIFF, CASE bucketing
--
-- Expected Output:
-- Shows last order date, days since last order, and churn status.
--
-- Easy Explanation:
-- DATEDIFF measures inactivity; CASE groups customers into status buckets.
--
-- Learning Takeaway:
-- This query turns raw transactional data into a business metric that
-- can be used in reports, dashboards, or interview discussions.
-- =====================================================================
SELECT
    c.customer_id,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    MAX(o.order_date) AS last_order_date,
    DATEDIFF(CURDATE(), MAX(o.order_date)) AS days_since_last_order,
    CASE
        WHEN DATEDIFF(CURDATE(), MAX(o.order_date)) > 180 THEN 'Churned'
        WHEN DATEDIFF(CURDATE(), MAX(o.order_date)) > 90  THEN 'At Risk'
        ELSE 'Active'
    END AS churn_status
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, customer_name
ORDER BY days_since_last_order DESC
LIMIT 20;

-- #####################################################################
-- SECTION: PAYMENT ANALYSIS
-- #####################################################################

-- =====================================================================
-- Q22. PAYMENT METHOD DISTRIBUTION & FAILURE RATE
-- Difficulty: Intermediate
--
-- Business Question:
-- Which payment methods are most used and how often do payments fail?
--
-- Why this is useful:
-- Helps monitor payment reliability and customer payment preference.
--
-- Skills Used:
-- CASE, GROUP BY, percentage of total using window function
--
-- Expected Output:
-- Shows payment method, transaction count, failed transactions, and share of all transactions.
--
-- Easy Explanation:
-- Window SUM(COUNT(*)) OVER () calculates overall total while keeping method rows.
--
-- Learning Takeaway:
-- This query turns raw transactional data into a business metric that
-- can be used in reports, dashboards, or interview discussions.
-- =====================================================================
SELECT
    payment_method,
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN payment_status = 'Failed' THEN 1 ELSE 0 END)   AS failed_transactions,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2)           AS pct_of_all_transactions
FROM payments
GROUP BY payment_method
ORDER BY total_transactions DESC;

-- #####################################################################
-- SECTION: DATA CLEANING EXAMPLES
-- #####################################################################

-- =====================================================================
-- Q23. STANDARDIZE CUSTOMER NAMES & EMAIL DOMAINS
-- Difficulty: Beginner
--
-- Business Question:
-- How can text fields be cleaned or transformed for reporting?
--
-- Why this is useful:
-- Useful for data cleaning and customer domain analysis.
--
-- Skills Used:
-- CONCAT, UPPER, SUBSTRING_INDEX
--
-- Expected Output:
-- Shows uppercase customer names and extracted email domains.
--
-- Easy Explanation:
-- CONCAT, UPPER, and SUBSTRING_INDEX are common string-cleaning functions.
--
-- Learning Takeaway:
-- This query turns raw transactional data into a business metric that
-- can be used in reports, dashboards, or interview discussions.
-- =====================================================================
SELECT
    customer_id,
    UPPER(CONCAT(first_name, ' ', last_name)) AS full_name_upper,
    SUBSTRING_INDEX(email, '@', -1)            AS email_domain
FROM customers
LIMIT 15;

-- #####################################################################
-- SECTION: CUSTOMER ANALYSIS
-- #####################################################################

-- =====================================================================
-- Q24. FIRST VS LATEST PURCHASE PER CUSTOMER
-- Difficulty: Advanced
--
-- Business Question:
-- When did each customer first and most recently purchase?
--
-- Why this is useful:
-- Helps measure customer lifecycle and purchase history.
--
-- Skills Used:
-- FIRST_VALUE, LAST_VALUE window functions
--
-- Expected Output:
-- Shows customer id, first order date, and latest order date.
--
-- Easy Explanation:
-- FIRST_VALUE and LAST_VALUE return values from ordered rows within each customer group.
--
-- Learning Takeaway:
-- This query turns raw transactional data into a business metric that
-- can be used in reports, dashboards, or interview discussions.
-- =====================================================================
SELECT DISTINCT
    customer_id,
    FIRST_VALUE(order_date) OVER (PARTITION BY customer_id ORDER BY order_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS first_order_date,
    LAST_VALUE(order_date) OVER (PARTITION BY customer_id ORDER BY order_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS latest_order_date
FROM orders
ORDER BY customer_id
LIMIT 20;

-- #####################################################################
-- SECTION: SHIPPING & LOGISTICS ANALYSIS
-- #####################################################################

-- =====================================================================
-- Q25. ORDER-TO-DELIVERY SLA COMPLIANCE
-- Difficulty: Intermediate
--
-- Business Question:
-- What percentage of delivered orders met the 5-day delivery SLA?
--
-- Why this is useful:
-- Helps measure logistics service quality.
--
-- Skills Used:
-- CASE, JOIN, aggregate ratio
--
-- Expected Output:
-- Shows SLA compliance percentage and delivered order count.
--
-- Easy Explanation:
-- CASE checks whether each delivered order met the SLA, then aggregates the result.
--
-- Learning Takeaway:
-- This query turns raw transactional data into a business metric that
-- can be used in reports, dashboards, or interview discussions.
-- =====================================================================
SELECT
    ROUND(100.0 * SUM(CASE WHEN TIMESTAMPDIFF(DAY, o.order_date, s.delivery_date) <= 5 THEN 1 ELSE 0 END)
          / COUNT(*), 2) AS sla_compliance_pct,
    COUNT(*) AS total_delivered_orders
FROM orders o
JOIN shipments s ON s.order_id = o.order_id
WHERE s.shipment_status = 'Delivered';

-- =====================================================================
-- END OF FILE
-- =====================================================================
-- Portfolio Tip:
-- After running these queries, take screenshots of important results or
-- use the results to build a Power BI/Tableau dashboard. This will make
-- the SQL project stronger for Data Analyst job applications.
-- =====================================================================
