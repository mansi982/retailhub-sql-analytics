-- =====================================================================
-- RETAILHUB — E-COMMERCE SALES, INVENTORY & CUSTOMER ANALYTICS DB
-- File: 02_insert_data_documented.sql
-- Purpose: Clean sample data for all 22 tables.
-- Rows: 25 rows per table, designed for SQL practice and portfolio demos.
-- How to use: Run 01_schema_fully_documented.sql first, then run this file.
-- Database: MySQL / MariaDB style SQL.
-- =====================================================================

USE retailhub_db;

-- This makes the script re-runnable during practice.
-- We temporarily disable foreign key checks only for cleanup, then insert data in the correct parent-to-child order.
SET FOREIGN_KEY_CHECKS = 0;

-- Delete child tables first because they depend on parent tables through foreign keys.
TRUNCATE TABLE support_tickets;
TRUNCATE TABLE cart_items;
TRUNCATE TABLE wishlist;
TRUNCATE TABLE order_coupons;
TRUNCATE TABLE reviews;
TRUNCATE TABLE returns;
TRUNCATE TABLE shipments;
TRUNCATE TABLE payments;
TRUNCATE TABLE order_items;
TRUNCATE TABLE orders;
TRUNCATE TABLE inventory;
TRUNCATE TABLE products;
TRUNCATE TABLE employees;
TRUNCATE TABLE customer_addresses;
TRUNCATE TABLE customers;
TRUNCATE TABLE coupons;
TRUNCATE TABLE delivery_agents;
TRUNCATE TABLE warehouses;
TRUNCATE TABLE suppliers;
TRUNCATE TABLE subcategories;
TRUNCATE TABLE categories;
TRUNCATE TABLE departments;

SET FOREIGN_KEY_CHECKS = 1;

START TRANSACTION;

-- ---------------------------------------------------------------------
-- 1. departments
-- Parent table: No foreign keys.
-- Why this data matters: Departments help analyze employee cost, team structure, and business spending.
-- Columns: department_id is fixed here so child tables can safely reference it.
-- ---------------------------------------------------------------------
INSERT INTO departments (department_id, department_name, department_budget) VALUES
(1, 'Sales', 62500.00),
(2, 'Customer Support', 75000.00),
(3, 'Warehouse Operations', 87500.00),
(4, 'Marketing', 100000.00),
(5, 'IT', 112500.00),
(6, 'Procurement', 125000.00),
(7, 'Finance', 137500.00),
(8, 'Human Resources', 150000.00),
(9, 'Data Analytics', 162500.00),
(10, 'Product Management', 175000.00),
(11, 'Quality Assurance', 187500.00),
(12, 'Logistics', 200000.00),
(13, 'Vendor Management', 212500.00),
(14, 'Customer Experience', 225000.00),
(15, 'Business Intelligence', 237500.00),
(16, 'Operations', 250000.00),
(17, 'Legal', 262500.00),
(18, 'Training', 275000.00),
(19, 'Security', 287500.00),
(20, 'Merchandising', 300000.00),
(21, 'Returns Management', 312500.00),
(22, 'Fulfillment', 325000.00),
(23, 'Pricing Strategy', 337500.00),
(24, 'CRM', 350000.00),
(25, 'Executive', 362500.00);

-- 2. categories
-- Parent table for subcategories. Each category name is unique for clean reporting.
INSERT INTO categories (category_id, category_name, description) VALUES
(1, 'Electronics', 'Main category for electronics products'),
(2, 'Fashion', 'Main category for fashion products'),
(3, 'Home & Kitchen', 'Main category for home & kitchen products'),
(4, 'Sports', 'Main category for sports products'),
(5, 'Beauty', 'Main category for beauty products'),
(6, 'Books', 'Main category for books products'),
(7, 'Grocery', 'Main category for grocery products'),
(8, 'Toys', 'Main category for toys products'),
(9, 'Automotive', 'Main category for automotive products'),
(10, 'Health', 'Main category for health products'),
(11, 'Office Supplies', 'Main category for office supplies products'),
(12, 'Pet Supplies', 'Main category for pet supplies products'),
(13, 'Garden', 'Main category for garden products'),
(14, 'Jewelry', 'Main category for jewelry products'),
(15, 'Baby Products', 'Main category for baby products products'),
(16, 'Music', 'Main category for music products'),
(17, 'Movies', 'Main category for movies products'),
(18, 'Gaming', 'Main category for gaming products'),
(19, 'Travel', 'Main category for travel products'),
(20, 'Footwear', 'Main category for footwear products'),
(21, 'Furniture', 'Main category for furniture products'),
(22, 'Appliances', 'Main category for appliances products'),
(23, 'Stationery', 'Main category for stationery products'),
(24, 'Fitness', 'Main category for fitness products'),
(25, 'Smart Home', 'Main category for smart home products');

-- 3. subcategories
-- Child table: category_id must already exist in categories.
-- One subcategory is added under each category to keep the data easy to understand.
INSERT INTO subcategories (subcategory_id, category_id, subcategory_name) VALUES
(1, 1, 'Mobiles'),
(2, 2, 'Laptops'),
(3, 3, 'Cookware'),
(4, 4, 'Mens Wear'),
(5, 5, 'Skincare'),
(6, 6, 'Fiction'),
(7, 7, 'Snacks'),
(8, 8, 'Educational Toys'),
(9, 9, 'Car Accessories'),
(10, 10, 'Supplements'),
(11, 11, 'Printers'),
(12, 12, 'Dog Food'),
(13, 13, 'Planters'),
(14, 14, 'Rings'),
(15, 15, 'Diapers'),
(16, 16, 'Guitars'),
(17, 17, 'Action Movies'),
(18, 18, 'Consoles'),
(19, 19, 'Backpacks'),
(20, 20, 'Running Shoes'),
(21, 21, 'Sofas'),
(22, 22, 'Refrigerators'),
(23, 23, 'Notebooks'),
(24, 24, 'Yoga Gear'),
(25, 25, 'Smart Speakers');

