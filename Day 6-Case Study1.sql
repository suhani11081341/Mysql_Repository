use ecommerce_db;

CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  
SELECT * FROM SALES;
SELECT * FROM MEMBERS;
SELECT * FROM MENU;

/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
SELECT Customer_id,SUM(price) AS total_amount_spent FROM SALES LEFT JOIN MENU USING(PRODUCT_ID) group by 1;

-- 2. How many days has each customer visited the restaurant?
SELECT Customer_id,Count( Distinct order_date) AS total_visit FROM SALES group by 1;

-- 3. What was the first item from the menu purchased by each customer?
-- Approach 0
select distinct customer_id,first_value(product_name) over(partition by customer_id order by order_date) from sales join menu 
using(product_id);
-- Approach 1
WITH ranked AS (SELECT s.*,DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY order_date) AS rnk FROM sales AS s)
SELECT DISTINCT r.customer_id, m.product_name FROM ranked AS r JOIN menu AS m ON r.product_id = m.product_id
WHERE r.rnk = 1 ORDER BY r.customer_id, m.product_name;


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
-- APPROACH 0
Select * from (SELECT product_id, product_name,price,count(product_id) as total_qty_purchased,
Dense_Rank() Over(order by count(product_id) Desc) as Ranking FROM sales Right Join menu using (product_id) 
group by 1,2,3 order by 4 desc)temp where ranking=1;

-- APPROACH 1
SELECT m.product_name, COUNT(*) AS times_purchased FROM sales AS s
JOIN menu  AS m ON s.product_id = m.product_id GROUP BY m.product_id, m.product_name
ORDER BY times_purchased DESC LIMIT 1;

-- 5. Which item was the most popular for each customer?
-- APPROACH 0
Select * from (SELECT customer_id,product_id,product_name, count(product_id) as total_qty_purchased,
Dense_Rank() Over(partition by customer_id order by count(product_id) Desc) as Ranking FROM sales LEFT Join menu using (product_id)  
group by 1,2,3 order by 1, 4 desc) temp where  ranking=1;

-- APPROACH 1
WITH cust_prod AS ( SELECT s.customer_id,m.product_name,COUNT(*) AS cnt FROM sales AS s
    JOIN menu  AS m ON s.product_id = m.product_id GROUP BY s.customer_id, m.product_name),
ranked AS (SELECT *, DENSE_RANK() OVER ( PARTITION BY customer_id ORDER BY cnt DESC) AS rnk FROM cust_prod)
SELECT customer_id, product_name,cnt AS times_purchased FROM ranked WHERE rnk = 1
ORDER BY customer_id, product_name;

-- 6. Which item was purchased first by the customer after they became a member?
-- Approach 0
select distinct customer_id,order_date,product_name from (
SELECT customer_id,product_id,order_date,dense_rank() Over(partition by customer_id order by order_date) as ranking 
FROM sales right join members 
using (customer_id) where members.join_date<=sales.order_date
) temp Join menu on menu.product_id=temp.product_id where ranking=1 order by customer_id;

WITH member_sales AS (
    SELECT s.customer_id,s.order_date,s.product_id,m.join_date,
    DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS rnk
    FROM sales   AS s JOIN members AS m ON s.customer_id = m.customer_id WHERE s.order_date >= m.join_date)
SELECT ms.customer_id,ms.order_date,me.product_name FROM member_sales AS ms JOIN menu AS me
  ON ms.product_id = me.product_id WHERE ms.rnk = 1 ORDER BY ms.customer_id, ms.order_date;

-- 7. Which item was purchased just before the customer became a member?
SELECT * FROM SALES;
SELECT * FROM MEMBERS;
SELECT * FROM MENU;
-- Approach 0
select distinct customer_id,order_date,product_name from (
SELECT customer_id,product_id,order_date,dense_rank() Over(partition by customer_id order by order_date desc) as ranking 
FROM sales right join members 
using (customer_id) where members.join_date>sales.order_date
) temp Join menu on menu.product_id=temp.product_id where ranking=1 order by customer_id;

-- Approach 1
WITH pre_member AS (
    SELECT s.customer_id,s.order_date,s.product_id,m.join_date,
	DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS rnk
    FROM sales AS s JOIN members AS m ON s.customer_id = m.customer_id WHERE s.order_date < m.join_date)
SELECT pm.customer_id,pm.order_date,me.product_name FROM pre_member AS pm
JOIN menu AS me ON pm.product_id = me.product_id WHERE pm.rnk = 1 ORDER BY pm.customer_id;

-- 8. What is the total items and amount spent for each member before they became a member?
-- Approach 0
select customer_id,count(temp.product_id) as total_items,sum(price) as total_price from (SELECT customer_id,sales.product_id,order_date,join_date FROM sales 
right join members using (customer_id) where members.join_date>sales.order_date ) temp Join menu 
on menu.product_id=temp.product_id  group by 1 order by customer_id;

-- Approach 1
SELECT s.customer_id,COUNT(*) AS total_items,SUM(m.price) AS total_amount
FROM sales AS s JOIN members AS mem ON s.customer_id = mem.customer_id
JOIN menu AS m ON s.product_id = m.product_id WHERE s.order_date < mem.join_date
GROUP BY s.customer_id ORDER BY s.customer_id;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- Aproach 0
SELECT customer_id, 
sum(case when product_name="sushi" then 2*price*10 else price*10  end) as total_points FROM SALES  JOIN MENU  using(product_id)
group by 1;

-- Approach 1
SELECT s.customer_id,
    SUM(CASE WHEN m.product_name = 'sushi' THEN m.price * 20  ELSE m.price *10 END) AS total_points
FROM sales AS s JOIN menu AS m ON s.product_id = m.product_id GROUP BY s.customer_id ORDER BY s.customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
-- not just sushi - how many points do customer A and B have at the end of January?

-- Approach 0
SELECT customer_id,
sum(case when date_add(members.join_date, interval 6 day)>=sales.order_date and members.join_date<=sales.order_date then (price*20)
when product_name="sushi" then (price*20) else (price*10) end) as total_points 
FROM sales right join members using (customer_id) left join menu  using (product_id) 
where month(order_date)=1 and year(order_date)=2021 group by 1;

-- Approach 1
SELECT s.customer_id,SUM(CASE
            -- First week after joining: 2x points on ALL items
WHEN mem.customer_id IS NOT NULL AND s.order_date BETWEEN mem.join_date AND DATE_ADD(mem.join_date, INTERVAL 6 DAY) THEN m.price * 20
            -- Outside promo week: sushi gets 2x
WHEN m.product_name = 'sushi' THEN m.price * 20
            -- Outside promo week: others normal (10 points per $1)
ELSE m.price * 10 END) AS total_points
FROM sales AS s JOIN menu  AS m ON s.product_id = m.product_id
LEFT JOIN members AS mem ON s.customer_id = mem.customer_id
WHERE s.order_date >= '2021-01-01' AND s.order_date <  '2021-02-01' AND s.customer_id IN ('A', 'B')
GROUP BY s.customer_id ORDER BY s.customer_id;
