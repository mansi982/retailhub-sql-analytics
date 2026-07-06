-- =====================================================================
--  RETAILHUB — VIEWS, STORED PROCEDURES, FUNCTIONS & TRIGGERS
--  File: 04_views_procedures_triggers_documented.sql
--  Database: MySQL 8.0+
--  Run Order:
--      1) 01_schema_fully_documented.sql
--      2) 02_insert_data_documented.sql
--      3) 03_analysis_queries_documented.sql  -- optional practice queries
--      4) This file
--
--  Purpose:
--  This file adds reusable database objects that are common in real projects:
--      * VIEWS              : Saved SELECT queries for dashboards/reporting.
--      * FUNCTIONS          : Reusable calculations that return one value.
--      * STORED PROCEDURES  : Reusable reports/actions with input parameters.
--      * TRIGGERS           : Automatic checks/actions when data changes.
--
--  Portfolio Value:
--  These objects show that you understand not only SELECT queries, but also
--  production-style SQL design, automation, validation, and reporting layers.
--
--  Important MySQL Note:
--  DELIMITER is used before procedures/functions/triggers because their body
--  contains semicolons (;). It tells MySQL Workbench to treat the whole block
--  as one statement until it reaches //.
-- =====================================================================

USE retailhub_db;

-- =====================================================================
-- SECTION 1: CLEANUP
-- Purpose:
-- Dropping old versions makes this file re-runnable during practice.
-- You can run this file multiple times without getting "already exists" errors.
-- =====================================================================

DROP VIEW IF EXISTS vw_monthly_sales_summary;
DROP VIEW IF EXISTS vw_customer_lifetime_value;
DROP VIEW IF EXISTS vw_product_performance;
DROP VIEW IF EXISTS vw_inventory_reorder_alerts;
DROP VIEW IF EXISTS vw_order_fulfillment_status;

DROP FUNCTION IF EXISTS fn_customer_total_spent;
DROP FUNCTION IF EXISTS fn_product_profit_margin;

DROP PROCEDURE IF EXISTS sp_get_customer_orders;
DROP PROCEDURE IF EXISTS sp_top_n_products;
DROP PROCEDURE IF EXISTS sp_customer_360_summary;
DROP PROCEDURE IF EXISTS sp_restock_inventory;

DROP TRIGGER IF EXISTS trg_validate_stock_before_order_item;
DROP TRIGGER IF EXISTS trg_reduce_stock_after_order_item;
DROP TRIGGER IF EXISTS trg_validate_ticket_resolution;
DROP TRIGGER IF EXISTS trg_log_order_status_change;


-- =====================================================================
-- SECTION 2: VIEWS
-- Views are like saved SELECT queries.
-- They do not usually store data physically; they make reporting queries
-- easier, cleaner, and reusable.
-- =====================================================================


-- =====================================================================
-- VIEW 1: Monthly Sales Summary
--
-- Business Question:
-- How much revenue is generated each month?
--
-- Why this is useful:
-- This is useful for dashboards, monthly sales reporting, trend analysis,
-- and comparing month-to-month business performance.
--
-- Key SQL concepts:
-- DATE_FORMAT() : Converts a full date/time into year-month format.
-- COUNT()       : Counts orders.
-- SUM()         : Calculates total revenue.
-- AVG()         : Calculates average order value.
-- ROUND()       : Displays money values neatly with 2 decimals.
-- =====================================================================

CREATE OR REPLACE VIEW vw_monthly_sales_summary AS
SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS sales_month,
    COUNT(DISTINCT o.order_id)         AS total_orders,
    ROUND(SUM(o.total_amount), 2)      AS total_revenue,
    ROUND(AVG(o.total_amount), 2)      AS avg_order_value
FROM orders o
WHERE o.order_status <> 'Cancelled'
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m');

-- Example:
-- SELECT * FROM vw_monthly_sales_summary ORDER BY sales_month;


-- =====================================================================
-- VIEW 2: Customer Lifetime Value
--
-- Business Question:
-- Which customers have spent the most money over their lifetime?
--
-- Why this is useful:
-- Helps identify VIP/high-value customers for loyalty programs,
-- remarketing campaigns, and customer retention analysis.
--
-- Important design choice:
-- LEFT JOIN is used so customers with zero orders can still appear.
-- COALESCE() changes NULL revenue into 0, making reports easier to read.
-- =====================================================================

