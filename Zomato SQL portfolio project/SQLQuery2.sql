select *
from sales

select *
from product

SELECT *
FROM goldusers_signup

select *
from users

/* 1. what is the total amount spent by each customer on zomato?*/

SELECT a.userid, sum(b.price) as total_amount_spent
FROM sales as a JOIN product as b ON a.product_id = b.product_id
GROUP BY userid

/* 2. how many days has each customer visited zomato?*/

SELECT userid, COUNT(DISTINCT created_date) as total_visit
FROM sales
GROUP BY userid

/* 3. what was the first product purchased by each customer?*/

SELECT * FROM
(SELECT *, RANK() OVER( PARTITION BY userid ORDER BY created_date) as rnk FROM sales) a WHERE rnk=1

/* 4. what is the most purchased item on the menu and how many times was it purchased by all the customers?*/

SELECT userid, count(product_id) as cnt FROM sales WHERE product_id =
(SELECT TOP 1 product_id FROM sales GROUP BY product_id ORDER BY COUNT(product_id) DESC)
GROUP BY userid

/*5.  which item was the most popular for each customer?*/

SELECT * FROM
(SELECT *, RANK() OVER(PARTITION BY userid ORDER BY popular_item DESC) as rnk FROM
(SELECT userid,  product_id, count(product_id) as popular_item FROM sales  GROUP BY userid, product_id) a) b
WHERE rnk = 1

/* 6. which item was purchased first by the customer after they became a member?*/

SELECT * FROM
(SELECT c.*, RANK() OVER(PARTITION BY userid ORDER BY created_date) as rnk FROM
(SELECT s.userid, s.created_date, s.product_id, gu.gold_signup_date 
FROM goldusers_signup as gu INNER JOIN sales as s 
ON gu.userid = s.userid AND s.created_date >= gu.gold_signup_date) c) d WHERE rnk = 1;

/* 7. which item was purchased just before the customer became a member?*/

SELECT * FROM
(SELECT a.*, RANK() OVER(PARTITION BY userid ORDER BY created_date DESC) AS RNK FROM
(SELECT s.userid, s.created_date, s.product_id, g.gold_signup_date  FROM sales AS s
INNER JOIN goldusers_signup AS g ON s.userid = g.userid AND s.created_date < g.gold_signup_date) a) b 
WHERE RNK = 1

/* 8. what is the total orders and amount spent for each member before the became a member?*/

SELECT s.userid, COUNT(s.created) AS cnt, SUM(p.price) AS spent  FROM sales AS s
INNER JOIN goldusers_signup AS g ON s.userid = g.userid AND s.created_date < g.gold_signup_date
INNER JOIN product AS p ON s.product_id = p.product_id
GROUP BY s.userid

/* If buying each product generates points for eg 5rs = 2 point and each product has different purchasing points 
for eg for p1 5rs=1 point, for p2 10rs=5 zomato points and for p3 5rs=1 point.
Calculate points collected by each customer and for which product most points have been given till now?*/

SELECT userid, SUM(total_points) AS user_points FROM
(SELECT c.*, amount/points AS total_points FROM 
(SELECT b.*, CASE WHEN product_id = 1 THEN 5 WHEN product_id = 2 THEN 2 WHEN product_id = 3 THEN 5 END AS points
FROM
(SELECT a.userid, a.product_id, SUM(price) AS amount FROM
(SELECT s.*, p.price FROM sales as s INNER JOIN product as p ON s.product_id = p.product_id) a
GROUP BY userid, product_id) b) c) d GROUP BY userid


/* 10. In the first one year after a customer joins the gold program (including their join date) irrespective 
of what the customer has purchased they earn 5 zomato points for every 10 rs spent who earned more 1 or 3 and what was their
points earnings in their first year?*/

/* 1 pt = 2 rs */

SELECT a.*, p.price/2 FROM
(SELECT s.*, g.gold_signup_date
FROM sales as s INNER JOIN goldusers_signup as g 
ON s.userid = g.userid AND s.created_date >= g.gold_signup_date AND created_date <= DATEADD(YEAR, 1, gold_signup_date)) a
INNER JOIN product as p ON a.product_id = p.product_id


/* 11. Rank all the transactions of the customers */

SELECT *, RANK() OVER(PARTITION BY userid ORDER BY created_date) as RANK1 FROM sales

/* 12. Rank all the transactions for each member whenever they are a zomato gold member for every non gold member transaction marked as na */

SELECT b.*, CASE WHEN RNK=0 THEN 'NA' ELSE RNK END AS RANK1 FROM
(SELECT a.*, 
CAST(
	(CASE WHEN gold_signup_date IS NULL THEN 0 ELSE RANK() OVER(PARTITION BY userid ORDER BY created_date DESC) END) 
	as varchar) as RNK FROM
(SELECT s.*, g.gold_signup_date FROM sales as s LEFT JOIN goldusers_signup as g	
ON s.userid = g.userid AND created_date>= gold_signup_date) a) b