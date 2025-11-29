/* What to Do When LIMIT and the Final Result Require a Different Sort Order
Problem:
LIMIT usually works best in conjunction with an ORDER BY clause that sorts rows. But sometimes that sort order differs from 
what you want for the final result.
Solution:
Use LIMIT in a subquery to retrieve the desired rows, then use the outer query to sort them.
Discussion:
If you want the last four rows of a result set, you can obtain them easily by sorting the set in reverse order and using LIMIT 4. 
*/

-- Optional: choose your database
-- USE your_database_name;

use erp_demo;
-- ===========================================
-- 1) card_txns : for TOP-N by amount, then re-sort
-- ===========================================
DROP TABLE IF EXISTS card_txns;

CREATE TABLE card_txns (
    txn_id   INT PRIMARY KEY,
    cardno   VARCHAR(19),
    txn_date DATE,
    amount   DECIMAL(10,2)
);

INSERT INTO card_txns (txn_id, cardno, txn_date, amount) VALUES
-- Card 1: Visa 4532-1234-1234-1234
(1,  '4532-1234-1234-1234', '2025-01-05',  500.00),
(2,  '4532-1234-1234-1234', '2025-01-10', 1200.00),
(3,  '4532-1234-1234-1234', '2025-01-15',  750.00),
(4,  '4532-1234-1234-1234', '2025-02-01', 3000.00),

-- Card 2: Mastercard 5123-4567-8901-2345
(5,  '5123-4567-8901-2345', '2025-01-03',  200.00),
(6,  '5123-4567-8901-2345', '2025-01-12', 1800.00),
(7,  '5123-4567-8901-2345', '2025-01-20',  950.00),
(8,  '5123-4567-8901-2345', '2025-02-02', 4000.00),

-- Card 3: Visa 4012-8888-8888-1881
(9,  '4012-8888-8888-1881', '2025-01-07',  600.00),
(10, '4012-8888-8888-1881', '2025-01-18', 2200.00),
(11, '4012-8888-8888-1881', '2025-01-25',  300.00),

-- Card 4: Mastercard 5424-1802-7979-1741
(12, '5424-1802-7979-1741', '2025-01-09', 1500.00),
(13, '5424-1802-7979-1741', '2025-01-22', 2700.00),
(14, '5424-1802-7979-1741', '2025-02-03',  800.00),
(15, '5424-1802-7979-1741', '2025-02-05', 5000.00);

SELECT * FROM card_txns LIMIT 5;
SELECT * FROM card_txns ORDER BY AMOUNT DESC LIMIT 5;
/*
ORDER BY contains aggregate function and applies to the result of a 
non-aggregated query
SELECT * FROM card_txns ORDER BY SUM(AMOUNT) LIMIT 5;
*/
SELECT cardno,SUM(AMOUNT) total_amount FROM card_txns GROUP BY cardno 
ORDER BY total_amount DESC LIMIT 5;

-- Example 1: Top 5 highest txns, then display from smallest to largest
-- (LIMIT and final ORDER BY different)

-- SELECT * FROM card_txns ORDER BY amount DESC  -- pick highest
-- LIMIT 5 ORDER BY amount ASC;  -- ❌ Not allowed after LIMIT

SELECT * FROM (SELECT * FROM card_txns ORDER BY amount DESC LIMIT 5) t 
ORDER BY amount ASC;


-- ===========================================
-- 2) orders : latest N orders but display oldest→newest
-- ===========================================
DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
    order_id     INT PRIMARY KEY,
    customer_name VARCHAR(50),
    order_date   DATE,
    order_amount DECIMAL(10,2)
);

INSERT INTO orders (order_id, customer_name, order_date, order_amount) VALUES
(101, 'Alice',   '2025-01-01', 1200.00),
(102, 'Bob',     '2025-01-03',  800.00),
(103, 'Charlie', '2025-01-05', 1500.00),
(104, 'Diana',   '2025-01-08',  950.00),
(105, 'Ethan',   '2025-01-10', 600.00),
(106, 'Farah',   '2025-01-12', 2000.00),
(107, 'George',  '2025-01-15', 500.00),
(108, 'Hina',    '2025-01-18', 2500.00),
(109, 'Ishaan',  '2025-01-20', 1750.00),
(110, 'Jiya',    '2025-01-22', 900.00),
(111, 'Karan',   '2025-01-25', 3000.00),
(112, 'Leena',   '2025-01-28', 1800.00);

