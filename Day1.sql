use ecommerce_db;
show tables;
table customers order by status;
select 1 as integer1;

-- Drop table if it already exists (optional)
DROP TABLE IF EXISTS test_scores;

-- Create table
CREATE TABLE test_scores (
    subject VARCHAR(50) NOT NULL,
    test    CHAR(1)     NOT NULL,
    score   INT         NULL
);

-- Insert data
INSERT INTO test_scores (subject, test, score) VALUES
('Jane',   'A', 47),
('Jane',   'B', 50),
('Jane',   'C', NULL),
('Jane',   'D', NULL),
('Marvin', 'A', 52),
('Marvin', 'B', 45),
('Marvin', 'C', 53),
('Marvin', 'D', NULL);

-- (Optional) Check data
SELECT * FROM test_scores;
select * from test_scores where score is null;
select * from test_scores where score is not null;
select * from test_scores where score <=> null;

/*The MySQL-specific <=> null-safe comparison operator, unlike the =
operator, is true even for two NULL values:*/
SELECT NULL = NULL, NULL <=> NULL;

-- Approach 1
SELECT subject, test, IF(score IS NULL,'Unknown', score) AS 'score' FROM test_scores;
-- Approach 2
SELECT subject, test, (CASE when score IS NULL THEN 'Unknown' ELSE score END) AS 'score' FROM test_scores;

/*
IF(expr1 IS NOT NULL,expr1,expr2)
IFNULL(expr1,expr2) */
-- Approach 3
SELECT subject, test, IFNULL(score,'Unknown') AS 'score' FROM test_scores;

-- Approach 4
/* One more way to map NULL values is to use the COALESCE function,which returns the first not-null element 
from the list of parameters:*/
SELECT subject, test, COALESCE(score,'Unknown') AS 'score' FROM test_scores;

/*For example, in Python, None represents a NULL value, so to construct a statement that finds rows
in the expt table matching some arbitrary value in a score variable, you
cannot do this:

cursor.execute("SELECT * FROM expt WHERE score = %s", (score,))

The statement fails when score is None because the resulting statement becomes the following:

SELECT * FROM expt WHERE score = NULL;

A comparison of score = NULL is never true, so that statement returns no rows. To take into account the possibility that 
score could be None, construct the statement using the appropriate comparison operator like this:

operator = "IS" if score is None else "="
cursor.execute("SELECT * FROM expt WHERE score {}%s".format(operator), (score,))*/

/* This results in statements as follows for score values of None (NULL) or 43 (not NULL):

SELECT * FROM expt WHERE score IS NULL
SELECT * FROM expt WHERE score = 43;

For inequality tests, set operator like this instead:
  operator = "IS NOT" if score is None else "<>" */
  
CREATE VIEW high_scores AS
SELECT subject, test, score FROM test_scores WHERE score > 50;

SELECT * FROM high_scores;

-- ================================
-- 1. Drop tables if they exist
-- ================================
DROP TABLE IF EXISTS profile_contact;
DROP TABLE IF EXISTS profile;

-- ================================
-- 2. Create profile table
-- ================================
CREATE TABLE profile (
    id      INT PRIMARY KEY,
    name    VARCHAR(50) NOT NULL,
    service VARCHAR(100) NOT NULL
);

-- ================================
-- 3. Create profile_contact table
-- ================================
CREATE TABLE profile_contact (
    contact_id   INT PRIMARY KEY,
    profile_id   INT NOT NULL,
    contact_name VARCHAR(100) NOT NULL,
    service      VARCHAR(100) NOT NULL,
    CONSTRAINT fk_profile
        FOREIGN KEY (profile_id) REFERENCES profile(id)
);

-- ================================
-- 4. Insert sample data into profile
-- ================================
INSERT INTO profile (id, name, service) VALUES
(1, 'Nancy',       'Plumbing'),
(2, 'Nancy',       'Electrical'),
(3, 'John',        'Carpentry'),
(4, 'Alice',       'Interior Design'),
(5, 'Michael',     'Landscaping');

-- ================================
-- 5. Insert sample data into profile_contact
-- ================================
INSERT INTO profile_contact (contact_id, profile_id, contact_name, service) VALUES
(101, 1, 'Nancy Home Services',    'Kitchen Plumbing'),
(102, 1, 'Nancy Pro Services',     'Bathroom Plumbing'),
(103, 2, 'Nancy Electric Works',   'House Wiring'),
(104, 2, 'Nancy Power Fixers',     'Appliance Repair'),
(105, 3, 'John Handy Team',        'Furniture Repair'),
(106, 4, 'Alice Design Studio',    'Living Room Design'),
(107, 5, 'GreenScape by Michael',  'Garden Setup'),
(108, 5, 'Michael Lawn Care',      'Lawn Maintenance');

