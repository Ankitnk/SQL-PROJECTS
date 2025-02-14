# CREATE DATABASE salesdb;
# USE salesdb;

# Data Cleaning :-

# Q1. Establish the relationship between the tables as per the ER diagram.
ALTER TABLE OrdersList  
ADD CONSTRAINT pk_orderid PRIMARY KEY (OrderID);

ALTER TABLE OrdersList  
MODIFY COLUMN OrderID VARCHAR(255) NOT NULL;

ALTER TABLE EachOrderBreakdown  
MODIFY COLUMN OrderID VARCHAR(255) NOT NULL;

ALTER TABLE EachOrderBreakdown  
ADD CONSTRAINT fk_orderid  
FOREIGN KEY (OrderID) REFERENCES OrdersList(OrderID);

# Q2. Split City State Country into 3 individual columns namely ‘City’, ‘State’, ‘Country’.

ALTER TABLE OrdersList  
ADD COLUMN City VARCHAR(255),  
ADD COLUMN State VARCHAR(255),  
ADD COLUMN Country VARCHAR(255);

SET SQL_SAFE_UPDATES = 0;

UPDATE OrdersList
SET 
    City = SUBSTRING_INDEX(`City State Country`, ',', 1),
    State = SUBSTRING_INDEX(SUBSTRING_INDEX(`City State Country`, ',', -2), ',', 1),
    Country = SUBSTRING_INDEX(`City State Country`, ',', -1);

SET SQL_SAFE_UPDATES = 1; -- Safe mode wapas enable karne ke liye

ALTER TABLE OrdersList  
DROP COLUMN `City State Country`;

# Q3. Add a new Category Column using the following mapping as per the first 3 characters in the Product Name Column:
# TEC- Technology
# OFS – Office Supplies
# FUR - Furniture 

ALTER TABLE EachOrderBreakdown  
ADD COLUMN Category VARCHAR(255);


SET SQL_SAFE_UPDATES = 0;
UPDATE EachOrderBreakdown
SET Category = CASE 
    WHEN LEFT(ProductName,3) = 'OFS' THEN 'Office Supplies'
    WHEN LEFT(ProductName,3) = 'TEC' THEN 'Technology'
    WHEN LEFT(ProductName,3) = 'FUR' THEN 'Furniture'
    ELSE 'Other'
END;
SET SQL_SAFE_UPDATES = 1;


# Q4. Delete the first 4 characters from the ProductName Column.

SET SQL_SAFE_UPDATES = 0;

UPDATE EachOrderBreakdown  
SET ProductName = SUBSTRING(ProductName, 5);

SET SQL_SAFE_UPDATES = 1;  -- Safe mode wapas enable karne ke liye
# Q5. Remove duplicate rows from EachOrderBreakdown table, if all column values are matching.

WITH CTE AS (
    SELECT *, 
           ROW_NUMBER() OVER(PARTITION BY OrderID, ProductName, Discount, Sales, Profit, Quantity, 
                                     Category, SubCategory 
                            ORDER BY OrderID) AS rn
    FROM EachOrderBreakdown
)
DELETE FROM EachOrderBreakdown 
WHERE OrderID IN (SELECT OrderID FROM CTE WHERE rn > 1);


# Q6. Replace blank with NA in OrderPriority Column in OrdersList table.

SET SQL_SAFE_UPDATES = 0;

UPDATE OrdersList
SET OrderPriority = 'NA'
WHERE OrderPriority = '' OR OrderPriority IS NULL;

SET SQL_SAFE_UPDATES = 1;



# DATA EXPLORATION :-



# BIGINNER LEVEL :

# 1.List the top 10 orders with the highest sales from the EachOrderBreakdown table.

SELECT * 
FROM EachOrderBreakdown 
ORDER BY Sales DESC 
LIMIT 10;

# 2.Show the number of orders for each product category in the EachOrderBreakdown table.

SELECT Category, COUNT(*) AS NumberOfOrders  
FROM EachOrderBreakdown  
GROUP BY Category;  

# 3.Find the total profit for each sub-category in the EachOrderBreakdown table.

SELECT SubCategory, 
       SUM(CAST(REPLACE(REPLACE(Profit, '$', ''), ',', '') AS DECIMAL(10,2))) AS TotalProfit
FROM EachOrderBreakdown
GROUP BY SubCategory
ORDER BY TotalProfit DESC;

# Intermediate

# 1.Identify the customer with the highest total sales across all orders.


SELECT DISTINCT CustomerName,SUM(Sales) AS TotalSales
FROM OrdersList AS ol  
JOIN EachOrderBreakdown AS ob  
ON ol.OrderID = ob.OrderID
GROUP By CustomerName
ORDER BY TotalSales DESC
LIMIT 1;

# 2.Find the month with the highest average sales in the OrdersList table.


SELECT MONTH(OrderDate) AS Month, AVG(Sales) AS AverageSales  
FROM OrdersList ol  
JOIN EachOrderBreakdown ob  
ON ol.OrderID = ob.OrderID  
GROUP BY MONTH(OrderDate)  
ORDER BY AverageSales DESC  
LIMIT 1; 

# 3.Find out the average quantity ordered by customers whose first name starts with an alphabet 's'?


SELECT AVG(Quantity) AS AverageQuantity  
FROM OrdersList ol  
JOIN EachOrderBreakdown ob  
ON ol.OrderID = ob.OrderID  
WHERE LEFT(CustomerName, 1) = 'S';

# Advanced

# 1.Find out how many new customers were acquired in the year 2014?


SELECT COUNT(*) AS NumberOfNewCustomers  
FROM (  
    SELECT CustomerName, MIN(OrderDate) AS FirstOrderDate  
    FROM OrdersList  
    GROUP BY CustomerName  
    HAVING YEAR(MIN(OrderDate)) = 2014  
) AS CustWithFirstOrder2014;

# 2.Calculate the percentage of total profit contributed by each sub-category to the overall profit.


SELECT SubCategory,  
       SUM(Profit) AS SubCategoryProfit,  
       (SUM(Profit) / (SELECT SUM(Profit) FROM EachOrderBreakdown)) * 100 AS PercentageOfTotalContribution  
FROM EachOrderBreakdown  
GROUP BY SubCategory;

# 3.Find the average sales per customer, considering only customers who have made more than one order. 


WITH CustomerAvgSales AS (  
    SELECT CustomerName, COUNT(DISTINCT ol.OrderID) AS NumberOfOrders, AVG(Sales) AS AvgSales  
    FROM OrdersList ol  
    JOIN EachOrderBreakdown ob  
    ON ol.OrderID = ob.OrderID  
    GROUP BY CustomerName  
)  
SELECT CustomerName, AvgSales  
FROM CustomerAvgSales  
WHERE NumberOfOrders > 12;

# 4.Identify the top-performing subcategory in each category based on total sales. Include the sub-category name, total sales, and a ranking of sub-category within each category.


WITH topsubcategory AS (  
    SELECT Category, SubCategory, SUM(Sales) AS TotalSales,  
           RANK() OVER(PARTITION BY Category ORDER BY SUM(Sales) DESC) AS SubcategoryRank  
    FROM EachOrderBreakdown  
    GROUP BY Category, SubCategory  
)  
SELECT Category, SubCategory, TotalSales  
FROM topsubcategory  
WHERE SubcategoryRank = 1;