-- 4. suppliers
-- Parent table for products. Supplier ratings allow supplier-performance analysis.
INSERT INTO suppliers (supplier_id, supplier_name, contact_email, contact_phone, country, rating) VALUES
(1, 'Supplier 01 Pvt Ltd', 'supplier01@retailhubdemo.com', '+91-9000000001', 'India', 3.1),
(2, 'Supplier 02 Pvt Ltd', 'supplier02@retailhubdemo.com', '+91-9000000002', 'USA', 3.2),
(3, 'Supplier 03 Pvt Ltd', 'supplier03@retailhubdemo.com', '+91-9000000003', 'China', 3.3),
(4, 'Supplier 04 Pvt Ltd', 'supplier04@retailhubdemo.com', '+91-9000000004', 'Germany', 3.4),
(5, 'Supplier 05 Pvt Ltd', 'supplier05@retailhubdemo.com', '+91-9000000005', 'Vietnam', 3.5),
(6, 'Supplier 06 Pvt Ltd', 'supplier06@retailhubdemo.com', '+91-9000000006', 'India', 3.6),
(7, 'Supplier 07 Pvt Ltd', 'supplier07@retailhubdemo.com', '+91-9000000007', 'USA', 3.7),
(8, 'Supplier 08 Pvt Ltd', 'supplier08@retailhubdemo.com', '+91-9000000008', 'China', 3.8),
(9, 'Supplier 09 Pvt Ltd', 'supplier09@retailhubdemo.com', '+91-9000000009', 'Germany', 3.9),
(10, 'Supplier 10 Pvt Ltd', 'supplier10@retailhubdemo.com', '+91-9000000010', 'Vietnam', 4.0),
(11, 'Supplier 11 Pvt Ltd', 'supplier11@retailhubdemo.com', '+91-9000000011', 'India', 4.1),
(12, 'Supplier 12 Pvt Ltd', 'supplier12@retailhubdemo.com', '+91-9000000012', 'USA', 4.2),
(13, 'Supplier 13 Pvt Ltd', 'supplier13@retailhubdemo.com', '+91-9000000013', 'China', 4.3),
(14, 'Supplier 14 Pvt Ltd', 'supplier14@retailhubdemo.com', '+91-9000000014', 'Germany', 4.4),
(15, 'Supplier 15 Pvt Ltd', 'supplier15@retailhubdemo.com', '+91-9000000015', 'Vietnam', 4.5),
(16, 'Supplier 16 Pvt Ltd', 'supplier16@retailhubdemo.com', '+91-9000000016', 'India', 4.6),
(17, 'Supplier 17 Pvt Ltd', 'supplier17@retailhubdemo.com', '+91-9000000017', 'USA', 4.7),
(18, 'Supplier 18 Pvt Ltd', 'supplier18@retailhubdemo.com', '+91-9000000018', 'China', 4.8),
(19, 'Supplier 19 Pvt Ltd', 'supplier19@retailhubdemo.com', '+91-9000000019', 'Germany', 4.9),
(20, 'Supplier 20 Pvt Ltd', 'supplier20@retailhubdemo.com', '+91-9000000020', 'Vietnam', 3.0),
(21, 'Supplier 21 Pvt Ltd', 'supplier21@retailhubdemo.com', '+91-9000000021', 'India', 3.1),
(22, 'Supplier 22 Pvt Ltd', 'supplier22@retailhubdemo.com', '+91-9000000022', 'USA', 3.2),
(23, 'Supplier 23 Pvt Ltd', 'supplier23@retailhubdemo.com', '+91-9000000023', 'China', 3.3),
(24, 'Supplier 24 Pvt Ltd', 'supplier24@retailhubdemo.com', '+91-9000000024', 'Germany', 3.4),
(25, 'Supplier 25 Pvt Ltd', 'supplier25@retailhubdemo.com', '+91-9000000025', 'Vietnam', 3.5);

-- 5. warehouses
-- Parent table for inventory and shipments. Capacity supports warehouse utilization analysis.
INSERT INTO warehouses (warehouse_id, warehouse_name, city, state, capacity) VALUES
(1, 'RH Warehouse 01', 'Delhi', 'Delhi', 5350),
(2, 'RH Warehouse 02', 'Mumbai', 'Maharashtra', 5700),
(3, 'RH Warehouse 03', 'Bengaluru', 'Karnataka', 6050),
(4, 'RH Warehouse 04', 'Kolkata', 'West Bengal', 6400),
(5, 'RH Warehouse 05', 'Chennai', 'Tamil Nadu', 6750),
(6, 'RH Warehouse 06', 'Hyderabad', 'Telangana', 7100),
(7, 'RH Warehouse 07', 'Pune', 'Maharashtra', 7450),
(8, 'RH Warehouse 08', 'Ahmedabad', 'Gujarat', 7800),
(9, 'RH Warehouse 09', 'Jaipur', 'Rajasthan', 8150),
(10, 'RH Warehouse 10', 'Lucknow', 'Uttar Pradesh', 8500),
(11, 'RH Warehouse 11', 'Kochi', 'Kerala', 8850),
(12, 'RH Warehouse 12', 'Indore', 'Madhya Pradesh', 9200),
(13, 'RH Warehouse 13', 'Nagpur', 'Maharashtra', 9550),
(14, 'RH Warehouse 14', 'Surat', 'Gujarat', 9900),
(15, 'RH Warehouse 15', 'Patna', 'Bihar', 10250),
(16, 'RH Warehouse 16', 'Bhopal', 'Madhya Pradesh', 10600),
(17, 'RH Warehouse 17', 'Noida', 'Uttar Pradesh', 10950),
(18, 'RH Warehouse 18', 'Gurugram', 'Haryana', 11300),
(19, 'RH Warehouse 19', 'Coimbatore', 'Tamil Nadu', 11650),
(20, 'RH Warehouse 20', 'Visakhapatnam', 'Andhra Pradesh', 12000),
(21, 'RH Warehouse 21', 'Mysuru', 'Karnataka', 12350),
(22, 'RH Warehouse 22', 'Ranchi', 'Jharkhand', 12700),
(23, 'RH Warehouse 23', 'Chandigarh', 'Chandigarh', 13050),
(24, 'RH Warehouse 24', 'Guwahati', 'Assam', 13400),
(25, 'RH Warehouse 25', 'Goa', 'Goa', 13750);

-- 6. delivery_agents
-- Parent table for shipments. Vehicle type and rating help analyze delivery performance.
INSERT INTO delivery_agents (agent_id, agent_name, phone, vehicle_type, rating) VALUES
(1, 'Delivery Agent 01', '+91-8100000001', 'Bike', 3.6),
(2, 'Delivery Agent 02', '+91-8100000002', 'Van', 3.7),
(3, 'Delivery Agent 03', '+91-8100000003', 'Truck', 3.8),
(4, 'Delivery Agent 04', '+91-8100000004', 'Bike', 3.9),
(5, 'Delivery Agent 05', '+91-8100000005', 'Van', 4.0),
(6, 'Delivery Agent 06', '+91-8100000006', 'Truck', 4.1),
(7, 'Delivery Agent 07', '+91-8100000007', 'Bike', 4.2),
(8, 'Delivery Agent 08', '+91-8100000008', 'Van', 4.3),
(9, 'Delivery Agent 09', '+91-8100000009', 'Truck', 4.4),
(10, 'Delivery Agent 10', '+91-8100000010', 'Bike', 4.5),
(11, 'Delivery Agent 11', '+91-8100000011', 'Van', 4.6),
(12, 'Delivery Agent 12', '+91-8100000012', 'Truck', 4.7),
(13, 'Delivery Agent 13', '+91-8100000013', 'Bike', 4.8),
(14, 'Delivery Agent 14', '+91-8100000014', 'Van', 4.9),
(15, 'Delivery Agent 15', '+91-8100000015', 'Truck', 3.5),
(16, 'Delivery Agent 16', '+91-8100000016', 'Bike', 3.6),
(17, 'Delivery Agent 17', '+91-8100000017', 'Van', 3.7),
(18, 'Delivery Agent 18', '+91-8100000018', 'Truck', 3.8),
(19, 'Delivery Agent 19', '+91-8100000019', 'Bike', 3.9),
(20, 'Delivery Agent 20', '+91-8100000020', 'Van', 4.0),
(21, 'Delivery Agent 21', '+91-8100000021', 'Truck', 4.1),
(22, 'Delivery Agent 22', '+91-8100000022', 'Bike', 4.2),
(23, 'Delivery Agent 23', '+91-8100000023', 'Van', 4.3),
(24, 'Delivery Agent 24', '+91-8100000024', 'Truck', 4.4),
(25, 'Delivery Agent 25', '+91-8100000025', 'Bike', 4.5);

