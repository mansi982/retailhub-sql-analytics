-- =====================================================================
--  RETAILHUB — E-COMMERCE SALES, INVENTORY & CUSTOMER ANALYTICS DB
--  File: 01_schema_fully_documented.sql
--  Database: MySQL 8.0+
--
--  Purpose:
--  This schema is designed for a Data Analyst portfolio project.
--  It shows normalized database design, primary keys, foreign keys,
--  constraints, audit columns, generated columns, and performance indexes.
--
--  Easy data type guide used in this file:
--  INT              : Whole numbers; best for IDs, counts, quantities, and capacity.
--  VARCHAR(n)       : Variable-length text; best for names, emails, phone numbers, codes, and short descriptions.
--  DECIMAL(12,2)    : Exact number with 2 decimals; best for money because it avoids floating-point rounding errors.
--  DECIMAL(5,2)     : Exact percentage value; allows values like 10.50 or 99.99.
--  DECIMAL(2,1)     : Small rating value; allows values like 4.5.
--  DATE             : Calendar date only; best for birth dates, launch dates, validity dates, and return dates.
--  DATETIME         : Date and time; best for order time, payment time, shipping time, and audit tracking.
--  BOOLEAN          : True/false value; used for yes/no flags like active product or default address.
--  ENUM             : Fixed list of allowed values; helps keep status/category data clean and consistent.
--
--  Constraint guide:
--  PRIMARY KEY      : Uniquely identifies each row.
--  FOREIGN KEY      : Connects related tables and protects relationship accuracy.
--  NOT NULL         : Makes important data mandatory.
--  UNIQUE           : Prevents duplicate values.
--  CHECK            : Validates business rules such as positive price or rating range.
--  DEFAULT          : Automatically fills a value when one is not provided.
--  ON DELETE        : Defines what happens to child records if a parent record is deleted.
--  ON UPDATE CASCADE: Keeps foreign-key values updated if the parent key changes.
-- =====================================================================

DROP DATABASE IF EXISTS retailhub_db;
CREATE DATABASE retailhub_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
USE retailhub_db;