-- Example 2: Get 5 latest orders, but show them oldest→newest
SELECT * FROM (SELECT * FROM orders ORDER BY order_date DESC LIMIT 5) x
ORDER BY order_date ASC;


-- ===========================================
-- 3) customers : pagination example (LIMIT offset, count)
-- ===========================================
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id   INT PRIMARY KEY,
    customer_name VARCHAR(50),
    revenue       DECIMAL(12,2)
);

INSERT INTO customers (customer_id, customer_name, revenue) VALUES
(1,  'Alpha Corp',    50000.00),
(2,  'Beta Ltd',      75000.00),
(3,  'Cyan Systems',  62000.00),
(4,  'Delta Traders', 90000.00),
(5,  'Echo Media',    55000.00),
(6,  'Foxtrot Inc',   30000.00),
(7,  'Gamma Group',   82000.00),
(8,  'Helix Labs',    40000.00),
(9,  'Indigo Co',     95000.00),
(10, 'Jupiter LLC',   70000.00),
(11, 'Krypton Tech',  45000.00),
(12, 'Lumen Services',38000.00);

-- Example 3: Page 2 (next 5 customers by revenue DESC),then show them by name ASC in UI
SELECT * FROM (SELECT * FROM customers ORDER BY revenue DESC LIMIT 5 OFFSET 5
) p ORDER BY customer_name ASC;


-- ===========================================
-- 4) employees : top N per department (ROW_NUMBER + LIMIT pattern)
-- ===========================================
DROP TABLE IF EXISTS employees;

CREATE TABLE employees (
    emp_id   INT PRIMARY KEY,
    emp_name VARCHAR(50),
    dept     VARCHAR(50),
    salary   DECIMAL(10,2)
);

INSERT INTO employees (emp_id, emp_name, dept, salary) VALUES
(1,  'Amit',    'Sales',     45000.00),
(2,  'Bhavna',  'Sales',     52000.00),
(3,  'Chetan',  'Sales',     61000.00),
(4,  'Deepa',   'Sales',     48000.00),
(5,  'Esha',    'Finance',   70000.00),
(6,  'Farhan',  'Finance',   65000.00),
(7,  'Gauri',   'Finance',   72000.00),
(8,  'Harsh',   'Finance',   55000.00),
(9,  'Ira',     'IT',        80000.00),
(10, 'Jay',     'IT',        78000.00),
(11, 'Kriti',   'IT',        60000.00),
(12, 'Lalit',   'IT',        82000.00);

-- Example 4: Top 2 highest paid employees per dept, display by dept/name
SELECT * FROM (
    SELECT emp_id,emp_name,dept,salary,
	ROW_NUMBER() OVER (PARTITION BY dept ORDER BY salary DESC) AS rn FROM employees
) t WHERE rn <= 2 ORDER BY dept, emp_name;


-- ===========================================
-- 5) invoices : top N invoices, then display low→high
-- ===========================================
DROP TABLE IF EXISTS invoices;

CREATE TABLE invoices (
    invoice_id   INT PRIMARY KEY,
    customer_name VARCHAR(50),
    invoice_date DATE,
    amount       DECIMAL(10,2)
);

INSERT INTO invoices (invoice_id, customer_name, invoice_date, amount) VALUES
(201, 'Alpha Corp',   '2025-02-01', 12000.00),
(202, 'Beta Ltd',     '2025-02-03',  8000.00),
(203, 'Cyan Systems', '2025-02-05', 15000.00),
(204, 'Delta Traders','2025-02-07', 22000.00),
(205, 'Echo Media',   '2025-02-10',  5000.00),
(206, 'Foxtrot Inc',  '2025-02-12', 30000.00),
(207, 'Gamma Group',  '2025-02-15', 27000.00),
(208, 'Helix Labs',   '2025-02-18', 18000.00);

-- Example 5: Pick largest 5 invoices, then display from lowest→highest
SELECT * FROM (SELECT * FROM invoices ORDER BY amount DESC LIMIT 5) t ORDER BY amount ASC;

