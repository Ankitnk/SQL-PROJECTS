CREATE DATABASE pizzasales;

use pizzasales;


#  A.	KPI’S

# 1.	Total Revenue:

SELECT SUM(total_price) AS Total_Revenue FROM pizza_sales_excel_file;


# 2.Average order value

select sum(total_price) / count(distinct order_id) as Avg_Order_Value from pizza_sales_excel_file;

# 3.Total pizza sold

select sum(quantity) as Total_pizza_sold from pizza_sales_excel_file;

# 4.Total orders

select count(distinct order_id) AS Total_orders from pizza_sales_excel_file;

# 5.Average Pizzas Per Order

select cast(cast(sum(quantity) as decimal(10,2)) / 
cast(count(distinct order_id) as decimal(10,2)) as decimal(10,2)) as Avg_Pizzas_Per_order from pizza_sales_excel_file;

 
# B.Daily Trend for Total orders

SELECT 
    DAYNAME(STR_TO_DATE(order_date, '%Y-%m-%d')) AS order_day, 
    COUNT(DISTINCT order_id) AS Total_orders
FROM pizza_sales_excel_file
WHERE order_date IS NOT NULL
GROUP BY order_day  
ORDER BY FIELD(order_day, 'Saturday','Wednesday','Monday','Sunday','Friday','Thursday','Tuesday');


# C. Monthly Trend for orders

SELECT 
    MONTHNAME(STR_TO_DATE(order_date, '%d-%m-%Y')) AS Month_Name, 
    COUNT(DISTINCT order_id) AS Total_orders
FROM pizza_sales_excel_file
WHERE order_date IS NOT NULL
GROUP BY MONTH(STR_TO_DATE(order_date, '%d-%m-%Y')), Month_Name  
ORDER BY Total_orders DESC;

# D. % of Sales by Pizza Category

SELECT 
    pizza_category, 
    SUM(total_price) AS Total_Sales, 
    SUM(total_price) * 100 / (SELECT SUM(total_price) FROM pizza_sales_excel_file WHERE MONTH(STR_TO_DATE(order_date, '%d-%m-%Y')) = 1) AS PCT
FROM pizza_sales_excel_file
WHERE MONTH(STR_TO_DATE(order_date, '%d-%m-%Y')) = 1 
GROUP BY pizza_category;

# E. % of Sales by Pizza Size

SELECT 
    pizza_size, 
    CAST(SUM(total_price) AS DECIMAL(10,2)) AS Total_Sales, 
    CAST(SUM(total_price) * 100 / 
         (SELECT SUM(total_price) FROM pizza_sales_excel_file 
          WHERE MONTH(STR_TO_DATE(order_date, '%d-%m-%Y')) = 1) 
    AS DECIMAL(10,2)) AS PCT
FROM pizza_sales_excel_file
WHERE MONTH(STR_TO_DATE(order_date, '%d-%m-%Y')) = 1 
GROUP BY pizza_size
ORDER BY PCT DESC;

# F. Total Pizzas Sold by Pizza Category

SELECT pizza_category, SUM(quantity) AS Total_Quantity_Sold
FROM pizza_sales_excel_file
WHERE MONTH(STR_TO_DATE(order_date, '%d-%m-%Y')) = 2
GROUP BY pizza_category
ORDER BY Total_Quantity_Sold DESC;

# G. Top 5 Pizzas by Revenue
SELECT pizza_name, SUM(total_price) AS Total_Revenue 
FROM pizza_sales_excel_file 
GROUP BY pizza_name 
ORDER BY Total_Revenue DESC 
LIMIT 5;

# H. Bottom 5 Pizzas by Revenue

SELECT pizza_name, SUM(total_price) AS Total_Revenue
FROM pizza_sales_excel_file
GROUP BY pizza_name
ORDER BY Total_Revenue ASC
LIMIT 5;

# I. Top 5 Pizzas by Quantity
SELECT pizza_name, SUM(quantity) AS Total_Quantity
FROM pizza_sales_excel_file
GROUP BY pizza_name
ORDER BY Total_Quantity DESC
LIMIT 5; 

# J. Bottom 5 Pizzas by Quantity
SELECT pizza_name, count(distinct order_id) as  Total_Orders
FROM pizza_sales_excel_file
GROUP BY pizza_name
ORDER BY Total_Orders ASC
LIMIT 5;

# K. Top 5 Pizzas by Total Orders
SELECT pizza_name, COUNT(DISTINCT order_id) AS Total_Orders
FROM pizza_sales_excel_file
GROUP BY pizza_name
ORDER BY Total_Orders DESC
LIMIT 5;

# L. Borrom 5 Pizzas by Total Orders
SELECT pizza_name, COUNT(DISTINCT order_id) AS Total_Orders
FROM pizza_sales_excel_file
GROUP BY pizza_name
ORDER BY Total_Orders ASC
LIMIT 5;