-- ================================
-- 6. JOIN example with ORDER BY + LIMIT
--    (Get top 3 contacts for all profiles, sorted by service)
-- ================================
SELECT * FROM profile;
SELECT * FROM profile_contact;
SELECT p.id,p.name,p.service AS main_service,pc.contact_name,pc.service AS contact_service
FROM profile p INNER JOIN profile_contact pc ON p.id = pc.profile_id ORDER BY pc.service ASC LIMIT 3;

-- ================================
-- 7. JOIN example filtered for Nancy
-- ================================
SELECT p.id,p.name,p.service AS main_service,pc.contact_name,pc.service AS contact_service
FROM profile p INNER JOIN profile_contact pc ON p.id = pc.profile_id WHERE p.name = 'Nancy'
ORDER BY pc.service ASC LIMIT 3;

-- ================================
-- 8. SUBQUERY example with ORDER BY + LIMIT
--    (Use subquery to find Nancy's first profile id)
-- ================================
SELECT profile_id,service,contact_name FROM profile_contact
WHERE profile_id = (
    SELECT id FROM profile WHERE name = 'Nancy' ORDER BY id ASC LIMIT 1      -- in case Nancy has multiple profiles
) ORDER BY service ASC LIMIT 2;

-- ================================
-- 9. Simple check of base tables
-- ================================
SELECT * FROM profile;
SELECT * FROM profile_contact;


-- =========================================
-- Use database
-- =========================================
-- USE ecommerce_db;

-- =========================================
-- 1. Drop table if exists
-- =========================================
DROP TABLE IF EXISTS card_txns;

-- =========================================
-- 2. Create card_txns table
-- =========================================
CREATE TABLE card_txns (
    txn_id   INT PRIMARY KEY,
    cardno   VARCHAR(25) NOT NULL,
    txn_date DATE        NOT NULL,
    amount   DECIMAL(12,2) NOT NULL
);

-- =========================================
-- 3. Insert REAL-WORLD style (fake) 16-digit card numbers
--    WITH hyphens
-- =========================================
INSERT INTO card_txns (txn_id, cardno, txn_date, amount) VALUES

-- Card: Visa 4532-1234-1234-1234
(1,  '4532-1234-1234-1234', '2025-01-05',  500.00),
(2,  '4532-1234-1234-1234', '2025-01-10', 1200.00),
(3,  '4532-1234-1234-1234', '2025-01-15',  750.00),
(4,  '4532-1234-1234-1234', '2025-02-01', 3000.00),

-- Card: Mastercard 5123-4567-8901-2345
(5,  '5123-4567-8901-2345', '2025-01-03',  200.00),
(6,  '5123-4567-8901-2345', '2025-01-12', 1800.00),
(7,  '5123-4567-8901-2345', '2025-01-20',  950.00),
(8,  '5123-4567-8901-2345', '2025-02-02', 4000.00),

-- Card: Visa 4012-8888-8888-1881
(9,  '4012-8888-8888-1881', '2025-01-07',  600.00),
(10, '4012-8888-8888-1881', '2025-01-18', 2200.00),
(11, '4012-8888-8888-1881', '2025-01-25',  300.00),

-- Card: Mastercard 5424-1802-7979-1741
(12, '5424-1802-7979-1741', '2025-01-09', 1500.00),
(13, '5424-1802-7979-1741', '2025-01-22', 2700.00),
(14, '5424-1802-7979-1741', '2025-02-03',  800.00),
(15, '5424-1802-7979-1741', '2025-02-05', 5000.00);

-- =========================================
-- 4. Check all inserted rows
-- =========================================
SELECT * FROM card_txns;
-- Approach 1
SELECT cardno,sum(amount)  total_amount FROM card_txns group by 1
ORDER BY total_amount DESC LIMIT 3;
-- Approach 2
SELECT cardno,sum(amount) total_amount,ROW_NUMBER() OVER (ORDER BY sum(amount) DESC) AS ranking FROM card_txns group by 1
ORDER BY ranking LIMIT 3;

/*Use cases
Syntax	              Meaning	                    Example
LIMIT 5	              First 5 rows	                Preview table
LIMIT 3	              Top 3	                        Top 3 highest salary (with ORDER BY)
LIMIT 5, 10	          Skip 5 rows, return next 10	Pagination (page 2)
LIMIT 1 OFFSET 7	  8th row	                    Get 1 row after skipping 7 (skip offset rows, return count rows)*/