-- 7. coupons
-- Parent table for order_coupons. Dates and discount values allow promotion analysis.
INSERT INTO coupons (coupon_id, coupon_code, discount_percent, min_order_value, valid_from, valid_to) VALUES
(1, 'SAVE01', 6.00, 500.00, '2026-01-02', '2026-12-02'),
(2, 'SAVE02', 7.00, 1000.00, '2026-01-03', '2026-12-03'),
(3, 'SAVE03', 8.00, 1500.00, '2026-01-04', '2026-12-04'),
(4, 'SAVE04', 9.00, 2000.00, '2026-01-05', '2026-12-05'),
(5, 'SAVE05', 10.00, 0.00, '2026-01-06', '2026-12-06'),
(6, 'SAVE06', 11.00, 500.00, '2026-01-07', '2026-12-07'),
(7, 'SAVE07', 12.00, 1000.00, '2026-01-08', '2026-12-08'),
(8, 'SAVE08', 13.00, 1500.00, '2026-01-09', '2026-12-09'),
(9, 'SAVE09', 14.00, 2000.00, '2026-01-10', '2026-12-10'),
(10, 'SAVE10', 15.00, 0.00, '2026-01-11', '2026-12-11'),
(11, 'SAVE11', 16.00, 500.00, '2026-01-12', '2026-12-12'),
(12, 'SAVE12', 17.00, 1000.00, '2026-01-13', '2026-12-13'),
(13, 'SAVE13', 18.00, 1500.00, '2026-01-14', '2026-12-14'),
(14, 'SAVE14', 19.00, 2000.00, '2026-01-15', '2026-12-15'),
(15, 'SAVE15', 20.00, 0.00, '2026-01-16', '2026-12-16'),
(16, 'SAVE16', 21.00, 500.00, '2026-01-17', '2026-12-17'),
(17, 'SAVE17', 22.00, 1000.00, '2026-01-18', '2026-12-18'),
(18, 'SAVE18', 23.00, 1500.00, '2026-01-19', '2026-12-19'),
(19, 'SAVE19', 24.00, 2000.00, '2026-01-20', '2026-12-20'),
(20, 'SAVE20', 5.00, 0.00, '2026-01-21', '2026-12-21'),
(21, 'SAVE21', 6.00, 500.00, '2026-01-22', '2026-12-22'),
(22, 'SAVE22', 7.00, 1000.00, '2026-01-23', '2026-12-23'),
(23, 'SAVE23', 8.00, 1500.00, '2026-01-24', '2026-12-24'),
(24, 'SAVE24', 9.00, 2000.00, '2026-01-25', '2026-12-25'),
(25, 'SAVE25', 10.00, 0.00, '2026-01-26', '2026-12-26');

-- 8. customers
-- Parent table for orders, reviews, carts, wishlists, addresses, and support tickets.
-- Customer segment supports grouping customers in analysis.
INSERT INTO customers (customer_id, first_name, last_name, email, phone, gender, date_of_birth, signup_date, customer_segment) VALUES
(1, 'Aarav', 'Sharma', 'customer01@retailhubdemo.com', '+91-9876500001', 'Male', '1986-02-02', '2026-02-02', 'Regular'),
(2, 'Vivaan', 'Verma', 'customer02@retailhubdemo.com', '+91-9876500002', 'Female', '1987-03-03', '2026-03-03', 'Premium'),
(3, 'Aditya', 'Patel', 'customer03@retailhubdemo.com', '+91-9876500003', 'Other', '1988-04-04', '2026-04-04', 'VIP'),
(4, 'Vihaan', 'Reddy', 'customer04@retailhubdemo.com', '+91-9876500004', 'Male', '1989-05-05', '2026-05-05', 'Regular'),
(5, 'Arjun', 'Nair', 'customer05@retailhubdemo.com', '+91-9876500005', 'Female', '1990-06-06', '2026-06-06', 'Premium'),
(6, 'Sai', 'Singh', 'customer06@retailhubdemo.com', '+91-9876500006', 'Other', '1991-07-07', '2026-01-07', 'VIP'),
(7, 'Reyansh', 'Gupta', 'customer07@retailhubdemo.com', '+91-9876500007', 'Male', '1992-08-08', '2026-02-08', 'Regular'),
(8, 'Ayaan', 'Mehta', 'customer08@retailhubdemo.com', '+91-9876500008', 'Female', '1993-09-09', '2026-03-09', 'Premium'),
(9, 'Krishna', 'Khan', 'customer09@retailhubdemo.com', '+91-9876500009', 'Other', '1994-01-10', '2026-04-10', 'VIP'),
(10, 'Ishaan', 'Joshi', 'customer10@retailhubdemo.com', '+91-9876500010', 'Male', '1995-02-11', '2026-05-11', 'Regular'),
(11, 'Anaya', 'Iyer', 'customer11@retailhubdemo.com', '+91-9876500011', 'Female', '1996-03-12', '2026-06-12', 'Premium'),
(12, 'Diya', 'Das', 'customer12@retailhubdemo.com', '+91-9876500012', 'Other', '1997-04-13', '2026-01-13', 'VIP'),
(13, 'Myra', 'Roy', 'customer13@retailhubdemo.com', '+91-9876500013', 'Male', '1998-05-14', '2026-02-14', 'Regular'),
(14, 'Sara', 'Kapoor', 'customer14@retailhubdemo.com', '+91-9876500014', 'Female', '1999-06-15', '2026-03-15', 'Premium'),
(15, 'Aadhya', 'Bose', 'customer15@retailhubdemo.com', '+91-9876500015', 'Other', '2000-07-16', '2026-04-16', 'VIP'),
(16, 'Ira', 'Malhotra', 'customer16@retailhubdemo.com', '+91-9876500016', 'Male', '2001-08-17', '2026-05-17', 'Regular'),
(17, 'Avni', 'Chopra', 'customer17@retailhubdemo.com', '+91-9876500017', 'Female', '2002-09-18', '2026-06-18', 'Premium'),
(18, 'Riya', 'Mishra', 'customer18@retailhubdemo.com', '+91-9876500018', 'Other', '2003-01-19', '2026-01-19', 'VIP'),
(19, 'Saanvi', 'Yadav', 'customer19@retailhubdemo.com', '+91-9876500019', 'Male', '2004-02-20', '2026-02-20', 'Regular'),
(20, 'Kiara', 'Agarwal', 'customer20@retailhubdemo.com', '+91-9876500020', 'Female', '1985-03-21', '2026-03-21', 'Premium'),
(21, 'Rahul', 'Kulkarni', 'customer21@retailhubdemo.com', '+91-9876500021', 'Other', '1986-04-22', '2026-04-22', 'VIP'),
(22, 'Priya', 'Pillai', 'customer22@retailhubdemo.com', '+91-9876500022', 'Male', '1987-05-23', '2026-05-23', 'Regular'),
(23, 'Neha', 'Bhat', 'customer23@retailhubdemo.com', '+91-9876500023', 'Female', '1988-06-24', '2026-06-24', 'Premium'),
(24, 'Karan', 'Saxena', 'customer24@retailhubdemo.com', '+91-9876500024', 'Other', '1989-07-25', '2026-01-25', 'VIP'),
(25, 'Pooja', 'Jain', 'customer25@retailhubdemo.com', '+91-9876500025', 'Male', '1990-08-26', '2026-02-26', 'Regular');