/*
It does NOT allow expressions, variables, or formulas inside LIMIT.
So these are NOT allowed:

❌ LIMIT 5 + 5;
❌ LIMIT @skip_count, @show_count;
❌ LIMIT x + y;

This is because the SQL parser expects LIMIT to contain only actual integers — nothing else.

🌟 Why LIMIT cannot use expressions?
Because LIMIT is handled at a very low SQL-parsing level, and MySQL wants the number of rows to be known before execution, not computed dynamically inside the SQL.
So LIMIT must be something like:

LIMIT 0
LIMIT 10
LIMIT 20, 10

But not:
LIMIT some expression
LIMIT a + b
LIMIT variable
❌ WRONG EXAMPLES (not allowed)
1. NOT ALLOWED:
SELECT * FROM profile LIMIT 5+5;
Even though 5+5 = 10, MySQL rejects it.

2️. NOT ALLOWED:
SELECT * FROM profile LIMIT @skip_count, @show_count;
MySQL does not evaluate variables directly inside LIMIT.

3️. NOT ALLOWED when building dynamic SQL:
$str = "SELECT * FROM profile LIMIT $x + $y";  
This creates SQL text:
SELECT * FROM profile LIMIT 3 + 4;

Still invalid.
*/

-- Inshort
/* MySQL LIMIT accepts only actual integers, not calculations.
   If you need a calculation, do it outside SQL first.
*/

-- Use your DB
-- USE your_database_name;

-- 1. Drop + create mail table
DROP TABLE IF EXISTS mail;

CREATE TABLE mail (
    id        INT PRIMARY KEY AUTO_INCREMENT,
    srcuser   VARCHAR(50),
    srchost   VARCHAR(50),
    dstuser   VARCHAR(50),
    dsthost   VARCHAR(50),
    sent_at   DATETIME
);

-- 2. Insert sample data
INSERT INTO mail (srcuser, srchost, dstuser, dsthost, sent_at) VALUES
-- Alice sends to Bob / Carol on hostA → hostX/Y
('alice',   'hostA.com', 'bob',    'hostX.com', '2025-01-01 10:00:00'),
('alice',   'hostA.com', 'carol',  'hostY.com', '2025-01-01 11:00:00'),
('alice',   'hostA.com', 'bob',    'hostX.com', '2025-01-02 09:00:00'),

-- Bob sends to Alice / Dave from hostX
('bob',     'hostX.com', 'alice',  'hostA.com', '2025-01-02 12:00:00'),
('bob',     'hostX.com', 'dave',   'hostZ.com', '2025-01-03 08:30:00'),

-- Carol sends to Alice / Eve from hostY
('carol',   'hostY.com', 'alice',  'hostA.com', '2025-01-03 09:45:00'),
('carol',   'hostY.com', 'eve',    'hostZ.com', '2025-01-03 10:15:00'),

-- Dave sends to Bob from hostZ
('dave',    'hostZ.com', 'bob',    'hostX.com', '2025-01-04 14:00:00'),

-- Eve sends to many from hostZ
('eve',     'hostZ.com', 'alice',  'hostA.com', '2025-01-04 15:00:00'),
('eve',     'hostZ.com', 'bob',    'hostX.com', '2025-01-04 16:00:00'),
('eve',     'hostZ.com', 'carol',  'hostY.com', '2025-01-05 09:00:00');

-- =========================================================
-- QUERY 1: All unique (user, host) pairs seen as sender or receiver
-- =========================================================

SELECT DISTINCT srcuser AS user, srchost AS host
FROM mail
UNION   -- remove duplicates between sender/receiver side
SELECT DISTINCT dstuser AS user, dsthost AS host
FROM mail;

-- =========================================================
-- QUERY 2: Top 4 sender addresses and top 4 receiver addresses
--          then combine them (keeping duplicates) and sort by user
-- =========================================================

( SELECT CONCAT(srcuser, '@', srchost) AS user, COUNT(*) AS emails FROM mail GROUP BY srcuser, srchost
    ORDER BY emails DESC LIMIT 4 )
UNION ALL   -- keep duplicates from src + dst lists
( SELECT CONCAT(dstuser, '@', dsthost) AS user, COUNT(*) AS emails FROM mail GROUP BY dstuser, dsthost
  ORDER BY emails DESC LIMIT 4)ORDER BY user;

------------------------------------------------------------
-- 2) BANK_TRANSFERS: money sent vs money received
------------------------------------------------------------

DROP TABLE IF EXISTS bank_transfers;

CREATE TABLE bank_transfers (
    txn_id    INT PRIMARY KEY AUTO_INCREMENT,
    from_acct VARCHAR(20),
    to_acct   VARCHAR(20),
    amount    DECIMAL(10,2),
    txn_date  DATE
);

