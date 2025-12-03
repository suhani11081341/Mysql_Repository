-- Drop the table if it already exists
use my_catalog;
DROP TABLE IF EXISTS orders;

-- Create the orders table
CREATE TABLE orders (
    id INT PRIMARY KEY,
    order_date DATE,
    order_amount DECIMAL(10,2),
    customer_id INT
);

-- Insert all 12 records
INSERT INTO orders (id, order_date, order_amount, customer_id) VALUES
(1, '2021-10-01', 42.12, 3),
(2, '2021-10-01', 415.63, 1),
(3, '2021-10-02', 84.99, 2),
(4, '2021-10-02', 28.96, 3),
(5, '2021-10-02', 54.31, 1),
(6, '2021-10-03', 74.26, 1),
(7, '2021-10-03', 77.77, 2),
(8, '2021-10-03', 55.70, 3),
(9, '2021-10-04', 16.94, 3),
(10, '2021-10-04', 51.44, 1),
(11, '2021-10-05', 41.58, 3),
(12, '2021-10-06', 95.00, 1);
-- ------------------------------------------------------
-- 💠 SCENARIO INSERTS (Requested by Suhani)
-- ------------------------------------------------------

-- ------------------------------------------------------
-- 🟩 Scenario 1:
-- Customer 4 (Noncon) orders on NON-CONSECUTIVE days:
-- Example: 1 Oct, 5 Oct, 10 Oct (GAPS = NOT consecutive)
-- ------------------------------------------------------
INSERT INTO orders (id, order_date, order_amount, customer_id) VALUES
(13, '2021-10-01', 100.00, 4),
(14, '2021-10-05', 150.00, 4),
(15, '2021-10-10', 200.00, 4);

--------------------------------------------------------
-- 🟦 Scenario 2:
-- Customer 5 (SameDay) makes ALL orders on SAME DATE:
-- Example: 2 orders on 3 Oct → NO consecutive days
--------------------------------------------------------
INSERT INTO orders (id, order_date, order_amount, customer_id) VALUES
(16, '2021-10-03', 80.00, 5),
(17, '2021-10-03', 125.00, 5);

--------------------------------------------------------
-- 🟨 Scenario 3:
-- Customer 6 (Mix):
-- Two orders on one day AND one order on next day
-- Example: 5 Oct (two orders), 6 Oct (one order)
-- This MUST be treated as ONE consecutive day sequence
--------------------------------------------------------
INSERT INTO orders (id, order_date, order_amount, customer_id) VALUES
(18, '2021-10-05', 50.00, 6),
(19, '2021-10-05', 75.00, 6),
(20, '2021-10-06', 120.00, 6);

-- Drop the table if it already exists
DROP TABLE IF EXISTS customers;

-- Create customers table
CREATE TABLE customers (
    id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50)
);

-- Insert the given customer records
INSERT INTO customers (id, first_name, last_name) VALUES
(1, 'Simon', 'Paulson'),
(2, 'Dylan', 'Bobson'),
(3, 'Reb', 'Mackennack'),
-- Scenario 1: Customer with NON-CONSECUTIVE order dates
(4, 'Noncon', 'Customer'),
-- Scenario 2: Customer with ALL orders on SAME DAY
(5, 'SameDay', 'Customer'),
-- Scenario 3: Customer with two orders on one day + one next day
(6, 'Mix', 'Customer');

Select * from Orders;

WITH ordered AS (SELECT DISTINCT customer_id,order_date,
ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS rn FROM orders
),
grp AS (SELECT customer_id,order_date,rn, 
DATE(order_date) - INTERVAL rn DAY AS grp FROM ordered)
SELECT customer_id,COUNT(*) AS consecutive_days
FROM grp GROUP BY customer_id, grp HAVING COUNT(*) >= 2;



-- Drop existing tables if any
use sakila;
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS customers;

-- Create customers table
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100)
);

-- Insert 20 customers (some will have no transactions)
INSERT INTO customers (customer_id, name) VALUES
(1, 'Aarav Mehta'),
(2, 'Suhani Rastogi'),
(3, 'Rohit Sharma'),
(4, 'Priya Gupta'),
(5, 'Arjun Singh'),
(6, 'Meera Kapoor'),
(7, 'Karan Verma'),
(8, 'Neha Joshi'),
(9, 'Vikas Rao'),
(10, 'Simran Kaur'),
(11, 'Aditya Jain'),   -- No transactions
(12, 'Tanya Arora'),   -- No transactions
(13, 'Rahul Nair'),
(14, 'Isha Malhotra'),
(15, 'Kabir Bhatia'),
(16, 'Sneha Desai'),
(17, 'Harsh Patel'),
(18, 'Ritu Soni'),
(19, 'Manish Khurana'),
(20, 'Divya Anand');   -- No transactions


