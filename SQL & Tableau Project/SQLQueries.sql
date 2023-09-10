SELECT * FROM pizza_sales

/*1.	Total Revenue: The sum of the total price of all pizza orders.*/
SELECT  SUM(total_price) AS Revenue FROM pizza_sales


/*2.    Average Order Value: The average amount spent per order, calculated by dividing the total revenue by the total number of orders.*/
SELECT  SUM(total_price)/COUNT(DISTINCT order_id) AS Average_Order_Value FROM pizza_sales


/*3.   Total Pizzas Sold: The sum of the quantities of all pizzas sold.*/
SELECT SUM(quantity) AS total_pizza_sold FROM pizza_sales

/*4.  Total Orders: The total number of orders placed.*/
SELECT COUNT(DISTINCT order_id) AS total_orders_placed FROM pizza_sales

/*5.  Average Pizzas Per Order: The average number of pizzas sold per order, 
calculated by dividing the total number of pizzas sold by the total number of orders.*/

SELECT CAST(
CAST(SUM(quantity) AS decimal(10,2))/CAST(COUNT(DISTINCT order_id)AS decimal(10,2)) AS decimal(10,2)
) AS Avg_pizza_orders  FROM pizza_sales


--Hourly trend for total pizzas sold

SELECT DATEPART(HOUR, order_time) AS order_hour, SUM(quantity) as Total_pizza_sold_hourly FROM pizza_sales
GROUP BY DATEPART(HOUR, order_time)
ORDER BY DATEPART(HOUR, order_time)

--Weekly trend for total orders

SELECT DATEPART(ISO_WEEK, order_date) AS week_number, YEAR(order_date) AS order_year, COUNT(DISTINCT order_id) Total_orders
FROM pizza_sales
GROUP BY DATEPART(ISO_WEEK, order_date), YEAR(order_date)
ORDER BY DATEPART(ISO_WEEK, order_date), YEAR(order_date)

-- Percentage of Sales by Pizza Category
SELECT pizza_category, SUM(total_price)*100/(SELECT SUM(total_price) FROM pizza_sales) AS percentage_of_sales   
FROM pizza_sales
GROUP BY pizza_category

--Percentage of Sales by Pizza Size:
SELECT pizza_size, CAST(SUM(total_price)*100 / (SELECT SUM(total_price) FROM pizza_sales) AS DECIMAL(10,2)) AS percentage_of_sales  
FROM pizza_sales
GROUP BY pizza_size
ORDER BY percentage_of_sales  desc

-- Top 5 Best Sellers by Revenue, Total Quantity and Total Orders
SELECT TOP 5 pizza_name, SUM(total_price) AS Revenue FROM pizza_sales
GROUP BY pizza_name
ORDER BY Revenue DESC

SELECT TOP 5 pizza_name, SUM(quantity) AS Quantity FROM pizza_sales
GROUP BY pizza_name
ORDER BY Quantity DESC

SELECT TOP 5 pizza_name, COUNT(DISTINCT order_id) AS total_orders FROM pizza_sales
GROUP BY pizza_name
ORDER BY total_orders DESC


--Bottom 5 Best Sellers by Revenue, Total Quantity and Total Orders
SELECT TOP 5 pizza_name, SUM(total_price) AS Revenue FROM pizza_sales
GROUP BY pizza_name
ORDER BY REVENUE ASC

SELECT TOP 5 pizza_name, SUM(quantity) AS Quantity FROM pizza_sales
GROUP BY pizza_name
ORDER BY Quantity ASC

SELECT TOP 5 pizza_name, COUNT(DISTINCT order_id) AS total_orders FROM pizza_sales
GROUP BY pizza_name
ORDER BY total_orders ASC