-- 9. customer_addresses
-- Child table: customer_id must exist in customers.
-- is_default uses TRUE/FALSE logic to mark a customer's main delivery address.
INSERT INTO customer_addresses (address_id, customer_id, address_line, city, state, pincode, is_default) VALUES
(1, 1, 'House 101, Main Road, Area 1', 'Delhi', 'Delhi', '110001', 1),
(2, 2, 'House 102, Main Road, Area 2', 'Mumbai', 'Maharashtra', '110002', 1),
(3, 3, 'House 103, Main Road, Area 3', 'Bengaluru', 'Karnataka', '110003', 1),
(4, 4, 'House 104, Main Road, Area 4', 'Kolkata', 'West Bengal', '110004', 1),
(5, 5, 'House 105, Main Road, Area 5', 'Chennai', 'Tamil Nadu', '110005', 1),
(6, 6, 'House 106, Main Road, Area 6', 'Hyderabad', 'Telangana', '110006', 1),
(7, 7, 'House 107, Main Road, Area 7', 'Pune', 'Maharashtra', '110007', 1),
(8, 8, 'House 108, Main Road, Area 8', 'Ahmedabad', 'Gujarat', '110008', 1),
(9, 9, 'House 109, Main Road, Area 9', 'Jaipur', 'Rajasthan', '110009', 1),
(10, 10, 'House 110, Main Road, Area 10', 'Lucknow', 'Uttar Pradesh', '110010', 1),
(11, 11, 'House 111, Main Road, Area 11', 'Kochi', 'Kerala', '110011', 0),
(12, 12, 'House 112, Main Road, Area 12', 'Indore', 'Madhya Pradesh', '110012', 0),
(13, 13, 'House 113, Main Road, Area 13', 'Nagpur', 'Maharashtra', '110013', 0),
(14, 14, 'House 114, Main Road, Area 14', 'Surat', 'Gujarat', '110014', 0),
(15, 15, 'House 115, Main Road, Area 15', 'Patna', 'Bihar', '110015', 0),
(16, 16, 'House 116, Main Road, Area 16', 'Bhopal', 'Madhya Pradesh', '110016', 0),
(17, 17, 'House 117, Main Road, Area 17', 'Noida', 'Uttar Pradesh', '110017', 0),
(18, 18, 'House 118, Main Road, Area 18', 'Gurugram', 'Haryana', '110018', 0),
(19, 19, 'House 119, Main Road, Area 19', 'Coimbatore', 'Tamil Nadu', '110019', 0),
(20, 20, 'House 120, Main Road, Area 20', 'Visakhapatnam', 'Andhra Pradesh', '110020', 0),
(21, 21, 'House 121, Main Road, Area 21', 'Mysuru', 'Karnataka', '110021', 0),
(22, 22, 'House 122, Main Road, Area 22', 'Ranchi', 'Jharkhand', '110022', 0),
(23, 23, 'House 123, Main Road, Area 23', 'Chandigarh', 'Chandigarh', '110023', 0),
(24, 24, 'House 124, Main Road, Area 24', 'Guwahati', 'Assam', '110024', 0),
(25, 25, 'House 125, Main Road, Area 25', 'Goa', 'Goa', '110025', 0);

-- 10. employees
-- Child table: department_id references departments; manager_id references employees.
-- manager_id can be NULL for top-level managers.
INSERT INTO employees (employee_id, first_name, last_name, email, department_id, manager_id, job_title, hire_date, salary) VALUES
(1, 'Aarav', 'Jain', 'employee01@retailhubdemo.com', 1, NULL, 'Sales Analyst', '2024-01-01', 32500.00),
(2, 'Vivaan', 'Saxena', 'employee02@retailhubdemo.com', 2, 1, 'Support Executive', '2024-02-02', 35000.00),
(3, 'Aditya', 'Bhat', 'employee03@retailhubdemo.com', 3, 1, 'Warehouse Lead', '2024-03-03', 37500.00),
(4, 'Vihaan', 'Pillai', 'employee04@retailhubdemo.com', 4, 1, 'Marketing Analyst', '2024-04-04', 40000.00),
(5, 'Arjun', 'Kulkarni', 'employee05@retailhubdemo.com', 5, 1, 'IT Engineer', '2024-05-05', 42500.00),
(6, 'Sai', 'Agarwal', 'employee06@retailhubdemo.com', 6, 2, 'Procurement Analyst', '2024-06-06', 45000.00),
(7, 'Reyansh', 'Yadav', 'employee07@retailhubdemo.com', 7, 2, 'Finance Analyst', '2024-07-07', 47500.00),
(8, 'Ayaan', 'Mishra', 'employee08@retailhubdemo.com', 8, 2, 'HR Executive', '2024-08-08', 50000.00),
(9, 'Krishna', 'Chopra', 'employee09@retailhubdemo.com', 9, 2, 'Data Analyst', '2024-09-09', 52500.00),
(10, 'Ishaan', 'Malhotra', 'employee10@retailhubdemo.com', 10, 2, 'Product Analyst', '2024-10-10', 55000.00),
(11, 'Anaya', 'Bose', 'employee11@retailhubdemo.com', 11, 3, 'QA Analyst', '2024-11-11', 57500.00),
(12, 'Diya', 'Kapoor', 'employee12@retailhubdemo.com', 12, 3, 'Logistics Coordinator', '2024-12-12', 60000.00),
(13, 'Myra', 'Roy', 'employee13@retailhubdemo.com', 13, 3, 'Vendor Manager', '2024-01-13', 62500.00),
(14, 'Sara', 'Das', 'employee14@retailhubdemo.com', 14, 3, 'CX Associate', '2024-02-14', 65000.00),
(15, 'Aadhya', 'Iyer', 'employee15@retailhubdemo.com', 15, 3, 'BI Analyst', '2024-03-15', 67500.00),
(16, 'Ira', 'Joshi', 'employee16@retailhubdemo.com', 16, 4, 'Operations Analyst', '2024-04-16', 70000.00),
(17, 'Avni', 'Khan', 'employee17@retailhubdemo.com', 17, 4, 'Legal Associate', '2024-05-17', 72500.00),
(18, 'Riya', 'Mehta', 'employee18@retailhubdemo.com', 18, 4, 'Trainer', '2024-06-18', 75000.00),
(19, 'Saanvi', 'Gupta', 'employee19@retailhubdemo.com', 19, 4, 'Security Officer', '2024-07-19', 77500.00),
(20, 'Kiara', 'Singh', 'employee20@retailhubdemo.com', 20, 4, 'Merchandiser', '2024-08-20', 80000.00),
(21, 'Rahul', 'Nair', 'employee21@retailhubdemo.com', 21, 5, 'Returns Analyst', '2024-09-21', 82500.00),
(22, 'Priya', 'Reddy', 'employee22@retailhubdemo.com', 22, 5, 'Fulfillment Lead', '2024-10-22', 85000.00),
(23, 'Neha', 'Patel', 'employee23@retailhubdemo.com', 23, 5, 'Pricing Analyst', '2024-11-23', 87500.00),
(24, 'Karan', 'Verma', 'employee24@retailhubdemo.com', 24, 5, 'CRM Analyst', '2024-12-24', 90000.00),
(25, 'Pooja', 'Sharma', 'employee25@retailhubdemo.com', 25, NULL, 'General Manager', '2024-01-25', 92500.00);