INSERT INTO bank_transfers (from_acct, to_acct, amount, txn_date) VALUES
('ACCT001', 'ACCT002', 5000.00, '2025-03-01'),
('ACCT001', 'ACCT003', 2000.00, '2025-03-02'),
('ACCT001', 'ACCT004', 1500.00, '2025-03-03'),

('ACCT002', 'ACCT001', 3000.00, '2025-03-04'),
('ACCT002', 'ACCT003', 2500.00, '2025-03-05'),

('ACCT003', 'ACCT001', 1000.00, '2025-03-06'),
('ACCT003', 'ACCT004', 4000.00, '2025-03-07'),

('ACCT004', 'ACCT002', 3500.00, '2025-03-08'),
('ACCT004', 'ACCT003', 1200.00, '2025-03-09');

-- Amount sent vs amount received per account
SELECT * FROM bank_transfers;

-- Aproach 1
SELECT b.from_acct AS account,SUM(b.amount) AS total_sent,
(SELECT COALESCE(SUM(d.amount), 0) FROM bank_transfers d WHERE d.to_acct = b.from_acct) AS total_received
FROM bank_transfers b GROUP BY b.from_acct ORDER BY total_sent DESC;

-- Aproach 2
SELECT account,SUM(sent_amount) AS total_sent,SUM(received_amount) AS total_received
FROM ( -- outgoing money
    SELECT from_acct AS account,amount AS sent_amount,0 AS received_amount FROM bank_transfers
    UNION ALL
    -- incoming money
    SELECT to_acct AS account,0 AS sent_amount,amount AS received_amount FROM bank_transfers
) t GROUP BY account ORDER BY total_sent DESC;

-- Approach 3
/*
❗ Important point
The driving table is s (sent side, from_acct).
So this query will show only accounts that have sent something.
If an account only received but never sent → it won’t appear at all.
*/

SELECT s.from_acct AS account, s.total_sent,COALESCE(r.total_received, 0) AS total_received
FROM (SELECT from_acct, SUM(amount) AS total_sent FROM bank_transfers GROUP BY from_acct ) AS s
LEFT JOIN (SELECT to_acct, SUM(amount) AS total_received FROM bank_transfers  GROUP BY to_acct) AS r
ON r.to_acct = s.from_acct ORDER BY account;

-- Approach 4
WITH accounts AS ( 
    SELECT from_acct AS account FROM bank_transfers
    UNION
    SELECT to_acct AS account FROM bank_transfers
) 
SELECT a.account,COALESCE(s.total_sent, 0) AS total_sent, COALESCE(r.total_received, 0) AS total_received
FROM accounts a LEFT JOIN ( SELECT from_acct AS account, SUM(amount) AS total_sent FROM bank_transfers
    GROUP BY from_acct ) AS s ON s.account = a.account
LEFT JOIN ( SELECT to_acct AS account, SUM(amount) AS total_received FROM bank_transfers GROUP BY to_acct) AS r
ON r.account = a.account ORDER BY a.account;
/*
Summary of logical order
Build CTE accounts (UNION of from_acct and to_acct, unique accounts)
Build s = totals sent per from_acct
Build r = totals received per to_acct
Main FROM accounts a
LEFT JOIN s ON s.account = a.account
LEFT JOIN r ON r.account = a.account
Evaluate SELECT list with COALESCE
Apply ORDER BY a.account */

-- Approach 5
SELECT s.from_acct AS account,s.total_sent,COALESCE(r.total_received, 0) AS total_received
FROM ( SELECT from_acct, SUM(amount) AS total_sent FROM bank_transfers GROUP BY from_acct) AS s
LEFT JOIN ( SELECT to_acct, SUM(amount) AS total_received FROM bank_transfers GROUP BY to_acct) AS r
ON r.to_acct = s.from_acct ORDER BY account;


/*Logical order of execution (high-level)
   SQL never runs in the same order as we write it.
   For this query, the logical order is:
   - FROM bank_transfers
   - WHERE ... (none here)
   - GROUP BY ... (none here)
   - Window functions (SUM(...) OVER (...))
   - SELECT list (pick columns)
   - DISTINCT (remove duplicate rows based on all selected columns)
   - ORDER BY (none here)
   - LIMIT (none here)*/

