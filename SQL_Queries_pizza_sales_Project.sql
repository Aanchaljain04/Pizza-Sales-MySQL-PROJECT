-- 1. Retrieve the total number of orders placed.
SELECT COUNT(*) AS Total_Orders
FROM orders;

-- 2. Calculate the total revenue generated from pizza sales.
SELECT ROUND(SUM(od.quantity * p.price), 2) AS Total_Revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id;

-- 3. Total Number of Pizzas Sold.
SELECT SUM(quantity) AS Total_Pizzas_Sold
FROM order_details;

-- 4. Find the Average order value.
WITH order_revenue AS (
    SELECT od.order_id, SUM(od.quantity * p.price) AS Revenue
    FROM order_details od
    JOIN pizzas p ON od.pizza_id = p.pizza_id
    GROUP BY od.order_id
)
SELECT ROUND(AVG(Revenue), 2) AS Average_Order_Value
FROM order_revenue;

-- 5. Find the Average Order Quantity (AOQ).
WITH order_quantity AS (
    SELECT order_id, SUM(quantity) AS Quantity
    FROM order_details
    GROUP BY order_id
)
SELECT ROUND(AVG(Quantity), 2) AS Average_Order_Quantity
FROM order_quantity;

-- 6. Identify the highest-priced pizza.
SELECT UCASE(pizza_id) AS Highest_Priced_Pizza, price AS Price
FROM pizzas
WHERE price = (SELECT MAX(price) FROM pizzas);

-- 7. Identify the most common pizza size ordered.
SELECT p.size AS Most_Common_Size, SUM(quantity) AS Order_Count
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY SUM(quantity) DESC
LIMIT 1;

-- 8. List the top 5 most ordered pizza types along with their quantities.
SELECT pt.name AS Pizza_Type, SUM(od.quantity) AS Total_Quantity
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY Total_Quantity DESC
LIMIT 5;

-- 9. JOIN the necessary tables to find the total quantity of each pizza category ordered.
SELECT pt.category AS Pizza_Category, SUM(od.quantity) AS Total_Quantity
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY Total_Quantity DESC;

-- 10. Determine the distribution of orders by hour of the day.
SELECT HOUR(order_time) AS Hour, COUNT(order_id) AS Order_Count
FROM orders
GROUP BY HOUR(order_time)
ORDER BY HOUR(order_time);

-- 11. JOIN relevant tables to find the category-wise distribution of pizzas.
SELECT pt.category AS Category, COUNT(*) AS Pizza_Count
FROM pizza_types pt
JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.category
ORDER BY COUNT(*) DESC;

-- 12. Count the Pizza Varieties in each category.
SELECT category AS Category, COUNT(*) AS Count_of_Varieties
FROM pizza_types
GROUP BY category
ORDER BY COUNT(*) DESC;

-- 13. Group the orders by date and calculate the average number of pizzas ordered per day.
WITH daily_pizza_orders AS (
    SELECT order_date, SUM(quantity) AS Count_of_Pizzas
    FROM orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY order_date
)
SELECT ROUND(AVG(Count_of_Pizzas), 2) AS Daily_Pizza_Orders_Avg
FROM daily_pizza_orders;

-- 14. Determine the top and bottom 3 most ordered pizza types based on revenue.
WITH pizza_revenue AS (
    SELECT pt.name AS Pizza_Type, ROUND(SUM(od.quantity * p.price), 2) AS Revenue
    FROM order_details od
    JOIN pizzas p ON od.pizza_id = p.pizza_id
    JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY pt.name
)
SELECT Pizza_Type AS Most_Ordered_Pizza_Types, Revenue
FROM pizza_revenue
ORDER BY Revenue DESC
LIMIT 3;

WITH pizza_revenue AS (
    SELECT pt.name AS Pizza_Type, ROUND(SUM(od.quantity * p.price), 2) AS Revenue
    FROM order_details od
    JOIN pizzas p ON od.pizza_id = p.pizza_id
    JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY pt.name
)
SELECT Pizza_Type AS Least_Ordered_Pizza_Types, Revenue
FROM pizza_revenue
ORDER BY Revenue
LIMIT 3;

-- 15. Calculate the percentage contribution of each pizza type to total revenue.
WITH pizza_revenue AS (
    SELECT pt.name AS Pizza_Type, SUM(od.quantity * p.price) AS Revenue
    FROM order_details od
    JOIN pizzas p ON od.pizza_id = p.pizza_id
    JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY pt.name
),
total_revenue AS (
    SELECT SUM(od.quantity * p.price) AS Total_Revenue
    FROM order_details od
    JOIN pizzas p ON od.pizza_id = p.pizza_id
)
SELECT Pizza_Type, ROUND((Revenue / (SELECT Total_Revenue FROM total_revenue)) * 100, 2) AS Revenue_Contribution_Percentage
FROM pizza_revenue
ORDER BY Revenue DESC;

-- 16. Calculate Day-Wise Revenue.
SELECT DAYNAME(order_date) AS Order_Day, COUNT(order_id) AS Order_Count
FROM orders
GROUP BY Order_Day;

-- 17. Analyze the cumulative revenue generated over time (month).
SELECT MONTH(order_date) AS Month, 
       MONTHNAME(order_date) AS Month_Name,
       SUM(ROUND(od.quantity * p.price)) OVER (ORDER BY MONTH(order_date)) AS Cumulative_Revenue
FROM orders o 
JOIN order_details od ON o.order_id = od.order_id
JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY MONTH(order_date), MONTHNAME(order_date);

-- 18. Determine the top 3 most ordered pizza types based on revenue for each pizza category.
WITH pizza_revenue AS (
    SELECT pt.category AS Category, 
           pt.name AS Pizza_Type, 
           ROUND(SUM(od.quantity * p.price), 2) AS Revenue, 
           DENSE_RANK() OVER (PARTITION BY pt.category ORDER BY SUM(od.quantity * p.price) DESC) AS Rank
    FROM order_details od 
    JOIN pizzas p ON od.pizza_id = p.pizza_id
    JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY pt.category, pt.name
)
SELECT Category, Pizza_Type, Revenue
FROM pizza_revenue
WHERE Rank <= 3;