-- 11. products
-- Child table: subcategory_id and supplier_id must exist.
-- unit_price is kept greater than cost_price to satisfy the profit-margin check constraint.
INSERT INTO products (product_id, product_name, subcategory_id, supplier_id, unit_price, cost_price, launch_date, is_active) VALUES
(1, 'Smartphone X1', 1, 1, 415.00, 280.00, '2025-01-01', TRUE),
(2, 'Laptop Pro 14', 2, 2, 530.00, 360.00, '2025-02-02', TRUE),
(3, 'Nonstick Cookware Set', 3, 3, 645.00, 440.00, '2025-03-03', TRUE),
(4, 'Classic Men Shirt', 4, 4, 760.00, 520.00, '2025-04-04', TRUE),
(5, 'Vitamin C Serum', 5, 5, 875.00, 600.00, '2025-05-05', TRUE),
(6, 'Mystery Novel', 6, 6, 990.00, 680.00, '2025-06-06', TRUE),
(7, 'Masala Chips Pack', 7, 7, 1105.00, 760.00, '2025-07-07', TRUE),
(8, 'STEM Learning Kit', 8, 8, 1220.00, 840.00, '2025-08-08', TRUE),
(9, 'Car Phone Holder', 9, 9, 1335.00, 920.00, '2025-09-09', TRUE),
(10, 'Daily Multivitamin', 10, 10, 1450.00, 1000.00, '2025-10-10', TRUE),
(11, 'Wireless Printer', 11, 11, 1565.00, 1080.00, '2025-11-11', TRUE),
(12, 'Premium Dog Food', 12, 12, 1680.00, 1160.00, '2025-12-12', TRUE),
(13, 'Ceramic Planter', 13, 13, 1795.00, 1240.00, '2025-01-13', TRUE),
(14, 'Silver Ring', 14, 14, 1910.00, 1320.00, '2025-02-14', TRUE),
(15, 'Baby Diapers Pack', 15, 15, 2025.00, 1400.00, '2025-03-15', TRUE),
(16, 'Acoustic Guitar', 16, 16, 2140.00, 1480.00, '2025-04-16', TRUE),
(17, 'Action Movie DVD', 17, 17, 2255.00, 1560.00, '2025-05-17', TRUE),
(18, 'Gaming Console', 18, 18, 2370.00, 1640.00, '2025-06-18', TRUE),
(19, 'Travel Backpack', 19, 19, 2485.00, 1720.00, '2025-07-19', TRUE),
(20, 'Running Shoes', 20, 20, 2600.00, 1800.00, '2025-08-20', TRUE),
(21, 'Three Seat Sofa', 21, 21, 2715.00, 1880.00, '2025-09-21', TRUE),
(22, 'Double Door Refrigerator', 22, 22, 2830.00, 1960.00, '2025-10-22', TRUE),
(23, 'Spiral Notebook Set', 23, 23, 2945.00, 2040.00, '2025-11-23', TRUE),
(24, 'Yoga Mat', 24, 24, 3060.00, 2120.00, '2025-12-24', TRUE),
(25, 'Smart Speaker Mini', 25, 25, 3175.00, 2200.00, '2025-01-25', TRUE);

-- 12. inventory
-- Child table: product_id and warehouse_id must exist.
-- Each product/warehouse pair is unique to avoid duplicate stock records.
INSERT INTO inventory (inventory_id, product_id, warehouse_id, stock_quantity, reorder_level, last_restock_date) VALUES
(1, 1, 1, 53, 15, '2026-01-01'),
(2, 2, 2, 56, 20, '2026-02-02'),
(3, 3, 3, 59, 25, '2026-03-03'),
(4, 4, 4, 62, 30, '2026-04-04'),
(5, 5, 5, 65, 10, '2026-05-05'),
(6, 6, 6, 68, 15, '2026-06-06'),
(7, 7, 7, 71, 20, '2026-01-07'),
(8, 8, 8, 74, 25, '2026-02-08'),
(9, 9, 9, 77, 30, '2026-03-09'),
(10, 10, 10, 80, 10, '2026-04-10'),
(11, 11, 11, 83, 15, '2026-05-11'),
(12, 12, 12, 86, 20, '2026-06-12'),
(13, 13, 13, 89, 25, '2026-01-13'),
(14, 14, 14, 92, 30, '2026-02-14'),
(15, 15, 15, 95, 10, '2026-03-15'),
(16, 16, 16, 98, 15, '2026-04-16'),
(17, 17, 17, 101, 20, '2026-05-17'),
(18, 18, 18, 104, 25, '2026-06-18'),
(19, 19, 19, 107, 30, '2026-01-19'),
(20, 20, 20, 110, 10, '2026-02-20'),
(21, 21, 21, 113, 15, '2026-03-21'),
(22, 22, 22, 116, 20, '2026-04-22'),
(23, 23, 23, 119, 25, '2026-05-23'),
(24, 24, 24, 122, 30, '2026-06-24'),
(25, 25, 25, 125, 10, '2026-01-25');

-- 13. orders
-- Child table: customer_id, employee_id, and address_id must exist.
-- total_amount is included for analytical practice; real systems may calculate it from order_items.
INSERT INTO orders (order_id, customer_id, employee_id, address_id, order_date, order_status, total_amount) VALUES
(1, 1, 1, 1, '2026-06-01 10:02:00', 'Pending', 840.00),
(2, 2, 2, 2, '2026-06-02 10:04:00', 'Processing', 1620.00),
(3, 3, 3, 3, '2026-06-03 10:06:00', 'Shipped', 660.00),
(4, 4, 4, 4, '2026-06-04 10:08:00', 'Delivered', 1560.00),
(5, 5, 5, 5, '2026-06-05 10:10:00', 'Cancelled', 2700.00),
(6, 6, 6, 6, '2026-06-06 10:12:00', 'Pending', 1020.00),
(7, 7, 7, 7, '2026-06-07 10:14:00', 'Processing', 2280.00),
(8, 8, 8, 8, '2026-06-08 10:16:00', 'Shipped', 3780.00),
(9, 9, 9, 9, '2026-06-09 10:18:00', 'Delivered', 1380.00),
(10, 10, 10, 10, '2026-06-10 10:20:00', 'Cancelled', 3000.00),
(11, 11, 11, 11, '2026-06-11 10:22:00', 'Pending', 4860.00),
(12, 12, 12, 12, '2026-06-12 10:24:00', 'Processing', 1740.00),
(13, 13, 13, 13, '2026-06-13 10:26:00', 'Shipped', 3720.00),
(14, 14, 14, 14, '2026-06-14 10:28:00', 'Delivered', 5940.00),
(15, 15, 15, 15, '2026-06-15 10:30:00', 'Cancelled', 2100.00),
(16, 16, 16, 16, '2026-06-16 10:32:00', 'Pending', 4440.00),
(17, 17, 17, 17, '2026-06-17 10:34:00', 'Processing', 7020.00),
(18, 18, 18, 18, '2026-06-18 10:36:00', 'Shipped', 2460.00),
(19, 19, 19, 19, '2026-06-19 10:38:00', 'Delivered', 5160.00),
(20, 20, 20, 20, '2026-06-20 10:40:00', 'Cancelled', 8100.00),
(21, 21, 21, 21, '2026-06-21 10:42:00', 'Pending', 2820.00),
(22, 22, 22, 22, '2026-06-22 10:44:00', 'Processing', 5880.00),
(23, 23, 23, 23, '2026-06-23 10:46:00', 'Shipped', 9180.00),
(24, 24, 24, 24, '2026-06-24 10:48:00', 'Delivered', 3180.00),
(25, 25, 25, 25, '2026-06-25 10:50:00', 'Cancelled', 6600.00);