CREATE OR REPLACE VIEW vw_customer_lifetime_value AS
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.customer_segment,
    COUNT(o.order_id)                       AS total_orders,
    ROUND(COALESCE(SUM(o.total_amount), 0), 2) AS lifetime_value
FROM customers c
LEFT JOIN orders o
    ON o.customer_id = c.customer_id
   AND o.order_status <> 'Cancelled'
GROUP BY
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name),
    c.customer_segment;

-- Example:
-- SELECT * FROM vw_customer_lifetime_value
-- ORDER BY lifetime_value DESC
-- LIMIT 10;


-- =====================================================================
-- VIEW 3: Product Performance
--
-- Business Question:
-- Which products sell well, generate revenue, and receive good ratings?
--
-- Why this is useful:
-- Combines sales and review data in one place for product performance
-- analysis. Useful for dashboards and product manager reports.
--
-- Important correction:
-- Revenue and units_sold count only non-cancelled orders.
-- This avoids overstating product performance.
-- =====================================================================

CREATE OR REPLACE VIEW vw_product_performance AS
SELECT
    p.product_id,
    p.product_name,
    cat.category_name,

    -- CASE counts quantity only when the order is not cancelled.
    COALESCE(SUM(
        CASE
            WHEN o.order_status <> 'Cancelled' THEN oi.quantity
            ELSE 0
        END
    ), 0) AS units_sold,

    -- subtotal is generated in order_items as quantity * unit_price.
    COALESCE(ROUND(SUM(
        CASE
            WHEN o.order_status <> 'Cancelled' THEN oi.subtotal
            ELSE 0
        END
    ), 2), 0) AS revenue,

    ROUND(AVG(r.rating), 2) AS avg_rating
FROM products p
JOIN subcategories sc
    ON sc.subcategory_id = p.subcategory_id
JOIN categories cat
    ON cat.category_id = sc.category_id
LEFT JOIN order_items oi
    ON oi.product_id = p.product_id
LEFT JOIN orders o
    ON o.order_id = oi.order_id
LEFT JOIN reviews r
    ON r.product_id = p.product_id
GROUP BY
    p.product_id,
    p.product_name,
    cat.category_name;

-- Example:
-- SELECT * FROM vw_product_performance
-- ORDER BY revenue DESC;


-- =====================================================================
-- VIEW 4: Inventory Reorder Alerts
--
-- Business Question:
-- Which products are below or close to their reorder level?
--
-- Why this is useful:
-- Helps warehouse and operations teams avoid stockouts.
--
-- Key SQL concept:
-- CASE creates a readable business label from numeric stock values.
-- =====================================================================

CREATE OR REPLACE VIEW vw_inventory_reorder_alerts AS
SELECT
    i.inventory_id,
    p.product_id,
    p.product_name,
    w.warehouse_name,
    i.stock_quantity,
    i.reorder_level,
    i.last_restock_date,
    CASE
        WHEN i.stock_quantity = 0 THEN 'Out of Stock'
        WHEN i.stock_quantity <= i.reorder_level THEN 'Reorder Needed'
        WHEN i.stock_quantity <= i.reorder_level + 10 THEN 'Watch List'
        ELSE 'Healthy Stock'
    END AS stock_status
FROM inventory i
JOIN products p
    ON p.product_id = i.product_id
JOIN warehouses w
    ON w.warehouse_id = i.warehouse_id;

-- Example:
-- SELECT * FROM vw_inventory_reorder_alerts
-- WHERE stock_status IN ('Out of Stock', 'Reorder Needed');


-- =====================================================================
-- VIEW 5: Order Fulfillment Status
--
-- Business Question:
-- What is the payment and delivery status of each order?
--
-- Why this is useful:
-- Gives a single report for customer service, logistics, and operations.
-- It helps identify unpaid, delayed, cancelled, or delivered orders.
-- =====================================================================

CREATE OR REPLACE VIEW vw_order_fulfillment_status AS
SELECT
    o.order_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    o.order_date,
    o.order_status,
    o.total_amount,
    pay.payment_method,
    pay.payment_status,
    s.shipment_status,
    s.shipped_date,
    s.delivery_date,
    CASE
        WHEN o.order_status = 'Cancelled' THEN 'Order Cancelled'
        WHEN pay.payment_status IS NULL THEN 'Payment Missing'
        WHEN pay.payment_status <> 'Success' THEN 'Payment Not Successful'
        WHEN s.shipment_status IS NULL THEN 'Shipment Not Created'
        WHEN s.shipment_status = 'Delivered' THEN 'Completed'
        ELSE 'In Progress'
    END AS fulfillment_summary