-- =====================================================================
-- 1. DEPARTMENTS
-- Purpose: Stores company departments such as Sales, Support, Finance, etc.
-- Analytical use: Helps analyze employee count, salaries, and budgets by department.
-- =====================================================================
CREATE TABLE departments (
    -- INT is used for ID columns because it is compact, fast to join, and easy to index.
    -- AUTO_INCREMENT lets MySQL generate the next department ID automatically.
    department_id     INT AUTO_INCREMENT PRIMARY KEY,

    -- VARCHAR(50) is enough for short department names and saves space compared to TEXT.
    -- NOT NULL makes the department name required.
    -- UNIQUE prevents duplicate department names.
    department_name   VARCHAR(50)  NOT NULL UNIQUE,

    -- DECIMAL(12,2) is used for money/budget values to store exact currency amounts.
    -- DEFAULT 0 means a department can be created even if the budget is not known yet.
    -- CHECK prevents negative budget values.
    department_budget DECIMAL(12,2) DEFAULT 0 CHECK (department_budget >= 0),

    -- DATETIME stores when this record was created.
    -- CURRENT_TIMESTAMP automatically fills the current date and time.
    created_at        DATETIME DEFAULT CURRENT_TIMESTAMP,

    -- DATETIME stores when this record was last updated.
    -- ON UPDATE CURRENT_TIMESTAMP automatically refreshes this value after changes.
    updated_at        DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- =====================================================================
-- 2. CATEGORIES
-- Purpose: Stores main product categories such as Electronics, Fashion, Grocery.
-- Analytical use: Helps calculate revenue, orders, and product performance by category.
-- =====================================================================
CREATE TABLE categories (
    -- INT ID is efficient for joins between categories and subcategories.
    category_id   INT AUTO_INCREMENT PRIMARY KEY,

    -- VARCHAR(50) is suitable for short category names.
    -- UNIQUE avoids duplicate categories such as two rows named Electronics.
    category_name VARCHAR(50) NOT NULL UNIQUE,

    -- VARCHAR(255) stores a short optional description without using large TEXT storage.
    description   VARCHAR(255),

    -- Audit columns help track when records were created and modified.
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- =====================================================================
-- 3. SUBCATEGORIES
-- Purpose: Stores smaller groups inside categories, such as Mobiles under Electronics.
-- Analytical use: Enables detailed product and sales analysis below category level.
-- =====================================================================
CREATE TABLE subcategories (
    -- INT ID uniquely identifies each subcategory.
    subcategory_id   INT AUTO_INCREMENT PRIMARY KEY,

    -- INT is used because it references categories.category_id.
    -- NOT NULL means every subcategory must belong to a category.
    category_id      INT NOT NULL,

    -- VARCHAR(50) is enough for readable subcategory names.
    subcategory_name VARCHAR(50) NOT NULL,

    created_at       DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at       DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    -- FOREIGN KEY links each subcategory to a valid category.
    -- ON DELETE CASCADE means if a category is deleted, its subcategories are also deleted.
    -- This is acceptable because subcategories depend directly on categories.
    CONSTRAINT fk_subcat_category
        FOREIGN KEY (category_id) REFERENCES categories(category_id)
        ON DELETE CASCADE ON UPDATE CASCADE,

    -- UNIQUE(category_id, subcategory_name) prevents duplicate subcategory names inside the same category.
    CONSTRAINT uq_subcat UNIQUE (category_id, subcategory_name)
) ENGINE=InnoDB;

-- =====================================================================
-- 4. SUPPLIERS
-- Purpose: Stores companies or vendors that supply products.
-- Analytical use: Helps analyze supplier performance, ratings, and product sourcing.
-- =====================================================================
CREATE TABLE suppliers (
    -- INT ID is used as the primary key for supplier records.
    supplier_id   INT AUTO_INCREMENT PRIMARY KEY,

    -- VARCHAR(100) supports longer company names.
    supplier_name VARCHAR(100) NOT NULL,

    -- VARCHAR(100) stores email text; UNIQUE prevents duplicate supplier email records.
    contact_email VARCHAR(100) UNIQUE,

    -- VARCHAR(20) is used for phone numbers because phone numbers may contain +, spaces, or leading zeroes.
    contact_phone VARCHAR(20),

    -- VARCHAR(50) stores country names for geographic supplier analysis.
    country       VARCHAR(50),

    -- DECIMAL(2,1) stores small rating values like 4.5 exactly.
    -- CHECK ensures rating stays between 0 and 5.
    rating        DECIMAL(2,1) DEFAULT 3.0 CHECK (rating BETWEEN 0 AND 5),

    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- =====================================================================
-- 5. WAREHOUSES
-- Purpose: Stores warehouse locations where product inventory is kept.
-- Analytical use: Helps monitor stock levels, warehouse capacity, and fulfillment location.
-- =====================================================================
CREATE TABLE warehouses (
    -- INT ID uniquely identifies each warehouse.
    warehouse_id   INT AUTO_INCREMENT PRIMARY KEY,

    -- VARCHAR(50) is suitable for short warehouse names.
    warehouse_name VARCHAR(50) NOT NULL,

    -- VARCHAR is used for city/state because these are text values and may vary in length.
    city           VARCHAR(50),
    state          VARCHAR(50),

    -- INT is used because capacity is a whole number.
    -- CHECK prevents zero or negative capacity.
    capacity       INT CHECK (capacity > 0),

    created_at     DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at     DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- =====================================================================
-- 6. DELIVERY AGENTS
-- Purpose: Stores delivery staff or partners responsible for shipments.
-- Analytical use: Helps analyze delivery performance and agent ratings.
-- =====================================================================
CREATE TABLE delivery_agents (
    -- INT ID uniquely identifies each delivery agent.
    agent_id     INT AUTO_INCREMENT PRIMARY KEY,

    -- VARCHAR(100) allows full names.
    agent_name   VARCHAR(100) NOT NULL,

    -- VARCHAR(20) is better than INT for phone numbers because phone numbers are not used for math.
    phone        VARCHAR(20),

    -- ENUM restricts vehicle type to valid business choices only.
    vehicle_type ENUM('Bike','Van','Truck') DEFAULT 'Bike',

    -- DECIMAL(2,1) stores ratings such as 4.7 and CHECK keeps values valid.
    rating       DECIMAL(2,1) DEFAULT 4.0 CHECK (rating BETWEEN 0 AND 5),

    created_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at   DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- =====================================================================
-- 7. COUPONS
-- Purpose: Stores discount coupons used during orders.
-- Analytical use: Helps measure coupon usage, discount impact, and promotion performance.
-- =====================================================================
CREATE TABLE coupons (
    -- INT ID uniquely identifies each coupon.
    coupon_id         INT AUTO_INCREMENT PRIMARY KEY,

    -- VARCHAR(20) stores short coupon codes such as SAVE20.
    -- UNIQUE ensures the same coupon code cannot be reused accidentally.
    coupon_code       VARCHAR(20) NOT NULL UNIQUE,

    -- DECIMAL(5,2) stores percentage values like 15.50 exactly.
    -- CHECK limits the discount from 0 to 100 percent.
    discount_percent  DECIMAL(5,2) CHECK (discount_percent BETWEEN 0 AND 100),

    -- DECIMAL(12,2) stores minimum order amount accurately.
    min_order_value   DECIMAL(12,2) DEFAULT 0,

    -- DATE is used because coupon validity needs only calendar dates, not time.
    valid_from        DATE NOT NULL,
    valid_to          DATE NOT NULL,

    created_at        DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at        DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    -- Business rule: coupon end date must be after start date.
    CHECK (valid_to > valid_from)
) ENGINE=InnoDB;

-- =====================================================================
-- 8. CUSTOMERS
-- Purpose: Stores customer profile information.
-- Analytical use: Supports customer segmentation, retention, cohort, and demographic analysis.
-- =====================================================================
CREATE TABLE customers (
    -- INT ID is efficient for joining customers to orders, reviews, addresses, and support tickets.
    customer_id      INT AUTO_INCREMENT PRIMARY KEY,

    -- VARCHAR(50) stores names with reasonable length and better efficiency than TEXT.
    first_name       VARCHAR(50) NOT NULL,
    last_name        VARCHAR(50) NOT NULL,

    -- VARCHAR(100) stores email text; UNIQUE prevents duplicate customer accounts.
    email            VARCHAR(100) NOT NULL UNIQUE,

    -- VARCHAR(20) stores phone numbers safely, including leading zeroes and country codes.
    phone            VARCHAR(20),

    -- ENUM keeps gender values standardized for reporting.
    gender           ENUM('Male','Female','Other'),

    -- DATE is used because birth date does not require time.
    date_of_birth    DATE,

    -- DATE is used for signup date to support cohort and retention analysis.
    signup_date      DATE NOT NULL,

    -- ENUM keeps customer segment values clean and easy to group in analysis.
    customer_segment ENUM('Regular','Premium','VIP') DEFAULT 'Regular',

    created_at       DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at       DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- =====================================================================
-- 9. CUSTOMER ADDRESSES
-- Purpose: Stores one or more addresses for each customer.
-- Analytical use: Helps analyze sales by city/state and supports delivery address history.
-- =====================================================================
CREATE TABLE customer_addresses (
    -- INT ID uniquely identifies each address record.
    address_id   INT AUTO_INCREMENT PRIMARY KEY,

    -- INT links the address to a customer.
    customer_id  INT NOT NULL,

    -- VARCHAR(150) allows a detailed street/address line without needing TEXT.
    address_line VARCHAR(150) NOT NULL,

    -- VARCHAR is used for geographic text fields.
    city         VARCHAR(50),
    state        VARCHAR(50),

    -- VARCHAR(10) is used because pincodes/postcodes can have leading zeroes and are not used for math.
    pincode      VARCHAR(10),

    -- BOOLEAN stores true/false information for default address selection.
    is_default   BOOLEAN DEFAULT FALSE,

    created_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at   DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    -- ON DELETE CASCADE is acceptable because addresses depend on the customer profile.
    CONSTRAINT fk_addr_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- =====================================================================
-- 10. EMPLOYEES
-- Purpose: Stores employee details and reporting manager hierarchy.
-- Analytical use: Supports analysis by department, salary, job title, and manager structure.
-- =====================================================================
CREATE TABLE employees (
    -- INT ID uniquely identifies each employee.
    employee_id   INT AUTO_INCREMENT PRIMARY KEY,

    -- VARCHAR(50) stores employee first and last names.
    first_name    VARCHAR(50) NOT NULL,
    last_name     VARCHAR(50) NOT NULL,

    -- VARCHAR(100) stores email; UNIQUE avoids duplicate employee email accounts.
    email         VARCHAR(100) UNIQUE,

    -- INT references departments.department_id; NULL is allowed if department is unknown.
    department_id INT,

    -- INT self-references employees.employee_id to represent manager hierarchy.
    -- NULL is allowed for top-level managers.
    manager_id    INT NULL,

    -- VARCHAR(50) stores short job titles.
    job_title     VARCHAR(50),

    -- DATE is enough for hire date because time is not needed.
    hire_date     DATE,

    -- DECIMAL(12,2) stores salary accurately as a money value.
    salary        DECIMAL(12,2) CHECK (salary > 0),

    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    -- SET NULL preserves employee records if a department is removed.
    CONSTRAINT fk_emp_department
        FOREIGN KEY (department_id) REFERENCES departments(department_id)
        ON DELETE SET NULL ON UPDATE CASCADE,

    -- Self-referencing foreign key for manager relationship.
    CONSTRAINT fk_emp_manager
        FOREIGN KEY (manager_id) REFERENCES employees(employee_id)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- =====================================================================
-- 11. PRODUCTS
-- Purpose: Stores products sold by the e-commerce business.
-- Analytical use: Supports product sales, margin, category, supplier, and active/inactive analysis.
-- =====================================================================
CREATE TABLE products (
    -- INT ID uniquely identifies each product.
    product_id     INT AUTO_INCREMENT PRIMARY KEY,

    -- VARCHAR(100) allows meaningful product names.
    product_name   VARCHAR(100) NOT NULL,

    -- INT foreign keys connect product to subcategory and supplier.
    subcategory_id INT NOT NULL,
    supplier_id    INT NOT NULL,

    -- DECIMAL(12,2) stores selling price accurately.
    unit_price     DECIMAL(12,2) CHECK (unit_price > 0),

    -- DECIMAL(12,2) stores cost price accurately for profit/margin analysis.
    cost_price     DECIMAL(12,2) CHECK (cost_price > 0),

    -- DATE stores product launch date for lifecycle analysis.
    launch_date    DATE,

    -- BOOLEAN is used for active/inactive product status.
    is_active      BOOLEAN DEFAULT TRUE,

    created_at     DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at     DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    -- RESTRICT prevents deleting categories/suppliers that are still connected to products.
    CONSTRAINT fk_prod_subcat
        FOREIGN KEY (subcategory_id) REFERENCES subcategories(subcategory_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_prod_supplier
        FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    -- Business rule: selling price should not be lower than cost price.
    CONSTRAINT chk_price_margin CHECK (unit_price >= cost_price)
) ENGINE=InnoDB;

-- =====================================================================
-- 12. INVENTORY
-- Purpose: Tracks product stock quantity in each warehouse.
-- Analytical use: Supports inventory turnover, low-stock alerts, and warehouse utilization.
-- =====================================================================
CREATE TABLE inventory (
    -- INT ID uniquely identifies each inventory record.
    inventory_id      INT AUTO_INCREMENT PRIMARY KEY,

    -- INT foreign keys link inventory to product and warehouse.
    product_id        INT NOT NULL,
    warehouse_id      INT NOT NULL,

    -- INT is used because stock quantity is a whole number.
    -- DEFAULT 0 prevents NULL stock values and CHECK prevents negative stock.
    stock_quantity    INT NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),

    -- INT is used because reorder level is a whole-number threshold.
    reorder_level     INT DEFAULT 20 CHECK (reorder_level >= 0),

    -- DATE stores the last restock date without time.
    last_restock_date DATE,

    created_at        DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at        DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    -- Inventory depends on products and warehouses, so cascade is acceptable here.
    CONSTRAINT fk_inv_product
        FOREIGN KEY (product_id) REFERENCES products(product_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_inv_warehouse
        FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id)
        ON DELETE CASCADE ON UPDATE CASCADE,

    -- Prevents duplicate inventory row for the same product in the same warehouse.
    CONSTRAINT uq_inventory UNIQUE (product_id, warehouse_id)
) ENGINE=InnoDB;

-- =====================================================================
-- 13. ORDERS
-- Purpose: Stores customer order header information.
-- Analytical use: Core table for revenue, order trends, customer behavior, and sales performance.
-- Business rule: Customer order history is preserved; deleting customers is restricted.
-- =====================================================================
CREATE TABLE orders (
    -- INT ID uniquely identifies each order.
    order_id      INT AUTO_INCREMENT PRIMARY KEY,

    -- INT links each order to a customer.
    customer_id   INT NOT NULL,

    -- INT links the order to the employee who handled it; NULL is allowed if not assigned.
    employee_id   INT NULL,

    -- INT links order to delivery address used at checkout.
    address_id    INT NOT NULL,

    -- DATETIME captures exact order date and time, useful for daily/hourly sales analysis.
    order_date    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- ENUM keeps order status values standardized.
    order_status  ENUM('Pending','Processing','Shipped','Delivered','Cancelled') DEFAULT 'Pending',

    -- DECIMAL(12,2) stores total order amount exactly.
    total_amount  DECIMAL(12,2) DEFAULT 0 CHECK (total_amount >= 0),

    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    -- RESTRICT prevents deleting a customer if historical orders exist.
    CONSTRAINT fk_order_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    -- SET NULL keeps order history even if employee record is removed.
    CONSTRAINT fk_order_employee
        FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
        ON DELETE SET NULL ON UPDATE CASCADE,

    -- RESTRICT protects historical delivery address used for order records.
    CONSTRAINT fk_order_address
        FOREIGN KEY (address_id) REFERENCES customer_addresses(address_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- =====================================================================
-- 14. ORDER ITEMS
-- Purpose: Stores individual products purchased inside each order.
-- Analytical use: Main table for product-level sales, quantity sold, revenue, and basket analysis.
-- =====================================================================
CREATE TABLE order_items (
    -- INT ID uniquely identifies each order line item.
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,

    -- INT links each line item to an order.
    order_id      INT NOT NULL,

    -- INT links each line item to a product.
    product_id    INT NOT NULL,

    -- INT is used because quantity is a whole number.
    quantity      INT NOT NULL CHECK (quantity > 0),

    -- DECIMAL(12,2) stores the product price at the time of order.
    unit_price    DECIMAL(12,2) NOT NULL CHECK (unit_price > 0),

    -- GENERATED ALWAYS calculates subtotal automatically as quantity * unit_price.
    -- STORED saves the calculated value for faster reporting queries.
    subtotal      DECIMAL(12,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,

    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    -- CASCADE removes order items if the parent order is deleted.
    CONSTRAINT fk_oi_order
        FOREIGN KEY (order_id) REFERENCES orders(order_id)
        ON DELETE CASCADE ON UPDATE CASCADE,

    -- RESTRICT prevents deleting products that exist in order history.
    CONSTRAINT fk_oi_product
        FOREIGN KEY (product_id) REFERENCES products(product_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- =====================================================================
-- 15. PAYMENTS
-- Purpose: Stores payment details for orders.
-- Analytical use: Supports payment success rate, method usage, refunds, and pending payment analysis.
-- Business rule: One payment record per order.
-- =====================================================================
CREATE TABLE payments (
    -- INT ID uniquely identifies each payment.
    payment_id     INT AUTO_INCREMENT PRIMARY KEY,

    -- INT links payment to order; UNIQUE enforces one payment row per order.
    order_id       INT NOT NULL UNIQUE,

    -- DATETIME stores exact payment date and time.
    payment_date   DATETIME,

    -- ENUM standardizes payment methods for clean grouping in analysis.
    payment_method ENUM('Credit Card','Debit Card','UPI','Net Banking','COD') NOT NULL,

    -- DECIMAL(12,2) stores payment amount exactly.
    amount         DECIMAL(12,2) CHECK (amount >= 0),

    -- ENUM keeps payment statuses clean and avoids spelling variations.
    payment_status ENUM('Success','Failed','Refunded','Pending') DEFAULT 'Pending',

    created_at     DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at     DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    -- Payment belongs to order; if an order is deleted, payment can also be removed.
    CONSTRAINT fk_pay_order
        FOREIGN KEY (order_id) REFERENCES orders(order_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- =====================================================================
-- 16. SHIPMENTS
-- Purpose: Stores shipment and delivery information for each order.
-- Analytical use: Supports delivery time analysis, delayed shipment tracking, and agent performance.
-- Business rule: One shipment record per order.
-- =====================================================================
CREATE TABLE shipments (
    -- INT ID uniquely identifies each shipment.
    shipment_id     INT AUTO_INCREMENT PRIMARY KEY,

    -- INT links shipment to order; UNIQUE enforces one shipment per order.
    order_id        INT NOT NULL UNIQUE,

    -- INT links shipment to warehouse and delivery agent.
    warehouse_id    INT NOT NULL,
    agent_id        INT NOT NULL,

    -- DATETIME stores exact shipping and delivery timestamps.
    shipped_date    DATETIME NULL,
    delivery_date   DATETIME NULL,

    -- ENUM standardizes shipment status values.
    shipment_status ENUM('Preparing','In Transit','Delivered','Delayed','Returned') DEFAULT 'Preparing',

    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    -- Shipment depends on order, so cascade is acceptable here.
    CONSTRAINT fk_ship_order
        FOREIGN KEY (order_id) REFERENCES orders(order_id)
        ON DELETE CASCADE ON UPDATE CASCADE,

    -- RESTRICT protects warehouse/agent records if shipments reference them.
    CONSTRAINT fk_ship_warehouse
        FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_ship_agent
        FOREIGN KEY (agent_id) REFERENCES delivery_agents(agent_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    -- Business rule: delivery date cannot be before shipped date.
    CHECK (delivery_date IS NULL OR shipped_date IS NULL OR delivery_date >= shipped_date)
) ENGINE=InnoDB;

-- =====================================================================
-- 17. RETURNS
-- Purpose: Stores returned order items and refund information.
-- Analytical use: Supports return rate, refund amount, product quality, and customer issue analysis.
-- =====================================================================
CREATE TABLE returns (
    -- INT ID uniquely identifies each return record.
    return_id      INT AUTO_INCREMENT PRIMARY KEY,

    -- INT links return to the exact product line that was returned.
    order_item_id  INT NOT NULL,

    -- DATE is enough because return analysis usually needs the return day, not exact time.
    return_date    DATE NOT NULL,

    -- VARCHAR(255) stores a short reason for the return.
    reason         VARCHAR(255),

    -- DECIMAL(12,2) stores refund amount accurately.
    refund_amount  DECIMAL(12,2) CHECK (refund_amount >= 0),

    -- ENUM standardizes return workflow status values.
    return_status  ENUM('Requested','Approved','Rejected','Completed') DEFAULT 'Requested',

    created_at     DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at     DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    -- Return depends on order item, so cascade is acceptable here.
    CONSTRAINT fk_ret_orderitem
        FOREIGN KEY (order_item_id) REFERENCES order_items(order_item_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- =====================================================================
-- 18. REVIEWS
-- Purpose: Stores customer ratings and review comments for products.
-- Analytical use: Supports product satisfaction, rating trends, and customer feedback analysis.
-- Business rule: One review per customer per product.
-- =====================================================================
CREATE TABLE reviews (
    -- INT ID uniquely identifies each review.
    review_id   INT AUTO_INCREMENT PRIMARY KEY,

    -- INT foreign keys connect the review to product and customer.
    product_id  INT NOT NULL,
    customer_id INT NOT NULL,

    -- INT is used because ratings are whole numbers from 1 to 5.
    rating      INT NOT NULL CHECK (rating BETWEEN 1 AND 5),

    -- VARCHAR(500) allows a longer but still controlled review comment.
    review_text VARCHAR(500),

    -- DATE stores when the review was submitted.
    review_date DATE,

    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    -- RESTRICT protects product/customer history used for reviews.
    CONSTRAINT fk_rev_product
        FOREIGN KEY (product_id) REFERENCES products(product_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_rev_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    -- Prevents a customer from reviewing the same product multiple times.
    CONSTRAINT uq_review UNIQUE (product_id, customer_id)
) ENGINE=InnoDB;

-- =====================================================================
-- 19. ORDER_COUPONS
-- Purpose: Bridge table that connects orders and coupons.
-- Analytical use: Supports analysis of coupon usage and discount impact per order.
-- Business rule: Many orders can use many coupons, so a junction table is needed.
-- =====================================================================
CREATE TABLE order_coupons (
    -- INT foreign key to orders; part of composite primary key.
    order_id          INT NOT NULL,

    -- INT foreign key to coupons; part of composite primary key.
    coupon_id         INT NOT NULL,

    -- DECIMAL(12,2) stores the actual discount amount applied to the order.
    discount_applied  DECIMAL(12,2) CHECK (discount_applied >= 0),

    -- Composite primary key prevents the same coupon being attached twice to the same order.
    PRIMARY KEY (order_id, coupon_id),

    CONSTRAINT fk_oc_order
        FOREIGN KEY (order_id) REFERENCES orders(order_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_oc_coupon
        FOREIGN KEY (coupon_id) REFERENCES coupons(coupon_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- =====================================================================
-- 20. WISHLIST
-- Purpose: Stores products customers have saved for later.
-- Analytical use: Supports demand prediction and interest analysis before purchase.
-- =====================================================================
CREATE TABLE wishlist (
    -- INT ID uniquely identifies each wishlist row.
    wishlist_id INT AUTO_INCREMENT PRIMARY KEY,

    -- INT foreign keys connect customer and product.
    customer_id INT NOT NULL,
    product_id  INT NOT NULL,

    -- DATE stores when the product was added to wishlist.
    added_date  DATE,

    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    -- Wishlist records depend on customers/products, so cascade is acceptable here.
    CONSTRAINT fk_wish_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_wish_product
        FOREIGN KEY (product_id) REFERENCES products(product_id)
        ON DELETE CASCADE ON UPDATE CASCADE,

    -- Prevents duplicate wishlist entries for the same product by the same customer.
    CONSTRAINT uq_wishlist UNIQUE (customer_id, product_id)
) ENGINE=InnoDB;

-- =====================================================================
-- 21. CART ITEMS
-- Purpose: Stores products currently placed in customer shopping carts.
-- Analytical use: Supports cart abandonment and product interest analysis.
-- =====================================================================
CREATE TABLE cart_items (
    -- INT ID uniquely identifies each cart item.
    cart_item_id INT AUTO_INCREMENT PRIMARY KEY,

    -- INT foreign keys connect cart item to customer and product.
    customer_id  INT NOT NULL,
    product_id   INT NOT NULL,

    -- INT is used because quantity is a whole number.
    quantity     INT NOT NULL CHECK (quantity > 0),

    -- DATETIME stores exact time item was added to cart.
    added_date   DATETIME DEFAULT CURRENT_TIMESTAMP,

    created_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at   DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    -- Cart items depend on customer/product, so cascade is acceptable here.
    CONSTRAINT fk_cart_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_cart_product
        FOREIGN KEY (product_id) REFERENCES products(product_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- =====================================================================
-- 22. SUPPORT TICKETS
-- Purpose: Stores customer support issues related to orders, products, payments, refunds, etc.
-- Analytical use: Supports issue trend analysis, resolution time, and support workload reporting.
-- =====================================================================
CREATE TABLE support_tickets (
    -- INT ID uniquely identifies each support ticket.
    ticket_id     INT AUTO_INCREMENT PRIMARY KEY,

    -- INT links support ticket to customer.
    customer_id   INT NOT NULL,

    -- INT optionally links ticket to an order; NULL is allowed for general support issues.
    order_id      INT NULL,

    -- INT optionally links ticket to employee handling the issue.
    employee_id   INT NULL,

    -- ENUM keeps issue types standardized for reporting.
    issue_type    ENUM('Delivery','Product','Payment','Refund','Other'),

    -- ENUM keeps ticket status workflow clean and consistent.
    ticket_status ENUM('Open','In Progress','Resolved','Closed') DEFAULT 'Open',

    -- DATETIME captures exact ticket creation time.
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP,

    -- DATETIME stores exact resolution time; NULL means not resolved yet.
    resolved_at   DATETIME NULL,

    -- DATETIME tracks last ticket update.
    updated_at    DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    -- RESTRICT protects customer support history.
    CONSTRAINT fk_tkt_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    -- SET NULL keeps ticket even if related order/employee is removed.
    CONSTRAINT fk_tkt_order
        FOREIGN KEY (order_id) REFERENCES orders(order_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_tkt_employee
        FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- =====================================================================
-- INDEXES
-- Purpose: Indexes improve SELECT query performance for joins, filters, grouping, and sorting.
-- Note: Too many indexes can slow INSERT/UPDATE operations, so these are chosen for common analytics queries.
-- =====================================================================

-- Speeds up finding all addresses for a customer.
CREATE INDEX idx_customer_addresses_customer ON customer_addresses(customer_id);

-- Speeds up customer order history and customer-level revenue analysis.
CREATE INDEX idx_orders_customer      ON orders(customer_id);

-- Speeds up daily, monthly, and yearly sales trend analysis.
CREATE INDEX idx_orders_date          ON orders(order_date);

-- Speeds up filtering orders by Pending, Delivered, Cancelled, etc.
CREATE INDEX idx_orders_status        ON orders(order_status);

-- Speeds up joining order_items with orders.
CREATE INDEX idx_orderitems_order     ON order_items(order_id);

-- Speeds up product-level sales analysis.
CREATE INDEX idx_orderitems_product   ON order_items(product_id);

-- Speeds up category/subcategory product analysis.
CREATE INDEX idx_products_subcat      ON products(subcategory_id);

-- Speeds up review analysis by product.
CREATE INDEX idx_reviews_product      ON reviews(product_id);

-- Speeds up stock lookup by product.
CREATE INDEX idx_inventory_product    ON inventory(product_id);

-- Speeds up payment success/failure/refund analysis.
CREATE INDEX idx_payments_status      ON payments(payment_status);

-- Speeds up customer segmentation analysis.
CREATE INDEX idx_customers_segment    ON customers(customer_segment);

-- Speeds up employee-wise order handling analysis.
CREATE INDEX idx_orders_employee      ON orders(employee_id);

-- Speeds up joining orders with customer address table.
CREATE INDEX idx_orders_address       ON orders(address_id);

-- Speeds up employee analysis by department.
CREATE INDEX idx_employees_department ON employees(department_id);

-- Speeds up manager hierarchy queries.
CREATE INDEX idx_employees_manager    ON employees(manager_id);

-- Speeds up supplier-level product analysis.
CREATE INDEX idx_products_supplier    ON products(supplier_id);

-- Speeds up warehouse-level inventory analysis.
CREATE INDEX idx_inventory_warehouse  ON inventory(warehouse_id);

-- Speeds up delivery agent performance analysis.
CREATE INDEX idx_shipments_agent      ON shipments(agent_id);

-- Speeds up shipment analysis by warehouse.
CREATE INDEX idx_shipments_warehouse  ON shipments(warehouse_id);

-- Speeds up return analysis by order item.
CREATE INDEX idx_returns_orderitem    ON returns(order_item_id);

-- Speeds up support tickets by customer.
CREATE INDEX idx_support_customer     ON support_tickets(customer_id);

-- Speeds up support tickets related to orders.
CREATE INDEX idx_support_order        ON support_tickets(order_id);

-- Speeds up support workload analysis by employee.
CREATE INDEX idx_support_employee     ON support_tickets(employee_id);

-- =====================================================================
-- End of fully documented schema
-- =====================================================================