-- 14. order_items
-- Child table: order_id and product_id must exist.
-- subtotal is not inserted because the schema generates it automatically as quantity * unit_price.
INSERT INTO order_items (order_item_id, order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 2, 420.00),
(2, 2, 2, 3, 540.00),
(3, 3, 3, 1, 660.00),
(4, 4, 4, 2, 780.00),
(5, 5, 5, 3, 900.00),
(6, 6, 6, 1, 1020.00),
(7, 7, 7, 2, 1140.00),
(8, 8, 8, 3, 1260.00),
(9, 9, 9, 1, 1380.00),
(10, 10, 10, 2, 1500.00),
(11, 11, 11, 3, 1620.00),
(12, 12, 12, 1, 1740.00),
(13, 13, 13, 2, 1860.00),
(14, 14, 14, 3, 1980.00),
(15, 15, 15, 1, 2100.00),
(16, 16, 16, 2, 2220.00),
(17, 17, 17, 3, 2340.00),
(18, 18, 18, 1, 2460.00),
(19, 19, 19, 2, 2580.00),
(20, 20, 20, 3, 2700.00),
(21, 21, 21, 1, 2820.00),
(22, 22, 22, 2, 2940.00),
(23, 23, 23, 3, 3060.00),
(24, 24, 24, 1, 3180.00),
(25, 25, 25, 2, 3300.00);

-- 15. payments
-- Child table: order_id must exist and is UNIQUE, so there is one payment row per order.
INSERT INTO payments (payment_id, order_id, payment_date, payment_method, amount, payment_status) VALUES
(1, 1, '2026-06-01 10:07:00', 'Credit Card', 840.00, 'Success'),
(2, 2, '2026-06-02 10:09:00', 'Debit Card', 1620.00, 'Success'),
(3, 3, '2026-06-03 10:11:00', 'UPI', 660.00, 'Pending'),
(4, 4, '2026-06-04 10:13:00', 'Net Banking', 1560.00, 'Failed'),
(5, 5, '2026-06-05 10:15:00', 'COD', 2700.00, 'Refunded'),
(6, 6, '2026-06-06 10:17:00', 'Credit Card', 1020.00, 'Success'),
(7, 7, '2026-06-07 10:19:00', 'Debit Card', 2280.00, 'Success'),
(8, 8, '2026-06-08 10:21:00', 'UPI', 3780.00, 'Pending'),
(9, 9, '2026-06-09 10:23:00', 'Net Banking', 1380.00, 'Failed'),
(10, 10, '2026-06-10 10:25:00', 'COD', 3000.00, 'Refunded'),
(11, 11, '2026-06-11 10:27:00', 'Credit Card', 4860.00, 'Success'),
(12, 12, '2026-06-12 10:29:00', 'Debit Card', 1740.00, 'Success'),
(13, 13, '2026-06-13 10:31:00', 'UPI', 3720.00, 'Pending'),
(14, 14, '2026-06-14 10:33:00', 'Net Banking', 5940.00, 'Failed'),
(15, 15, '2026-06-15 10:35:00', 'COD', 2100.00, 'Refunded'),
(16, 16, '2026-06-16 10:37:00', 'Credit Card', 4440.00, 'Success'),
(17, 17, '2026-06-17 10:39:00', 'Debit Card', 7020.00, 'Success'),
(18, 18, '2026-06-18 10:41:00', 'UPI', 2460.00, 'Pending'),
(19, 19, '2026-06-19 10:43:00', 'Net Banking', 5160.00, 'Failed'),
(20, 20, '2026-06-20 10:45:00', 'COD', 8100.00, 'Refunded'),
(21, 21, '2026-06-21 10:47:00', 'Credit Card', 2820.00, 'Success'),
(22, 22, '2026-06-22 10:49:00', 'Debit Card', 5880.00, 'Success'),
(23, 23, '2026-06-23 10:51:00', 'UPI', 9180.00, 'Pending'),
(24, 24, '2026-06-24 10:53:00', 'Net Banking', 3180.00, 'Failed'),
(25, 25, '2026-06-25 10:55:00', 'COD', 6600.00, 'Refunded');

-- 16. shipments
-- Child table: order_id, warehouse_id, and agent_id must exist.
-- Some delivery_date values are NULL to represent orders not delivered yet.
INSERT INTO shipments (shipment_id, order_id, warehouse_id, agent_id, shipped_date, delivery_date, shipment_status) VALUES
(1, 1, 1, 1, '2026-06-01 15:00:00', NULL, 'Preparing'),
(2, 2, 2, 2, '2026-06-02 15:00:00', NULL, 'In Transit'),
(3, 3, 3, 3, '2026-06-03 15:00:00', '2026-06-05 18:00:00', 'Delivered'),
(4, 4, 4, 4, '2026-06-04 15:00:00', '2026-06-06 18:00:00', 'Delayed'),
(5, 5, 5, 5, '2026-06-05 15:00:00', '2026-06-07 18:00:00', 'Returned'),
(6, 6, 6, 6, '2026-06-06 15:00:00', NULL, 'Preparing'),
(7, 7, 7, 7, '2026-06-07 15:00:00', NULL, 'In Transit'),
(8, 8, 8, 8, '2026-06-08 15:00:00', '2026-06-10 18:00:00', 'Delivered'),
(9, 9, 9, 9, '2026-06-09 15:00:00', '2026-06-11 18:00:00', 'Delayed'),
(10, 10, 10, 10, '2026-06-10 15:00:00', '2026-06-12 18:00:00', 'Returned'),
(11, 11, 11, 11, '2026-06-11 15:00:00', NULL, 'Preparing'),
(12, 12, 12, 12, '2026-06-12 15:00:00', NULL, 'In Transit'),
(13, 13, 13, 13, '2026-06-13 15:00:00', '2026-06-15 18:00:00', 'Delivered'),
(14, 14, 14, 14, '2026-06-14 15:00:00', '2026-06-16 18:00:00', 'Delayed'),
(15, 15, 15, 15, '2026-06-15 15:00:00', '2026-06-17 18:00:00', 'Returned'),
(16, 16, 16, 16, '2026-06-16 15:00:00', NULL, 'Preparing'),
(17, 17, 17, 17, '2026-06-17 15:00:00', NULL, 'In Transit'),
(18, 18, 18, 18, '2026-06-18 15:00:00', '2026-06-20 18:00:00', 'Delivered'),
(19, 19, 19, 19, '2026-06-19 15:00:00', '2026-06-21 18:00:00', 'Delayed'),
(20, 20, 20, 20, '2026-06-20 15:00:00', '2026-06-22 18:00:00', 'Returned'),
(21, 21, 21, 21, '2026-06-21 15:00:00', NULL, 'Preparing'),
(22, 22, 22, 22, '2026-06-22 15:00:00', NULL, 'In Transit'),
(23, 23, 23, 23, '2026-06-23 15:00:00', '2026-06-25 18:00:00', 'Delivered'),
(24, 24, 24, 24, '2026-06-24 15:00:00', '2026-06-26 18:00:00', 'Delayed'),
(25, 25, 25, 25, '2026-06-25 15:00:00', '2026-06-27 18:00:00', 'Returned');