FROM orders o
JOIN customers c
    ON c.customer_id = o.customer_id
LEFT JOIN payments pay
    ON pay.order_id = o.order_id
LEFT JOIN shipments s
    ON s.order_id = o.order_id;

-- Example:
-- SELECT * FROM vw_order_fulfillment_status
-- ORDER BY order_date DESC;


-- =====================================================================
-- SECTION 3: FUNCTIONS
-- Functions return one value and can be used inside SELECT statements.
-- =====================================================================


-- =====================================================================
-- FUNCTION 1: Customer Total Spent
--
-- Input:
-- p_customer_id = customer ID
--
-- Output:
-- Total amount spent by that customer, excluding cancelled orders.
--
-- Why this is useful:
-- Useful for customer segmentation, CLV analysis, and quick reporting.
-- =====================================================================

DELIMITER //
CREATE FUNCTION fn_customer_total_spent(p_customer_id INT)
RETURNS DECIMAL(12,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_total DECIMAL(12,2);

    SELECT COALESCE(SUM(total_amount), 0)
    INTO v_total
    FROM orders
    WHERE customer_id = p_customer_id
      AND order_status <> 'Cancelled';

    RETURN v_total;
END //
DELIMITER ;

-- Example:
-- SELECT fn_customer_total_spent(5) AS customer_total_spent;


-- =====================================================================
-- FUNCTION 2: Product Profit Margin Percentage
--
-- Input:
-- p_product_id = product ID
--
-- Output:
-- Profit margin percentage for the product.
--
-- Formula:
-- ((unit_price - cost_price) / unit_price) * 100
--
-- Why DECIMAL is used:
-- Profit margin is a financial percentage, so DECIMAL avoids rounding issues.
-- =====================================================================

DELIMITER //
CREATE FUNCTION fn_product_profit_margin(p_product_id INT)
RETURNS DECIMAL(5,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_margin DECIMAL(5,2);

    SELECT
        CASE
            WHEN unit_price IS NULL OR unit_price = 0 THEN 0
            ELSE ROUND(((unit_price - cost_price) / unit_price) * 100, 2)
        END
    INTO v_margin
    FROM products
    WHERE product_id = p_product_id;

    RETURN COALESCE(v_margin, 0);
END //
DELIMITER ;

-- Example:
-- SELECT product_id, product_name, fn_product_profit_margin(product_id) AS margin_pct
-- FROM products;


-- =====================================================================
-- SECTION 4: STORED PROCEDURES
-- Stored procedures are reusable SQL programs.
-- They are useful when the same report/action is needed many times.
-- =====================================================================


-- =====================================================================
-- PROCEDURE 1: Get Customer Orders
--
-- Input:
-- p_customer_id = customer ID
--
-- Output:
-- Full order history for one customer with payment details.
--
-- Why this is useful:
-- Customer support teams often need a customer's complete order history.
-- =====================================================================

DELIMITER //
CREATE PROCEDURE sp_get_customer_orders(IN p_customer_id INT)
BEGIN
    SELECT
        o.order_id,
        o.order_date,
        o.order_status,
        o.total_amount,
        pay.payment_method,
        pay.payment_status
    FROM orders o
    LEFT JOIN payments pay
        ON pay.order_id = o.order_id
    WHERE o.customer_id = p_customer_id
    ORDER BY o.order_date DESC;
END //
DELIMITER ;

-- Example:
-- CALL sp_get_customer_orders(5);


-- =====================================================================
-- PROCEDURE 2: Top N Products by Revenue
--
-- Input:
-- p_limit = number of products to return.
--
-- Output:
-- Best-selling products ranked by revenue.
--
-- Validation:
-- If user passes 0 or negative number, the procedure raises an error.
-- =====================================================================

DELIMITER //
CREATE PROCEDURE sp_top_n_products(IN p_limit INT)
BEGIN
    IF p_limit IS NULL OR p_limit <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'p_limit must be greater than 0';
    END IF;

    SELECT
        p.product_id,
        p.product_name,
        SUM(oi.quantity)          AS units_sold,
        ROUND(SUM(oi.subtotal),2) AS revenue
    FROM order_items oi
    JOIN orders o
        ON o.order_id = oi.order_id
    JOIN products p
        ON p.product_id = oi.product_id
    WHERE o.order_status <> 'Cancelled'
    GROUP BY
        p.product_id,
        p.product_name
    ORDER BY revenue DESC
    LIMIT p_limit;
END //
DELIMITER ;

-- Example:
-- CALL sp_top_n_products(10);


-- =====================================================================
-- PROCEDURE 3: Customer 360 Summary
--
-- Input:
-- p_customer_id = customer ID
--
-- Output:
-- A compact customer profile with sales, orders, returns, reviews,
-- and support-ticket information.
--
-- Why this is useful:
-- This is similar to a "single customer view" used by real companies.
-- =====================================================================

DELIMITER //
CREATE PROCEDURE sp_customer_360_summary(IN p_customer_id INT)
BEGIN
    SELECT
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        c.email,
        c.customer_segment,
        c.signup_date,

        COUNT(DISTINCT o.order_id) AS total_orders,
        ROUND(COALESCE(SUM(
            CASE
                WHEN o.order_status <> 'Cancelled' THEN o.total_amount
                ELSE 0
            END
        ), 0), 2) AS total_spent,

        COUNT(DISTINCT r.review_id) AS total_reviews,
        ROUND(AVG(r.rating), 2)     AS avg_rating_given,

        COUNT(DISTINCT t.ticket_id) AS total_support_tickets
    FROM customers c
    LEFT JOIN orders o
        ON o.customer_id = c.customer_id
    LEFT JOIN reviews r
        ON r.customer_id = c.customer_id
    LEFT JOIN support_tickets t
        ON t.customer_id = c.customer_id
    WHERE c.customer_id = p_customer_id
    GROUP BY
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name),
        c.email,
        c.customer_segment,
        c.signup_date;
END //
DELIMITER ;

-- Example:
-- CALL sp_customer_360_summary(5);


-- =====================================================================
-- PROCEDURE 4: Restock Inventory
--
-- Inputs:
-- p_product_id     = product being restocked
-- p_warehouse_id   = warehouse receiving stock
-- p_quantity_added = number of units added
--
-- What it does:
-- Adds stock quantity and updates last_restock_date.
--
-- Validation:
-- Prevents negative or zero restock quantities.
-- =====================================================================

DELIMITER //
CREATE PROCEDURE sp_restock_inventory(
    IN p_product_id INT,
    IN p_warehouse_id INT,
    IN p_quantity_added INT
)
BEGIN
    IF p_quantity_added IS NULL OR p_quantity_added <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'p_quantity_added must be greater than 0';
    END IF;

    UPDATE inventory
    SET
        stock_quantity = stock_quantity + p_quantity_added,
        last_restock_date = CURRENT_DATE
    WHERE product_id = p_product_id
      AND warehouse_id = p_warehouse_id;

    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No inventory row found for this product and warehouse';
    END IF;
END //
DELIMITER ;

-- Example:
-- CALL sp_restock_inventory(1, 1, 50);


-- =====================================================================
-- SECTION 5: TRIGGERS
-- Triggers run automatically when INSERT, UPDATE, or DELETE happens.
-- They are useful for data validation and automatic business rules.
-- =====================================================================


-- =====================================================================
-- TRIGGER 1: Validate Stock Before Order Item Insert
--
-- When it runs:
-- BEFORE INSERT on order_items.
--
-- Why this is useful:
-- Prevents selling more units than available in inventory.
--
-- How it works:
-- It calculates total stock available for the product across all warehouses.
-- If requested quantity is greater than stock, it stops the insert.
-- =====================================================================

DELIMITER //
CREATE TRIGGER trg_validate_stock_before_order_item
BEFORE INSERT ON order_items
FOR EACH ROW
BEGIN
    DECLARE v_available_stock INT DEFAULT 0;

    SELECT COALESCE(SUM(stock_quantity), 0)
    INTO v_available_stock
    FROM inventory
    WHERE product_id = NEW.product_id;

    IF NEW.quantity > v_available_stock THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Not enough inventory stock for this product';
    END IF;
END //
DELIMITER ;


-- =====================================================================
-- TRIGGER 2: Reduce Stock After Order Item Insert
--
-- When it runs:
-- AFTER INSERT on order_items.
--
-- Why this is useful:
-- Automatically updates inventory after a product is ordered.
--
-- Design note:
-- This simple version reduces stock from the warehouse with the highest
-- available stock for that product. In a real system, warehouse selection
-- may depend on delivery address, shipping cost, or fulfillment rules.
-- =====================================================================

DELIMITER //
CREATE TRIGGER trg_reduce_stock_after_order_item
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE inventory
    SET stock_quantity = GREATEST(stock_quantity - NEW.quantity, 0)
    WHERE product_id = NEW.product_id
    ORDER BY stock_quantity DESC
    LIMIT 1;
END //
DELIMITER ;


-- =====================================================================
-- TRIGGER 3: Validate Support Ticket Resolution Date
--
-- When it runs:
-- BEFORE UPDATE on support_tickets.
--
-- Business rule:
-- resolved_at cannot be earlier than created_at.
--
-- Why this is useful:
-- Protects data quality in support analytics.
-- =====================================================================

DELIMITER //
CREATE TRIGGER trg_validate_ticket_resolution
BEFORE UPDATE ON support_tickets
FOR EACH ROW
BEGIN
    IF NEW.resolved_at IS NOT NULL
       AND NEW.resolved_at < NEW.created_at THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'resolved_at cannot be earlier than created_at';
    END IF;
END //
DELIMITER ;


-- =====================================================================
-- TRIGGER 4: Log Order Status Changes
--
-- When it runs:
-- AFTER UPDATE on orders.
--
-- Why this is useful:
-- Creates an audit trail whenever an order status changes.
-- Audit logs are common in real companies because they help track changes,
-- investigate issues, and support reporting.
-- =====================================================================

CREATE TABLE IF NOT EXISTS order_status_audit (
    -- INT is used because audit_id is a numeric unique row identifier.
    audit_id    INT AUTO_INCREMENT PRIMARY KEY,

    -- INT stores the order whose status changed.
    order_id    INT NOT NULL,

    -- VARCHAR(20) is enough because status values are short words.
    old_status  VARCHAR(20),

    -- VARCHAR(20) stores the new status after update.
    new_status  VARCHAR(20),

    -- DATETIME stores exact date and time of the status change.
    changed_at  DATETIME DEFAULT CURRENT_TIMESTAMP,

    -- Foreign key keeps audit rows connected to valid orders.
    CONSTRAINT fk_audit_order
        FOREIGN KEY (order_id) REFERENCES orders(order_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DELIMITER //
CREATE TRIGGER trg_log_order_status_change
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
    IF OLD.order_status <> NEW.order_status THEN
        INSERT INTO order_status_audit(order_id, old_status, new_status)
        VALUES (NEW.order_id, OLD.order_status, NEW.order_status);
    END IF;
END //
DELIMITER ;


-- =====================================================================
-- SECTION 6: QUICK TEST COMMANDS
-- These are commented so they will not run automatically.
-- Remove the -- before a line when you want to test it.
-- =====================================================================

-- SELECT * FROM vw_monthly_sales_summary ORDER BY sales_month;
-- SELECT * FROM vw_customer_lifetime_value ORDER BY lifetime_value DESC LIMIT 10;
-- SELECT * FROM vw_product_performance ORDER BY revenue DESC LIMIT 10;
-- SELECT * FROM vw_inventory_reorder_alerts WHERE stock_status IN ('Out of Stock', 'Reorder Needed');
-- SELECT * FROM vw_order_fulfillment_status ORDER BY order_date DESC LIMIT 10;

-- SELECT fn_customer_total_spent(1) AS customer_1_total_spent;
-- SELECT fn_product_profit_margin(1) AS product_1_margin_pct;

-- CALL sp_get_customer_orders(1);
-- CALL sp_top_n_products(10);
-- CALL sp_customer_360_summary(1);
-- CALL sp_restock_inventory(1, 1, 10);

-- Test audit trigger:
-- UPDATE orders SET order_status = 'Cancelled' WHERE order_id = 1;
-- SELECT * FROM order_status_audit WHERE order_id = 1;


-- =====================================================================
-- End of file.
-- =====================================================================