-- Create transactions table
CREATE TABLE transactions (
    txn_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    transaction_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Insert 100 transactions for random customers
INSERT INTO transactions (customer_id, transaction_date) VALUES
(1, '2024-01-05'),
(2, '2024-01-07'),
(3, '2024-01-09'),
(4, '2024-01-11'),
(5, '2024-01-13'),
(6, '2024-01-14'),
(7, '2024-01-15'),
(8, '2024-01-17'),
(9, '2024-01-18'),
(10, '2024-01-20'),

(1, '2024-01-21'),
(2, '2024-01-22'),
(3, '2024-01-23'),
(4, '2024-01-24'),
(5, '2024-01-25'),
(6, '2024-01-26'),
(7, '2024-01-27'),
(8, '2024-01-28'),
(9, '2024-01-29'),
(10, '2024-01-30'),

(1, '2024-02-01'),
(2, '2024-02-02'),
(3, '2024-02-03'),
(4, '2024-02-04'),
(5, '2024-02-05'),
(6, '2024-02-06'),
(7, '2024-02-07'),
(8, '2024-02-08'),
(9, '2024-02-09'),
(10, '2024-02-10'),

(13, '2024-02-12'),
(14, '2024-02-13'),
(15, '2024-02-14'),
(16, '2024-02-15'),
(17, '2024-02-16'),
(18, '2024-02-17'),
(19, '2024-02-18'),
(13, '2024-02-19'),
(14, '2024-02-20'),
(15, '2024-02-21'),

(1, '2024-02-22'),
(2, '2024-02-23'),
(3, '2024-02-24'),
(4, '2024-02-25'),
(5, '2024-02-26'),
(6, '2024-02-27'),
(7, '2024-02-28'),
(8, '2024-02-29'),
(9, '2024-03-01'),
(10, '2024-03-02'),

(13, '2024-03-03'),
(14, '2024-03-04'),
(15, '2024-03-05'),
(16, '2024-03-06'),
(17, '2024-03-07'),
(18, '2024-03-08'),
(19, '2024-03-09'),
(13, '2024-03-10'),
(14, '2024-03-11'),
(15, '2024-03-12'),

(1, '2024-03-13'),
(2, '2024-03-14'),
(3, '2024-03-15'),
(4, '2024-03-16'),
(5, '2024-03-17'),
(6, '2024-03-18'),
(7, '2024-03-19'),
(8, '2024-03-20'),
(9, '2024-03-21'),
(10, '2024-03-22'),

(13, '2024-03-23'),
(14, '2024-03-24'),
(15, '2024-03-25'),
(16, '2024-03-26'),
(17, '2024-03-27'),
(18, '2024-03-28'),
(19, '2024-03-29'),
(13, '2024-03-30'),
(14, '2024-03-31'),
(15, '2024-04-01');
Select * from customers;
Select * from transactions;
Select c.customer_id,name,max(transaction_date) as last_txn
from customers c left join transactions t
using(customer_id) group by 1,2
HAVING MAX(t.transaction_date) IS NULL -- never purchased
OR MAX(t.transaction_date) < CURDATE() - INTERVAL 6 MONTH;

SELECT c.customer_id, c.name FROM customers c
LEFT JOIN transactions t ON c.customer_id = t.customer_id
AND t.transaction_date >= CURRENT_DATE - INTERVAL 6 month
WHERE t.customer_id IS NULL;

SELECT CURDATE() - INTERVAL 6 MONTH;

-- Drop table if exists
DROP TABLE IF EXISTS transaction1;

-- Create table
CREATE TABLE transaction1 (
    id INT PRIMARY KEY,
    customer_id INT,
    transaction_date DATE,
    amount DECIMAL(10,2)
);

-- Insert 100+ records across 2021, 2022, 2023, 2024, 2025
INSERT INTO transaction1 (id, customer_id, transaction_date, amount) VALUES
(1, 1, '2021-01-05', 120.50),
(2, 1, '2021-02-10', 95.00),
(3, 1, '2021-03-15', 150.75),
(4, 1, '2021-04-20', 210.00),
(5, 1, '2021-05-25', 99.99),
(6, 1, '2021-06-10', 185.40),
(7, 1, '2021-07-14', 132.80),
(8, 1, '2021-08-09', 148.00),
(9, 1, '2021-09-12', 174.20),
(10, 1, '2021-10-18', 199.99),

(11, 2, '2021-01-07', 88.00),
(12, 2, '2021-02-14', 110.00),
(13, 2, '2021-03-20', 135.50),
(14, 2, '2021-04-22', 175.00),
(15, 2, '2021-05-18', 200.90),
(16, 2, '2021-06-24', 220.30),
(17, 2, '2021-07-27', 145.50),
(18, 2, '2021-08-16', 80.20),
(19, 2, '2021-09-28', 95.10),
(20, 2, '2021-10-30', 165.40),

(21, 3, '2021-01-05', 90.50),
(22, 3, '2021-02-18', 120.00),
(23, 3, '2021-03-25', 140.75),
(24, 3, '2021-04-29', 220.99),
(25, 3, '2021-05-17', 170.40),
(26, 3, '2021-06-11', 155.70),
(27, 3, '2021-07-20', 88.80),
(28, 3, '2021-08-25', 105.00),
(29, 3, '2021-09-14', 130.50),
(30, 3, '2021-10-19', 166.60),

-- 2022 YEAR
(31, 1, '2022-01-04', 130.20),
(32, 1, '2022-02-13', 110.10),
(33, 1, '2022-03-18', 180.50),
(34, 1, '2022-04-22', 195.75),
(35, 1, '2022-05-26', 140.00),
(36, 1, '2022-06-12', 210.60),
(37, 1, '2022-07-19', 125.90),
(38, 1, '2022-08-23', 180.40),
(39, 1, '2022-09-10', 160.00),
(40, 1, '2022-10-15', 205.80),

(41, 2, '2022-01-09', 92.30),
(42, 2, '2022-02-11', 125.40),
(43, 2, '2022-03-19', 155.60),
(44, 2, '2022-04-25', 205.90),
(45, 2, '2022-05-29', 210.30),
(46, 2, '2022-06-18', 190.50),
(47, 2, '2022-07-24', 150.80),
(48, 2, '2022-08-12', 95.40),
(49, 2, '2022-09-26', 100.20),
(50, 2, '2022-10-31', 175.10),

(51, 3, '2022-01-06', 95.60),
(52, 3, '2022-02-15', 125.50),
(53, 3, '2022-03-22', 155.80),
(54, 3, '2022-04-28', 210.10),
(55, 3, '2022-05-21', 165.90),
(56, 3, '2022-06-16', 175.50),
(57, 3, '2022-07-30', 105.30),
(58, 3, '2022-08-14', 120.00),
(59, 3, '2022-09-22', 140.80),
(60, 3, '2022-10-27', 195.70),

-- 2023 YEAR
(61, 1, '2023-01-07', 140.10),
(62, 1, '2023-02-17', 115.20),
(63, 1, '2023-03-26', 190.40),
(64, 1, '2023-04-29', 220.65),
(65, 1, '2023-05-30', 160.20),
(66, 1, '2023-06-25', 225.30),
(67, 1, '2023-07-28', 135.60),
(68, 1, '2023-08-19', 185.40),
(69, 1, '2023-09-18', 165.90),
(70, 1, '2023-10-23', 210.99),

(71, 2, '2023-01-11', 98.50),
(72, 2, '2023-02-21', 130.80),
(73, 2, '2023-03-29', 160.70),
(74, 2, '2023-04-30', 210.20),
(75, 2, '2023-05-27', 220.50),
(76, 2, '2023-06-22', 200.60),
(77, 2, '2023-07-31', 155.90),
(78, 2, '2023-08-18', 105.00),
(79, 2, '2023-09-24', 110.80),
(80, 2, '2023-10-29', 180.40),

(81, 3, '2023-01-09', 100.50),
(82, 3, '2023-02-18', 135.60),
(83, 3, '2023-03-27', 165.80),
(84, 3, '2023-04-28', 225.40),
(85, 3, '2023-05-24', 175.60),
(86, 3, '2023-06-21', 185.20),
(87, 3, '2023-07-23', 115.40),
(88, 3, '2023-08-29', 140.20),
(89, 3, '2023-09-26', 150.80),
(90, 3, '2023-10-30', 200.10),

-- 2024 YEAR
(91, 1, '2024-01-08', 150.10),
(92, 1, '2024-02-20', 120.50),
(93, 1, '2024-03-29', 200.90),
(94, 1, '2024-04-30', 230.40),
(95, 1, '2024-05-29', 175.10),
(96, 1, '2024-06-28', 240.00),
(97, 1, '2024-07-27', 145.10),
(98, 1, '2024-08-21', 190.00),
(99, 1, '2024-09-25', 175.60),
(100, 1, '2024-10-28', 220.50),

(101, 2, '2024-01-10', 110.70),
(102, 2, '2024-02-22', 140.30),
(103, 2, '2024-03-30', 175.80),
(104, 2, '2024-04-29', 210.60),
(105, 2, '2024-05-28', 195.70),
(106, 2, '2024-06-27', 205.40),
(107, 2, '2024-07-26', 130.10),
(108, 2, '2024-08-24', 110.50),
(109, 2, '2024-09-27', 140.40),
(110, 2, '2024-10-29', 190.30),

(111, 3, '2024-01-09', 115.30),
(112, 3, '2024-02-25', 145.80),
(113, 3, '2024-03-28', 180.40),
(114, 3, '2024-04-30', 235.10),
(115, 3, '2024-05-29', 190.50),
(116, 3, '2024-06-25', 200.20),
(117, 3, '2024-07-29', 125.30),
(118, 3, '2024-08-28', 150.40),
(119, 3, '2024-09-26', 160.40),
(120, 3, '2024-10-31', 210.90),

-- 2025 YEAR
(121, 1, '2025-01-06', 155.40),
(122, 1, '2025-02-18', 130.40),
(123, 1, '2025-03-30', 210.80),
(124, 1, '2025-04-29', 240.10),
(125, 1, '2025-05-28', 190.50),
(126, 1, '2025-06-27', 245.30),
(127, 1, '2025-07-26', 150.90),
(128, 1, '2025-08-24', 195.40),
(129, 1, '2025-09-26', 185.60),
(130, 1, '2025-10-30', 225.40),

(131, 2, '2025-01-09', 115.10),
(132, 2, '2025-02-21', 150.20),
(133, 2, '2025-03-29', 180.40),
(134, 2, '2025-04-30', 220.90),
(135, 2, '2025-05-29', 200.40),
(136, 2, '2025-06-26', 215.80),
(137, 2, '2025-07-28', 140.50),
(138, 2, '2025-08-23', 115.70),
(139, 2, '2025-09-27', 155.40),
(140, 2, '2025-10-29', 205.10),

(141, 3, '2025-01-11', 120.10),
(142, 3, '2025-02-24', 160.30),
(143, 3, '2025-03-31', 185.60),
(144, 3, '2025-04-29', 245.90),
(145, 3, '2025-05-28', 210.50),
(146, 3, '2025-06-30', 225.40),
(147, 3, '2025-07-29', 135.80),
(148, 3, '2025-08-26', 155.20),
(149, 3, '2025-09-28', 165.40),
(150, 3, '2025-10-30', 220.20);

-- Approach 1
SELECT * FROM transaction1;
WITH yearly AS (
    SELECT YEAR(transaction_date) AS yr,SUM(amount) AS total
    FROM transaction1 GROUP BY YEAR(transaction_date)
)
SELECT yr,total AS current_year_revenue,
LAG(total) OVER (ORDER BY yr) AS previous_year_revenue,
ROUND(((total - LAG(total) OVER (ORDER BY yr)) / LAG(total) OVER (ORDER BY yr)) * 100, 2) AS yoy_growth
FROM yearly;

-- Approach 2
WITH yearly_revenue AS (SELECT EXTRACT(YEAR FROM transaction_date) AS year,
SUM(amount) AS total_revenue FROM transaction1 GROUP BY EXTRACT(YEAR FROM transaction_date)
)
SELECT curr.year AS current_year, curr.total_revenue,prev.total_revenue AS previous_year_revenue,
ROUND(((curr.total_revenue - prev.total_revenue) / prev.total_revenue) * 100, 2) AS yoy_growth_percent FROM yearly_revenue curr
LEFT JOIN yearly_revenue prev ON curr.year = prev.year + 1;

with avg_per_cust as (select customer_id ,avg(amount) as avg_amnt from transaction1 group by 1)
Select t.*,avg_amnt from avg_per_cust join transaction1 t using(customer_id) where avg_amnt>3*t.amount;

/*
Write a query to find customers who have used more than 2 credit cards for transactions in a given month.

Assume a transactions table:
(customer_id, card_id, transaction_date)
*/
SELECT customer_id,CONCAT(YEAR(transaction_date), '-', LPAD(MONTH(transaction_date), 2, '0')) AS txn_month,
COUNT(DISTINCT card_id) AS cards_used
FROM transactions GROUP BY customer_id,CONCAT(YEAR(transaction_date), '-', LPAD(MONTH(transaction_date), 2, '0'))
HAVING COUNT(DISTINCT card_id) > 2;