-- 17. returns
-- Child table: order_item_id must exist.
-- Return data helps practice refund and return-rate analysis.
INSERT INTO returns (return_id, order_item_id, return_date, reason, refund_amount, return_status) VALUES
(1, 1, '2026-07-01', 'Damaged item', 70.00, 'Requested'),
(2, 2, '2026-07-02', 'Wrong size', 90.00, 'Approved'),
(3, 3, '2026-07-03', 'Late delivery', 110.00, 'Rejected'),
(4, 4, '2026-07-04', 'Changed mind', 130.00, 'Completed'),
(5, 5, '2026-07-05', 'Product mismatch', 150.00, 'Requested'),
(6, 6, '2026-07-06', 'Damaged item', 170.00, 'Approved'),
(7, 7, '2026-07-07', 'Wrong size', 190.00, 'Rejected'),
(8, 8, '2026-07-08', 'Late delivery', 210.00, 'Completed'),
(9, 9, '2026-07-09', 'Changed mind', 230.00, 'Requested'),
(10, 10, '2026-07-10', 'Product mismatch', 250.00, 'Approved'),
(11, 11, '2026-07-11', 'Damaged item', 270.00, 'Rejected'),
(12, 12, '2026-07-12', 'Wrong size', 290.00, 'Completed'),
(13, 13, '2026-07-13', 'Late delivery', 310.00, 'Requested'),
(14, 14, '2026-07-14', 'Changed mind', 330.00, 'Approved'),
(15, 15, '2026-07-15', 'Product mismatch', 350.00, 'Rejected'),
(16, 16, '2026-07-16', 'Damaged item', 370.00, 'Completed'),
(17, 17, '2026-07-17', 'Wrong size', 390.00, 'Requested'),
(18, 18, '2026-07-18', 'Late delivery', 410.00, 'Approved'),
(19, 19, '2026-07-19', 'Changed mind', 430.00, 'Rejected'),
(20, 20, '2026-07-20', 'Product mismatch', 450.00, 'Completed'),
(21, 21, '2026-07-21', 'Damaged item', 470.00, 'Requested'),
(22, 22, '2026-07-22', 'Wrong size', 490.00, 'Approved'),
(23, 23, '2026-07-23', 'Late delivery', 510.00, 'Rejected'),
(24, 24, '2026-07-24', 'Changed mind', 530.00, 'Completed'),
(25, 25, '2026-07-25', 'Product mismatch', 550.00, 'Requested');

-- 18. reviews
-- Child table: product_id and customer_id must exist.
-- Each product/customer pair is unique, so every review uses a different pair.
INSERT INTO reviews (review_id, product_id, customer_id, rating, review_text, review_date) VALUES
(1, 1, 1, 1, 'Review for product 1: useful sample feedback for analysis.', '2026-07-01'),
(2, 2, 2, 2, 'Review for product 2: useful sample feedback for analysis.', '2026-07-02'),
(3, 3, 3, 3, 'Review for product 3: useful sample feedback for analysis.', '2026-07-03'),
(4, 4, 4, 4, 'Review for product 4: useful sample feedback for analysis.', '2026-07-04'),
(5, 5, 5, 5, 'Review for product 5: useful sample feedback for analysis.', '2026-07-05'),
(6, 6, 6, 1, 'Review for product 6: useful sample feedback for analysis.', '2026-07-06'),
(7, 7, 7, 2, 'Review for product 7: useful sample feedback for analysis.', '2026-07-07'),
(8, 8, 8, 3, 'Review for product 8: useful sample feedback for analysis.', '2026-07-08'),
(9, 9, 9, 4, 'Review for product 9: useful sample feedback for analysis.', '2026-07-09'),
(10, 10, 10, 5, 'Review for product 10: useful sample feedback for analysis.', '2026-07-10'),
(11, 11, 11, 1, 'Review for product 11: useful sample feedback for analysis.', '2026-07-11'),
(12, 12, 12, 2, 'Review for product 12: useful sample feedback for analysis.', '2026-07-12'),
(13, 13, 13, 3, 'Review for product 13: useful sample feedback for analysis.', '2026-07-13'),
(14, 14, 14, 4, 'Review for product 14: useful sample feedback for analysis.', '2026-07-14'),
(15, 15, 15, 5, 'Review for product 15: useful sample feedback for analysis.', '2026-07-15'),
(16, 16, 16, 1, 'Review for product 16: useful sample feedback for analysis.', '2026-07-16'),
(17, 17, 17, 2, 'Review for product 17: useful sample feedback for analysis.', '2026-07-17'),
(18, 18, 18, 3, 'Review for product 18: useful sample feedback for analysis.', '2026-07-18'),
(19, 19, 19, 4, 'Review for product 19: useful sample feedback for analysis.', '2026-07-19'),
(20, 20, 20, 5, 'Review for product 20: useful sample feedback for analysis.', '2026-07-20'),
(21, 21, 21, 1, 'Review for product 21: useful sample feedback for analysis.', '2026-07-21'),
(22, 22, 22, 2, 'Review for product 22: useful sample feedback for analysis.', '2026-07-22'),
(23, 23, 23, 3, 'Review for product 23: useful sample feedback for analysis.', '2026-07-23'),
(24, 24, 24, 4, 'Review for product 24: useful sample feedback for analysis.', '2026-07-24'),
(25, 25, 25, 5, 'Review for product 25: useful sample feedback for analysis.', '2026-07-25');

-- 19. order_coupons
-- Junction table: connects orders and coupons.
-- Composite primary key prevents the same coupon being attached twice to one order.
INSERT INTO order_coupons (order_id, coupon_id, discount_applied) VALUES
(1, 1, 30.00),
(2, 2, 35.00),
(3, 3, 40.00),
(4, 4, 45.00),
(5, 5, 50.00),
(6, 6, 55.00),
(7, 7, 60.00),
(8, 8, 65.00),
(9, 9, 70.00),
(10, 10, 75.00),
(11, 11, 80.00),
(12, 12, 85.00),
(13, 13, 90.00),
(14, 14, 95.00),
(15, 15, 100.00),
(16, 16, 105.00),
(17, 17, 110.00),
(18, 18, 115.00),
(19, 19, 120.00),
(20, 20, 125.00),
(21, 21, 130.00),
(22, 22, 135.00),
(23, 23, 140.00),
(24, 24, 145.00),
(25, 25, 150.00);

-- 20. wishlist
-- Child table: customer_id and product_id must exist.
-- Shows customer interest even before purchase.
INSERT INTO wishlist (wishlist_id, customer_id, product_id, added_date) VALUES
(1, 1, 25, '2026-06-01'),
(2, 2, 24, '2026-06-02'),
(3, 3, 23, '2026-06-03'),
(4, 4, 22, '2026-06-04'),
(5, 5, 21, '2026-06-05'),
(6, 6, 20, '2026-06-06'),
(7, 7, 19, '2026-06-07'),
(8, 8, 18, '2026-06-08'),
(9, 9, 17, '2026-06-09'),
(10, 10, 16, '2026-06-10'),
(11, 11, 15, '2026-06-11'),
(12, 12, 14, '2026-06-12'),
(13, 13, 13, '2026-06-13'),
(14, 14, 12, '2026-06-14'),
(15, 15, 11, '2026-06-15'),
(16, 16, 10, '2026-06-16'),
(17, 17, 9, '2026-06-17'),
(18, 18, 8, '2026-06-18'),
(19, 19, 7, '2026-06-19'),
(20, 20, 6, '2026-06-20'),
(21, 21, 5, '2026-06-21'),
(22, 22, 4, '2026-06-22'),
(23, 23, 3, '2026-06-23'),
(24, 24, 2, '2026-06-24'),
(25, 25, 1, '2026-06-25');

-- 21. cart_items
-- Child table: customer_id and product_id must exist.
-- Cart data is useful for cart-abandonment analysis.
INSERT INTO cart_items (cart_item_id, customer_id, product_id, quantity, added_date) VALUES
(1, 1, 5, 1, '2026-07-01 09:00:00'),
(2, 2, 6, 2, '2026-07-02 09:00:00'),
(3, 3, 7, 3, '2026-07-03 09:00:00'),
(4, 4, 8, 4, '2026-07-04 09:00:00'),
(5, 5, 9, 1, '2026-07-05 09:00:00'),
(6, 6, 10, 2, '2026-07-06 09:00:00'),
(7, 7, 11, 3, '2026-07-07 09:00:00'),
(8, 8, 12, 4, '2026-07-08 09:00:00'),
(9, 9, 13, 1, '2026-07-09 09:00:00'),
(10, 10, 14, 2, '2026-07-10 09:00:00'),
(11, 11, 15, 3, '2026-07-11 09:00:00'),
(12, 12, 16, 4, '2026-07-12 09:00:00'),
(13, 13, 17, 1, '2026-07-13 09:00:00'),
(14, 14, 18, 2, '2026-07-14 09:00:00'),
(15, 15, 19, 3, '2026-07-15 09:00:00'),
(16, 16, 20, 4, '2026-07-16 09:00:00'),
(17, 17, 21, 1, '2026-07-17 09:00:00'),
(18, 18, 22, 2, '2026-07-18 09:00:00'),
(19, 19, 23, 3, '2026-07-19 09:00:00'),
(20, 20, 24, 4, '2026-07-20 09:00:00'),
(21, 21, 25, 1, '2026-07-21 09:00:00'),
(22, 22, 1, 2, '2026-07-22 09:00:00'),
(23, 23, 2, 3, '2026-07-23 09:00:00'),
(24, 24, 3, 4, '2026-07-24 09:00:00'),
(25, 25, 4, 1, '2026-07-25 09:00:00');

-- 22. support_tickets
-- Child table: customer_id must exist; order_id and employee_id are optional relationships.
-- resolved_at is NULL when the ticket is still open or in progress.
INSERT INTO support_tickets (ticket_id, customer_id, order_id, employee_id, issue_type, ticket_status, created_at, resolved_at) VALUES
(1, 1, 1, 1, 'Delivery', 'Open', '2026-07-01 11:00:00', NULL),
(2, 2, 2, 2, 'Product', 'In Progress', '2026-07-02 11:00:00', NULL),
(3, 3, 3, 3, 'Payment', 'Resolved', '2026-07-03 11:00:00', '2026-07-04 17:00:00'),
(4, 4, 4, 4, 'Refund', 'Closed', '2026-07-04 11:00:00', '2026-07-05 17:00:00'),
(5, 5, 5, 5, 'Other', 'Open', '2026-07-05 11:00:00', NULL),
(6, 6, 6, 6, 'Delivery', 'In Progress', '2026-07-06 11:00:00', NULL),
(7, 7, 7, 7, 'Product', 'Resolved', '2026-07-07 11:00:00', '2026-07-08 17:00:00'),
(8, 8, 8, 8, 'Payment', 'Closed', '2026-07-08 11:00:00', '2026-07-09 17:00:00'),
(9, 9, 9, 9, 'Refund', 'Open', '2026-07-09 11:00:00', NULL),
(10, 10, 10, 10, 'Other', 'In Progress', '2026-07-10 11:00:00', NULL),
(11, 11, 11, 11, 'Delivery', 'Resolved', '2026-07-11 11:00:00', '2026-07-12 17:00:00'),
(12, 12, 12, 12, 'Product', 'Closed', '2026-07-12 11:00:00', '2026-07-13 17:00:00'),
(13, 13, 13, 13, 'Payment', 'Open', '2026-07-13 11:00:00', NULL),
(14, 14, 14, 14, 'Refund', 'In Progress', '2026-07-14 11:00:00', NULL),
(15, 15, 15, 15, 'Other', 'Resolved', '2026-07-15 11:00:00', '2026-07-16 17:00:00'),
(16, 16, 16, 16, 'Delivery', 'Closed', '2026-07-16 11:00:00', '2026-07-17 17:00:00'),
(17, 17, 17, 17, 'Product', 'Open', '2026-07-17 11:00:00', NULL),
(18, 18, 18, 18, 'Payment', 'In Progress', '2026-07-18 11:00:00', NULL),
(19, 19, 19, 19, 'Refund', 'Resolved', '2026-07-19 11:00:00', '2026-07-20 17:00:00'),
(20, 20, 20, 20, 'Other', 'Closed', '2026-07-20 11:00:00', '2026-07-21 17:00:00'),
(21, 21, 21, 21, 'Delivery', 'Open', '2026-07-21 11:00:00', NULL),
(22, 22, 22, 22, 'Product', 'In Progress', '2026-07-22 11:00:00', NULL),
(23, 23, 23, 23, 'Payment', 'Resolved', '2026-07-23 11:00:00', '2026-07-24 17:00:00'),
(24, 24, 24, 24, 'Refund', 'Closed', '2026-07-24 11:00:00', '2026-07-25 17:00:00'),
(25, 25, 25, 25, 'Other', 'Open', '2026-07-25 11:00:00', NULL);

COMMIT;

-- =====================================================================
-- End of file.
-- Quick check queries after running this file:
-- SELECT COUNT(*) FROM customers;
-- SELECT COUNT(*) FROM orders;
-- SELECT COUNT(*) FROM order_items;
-- =====================================================================
