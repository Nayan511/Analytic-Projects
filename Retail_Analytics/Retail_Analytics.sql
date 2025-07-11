-- Create Database
CREATE DATABASE Retail_Analytic;
USE Retail_Analytic;

-- Import Tables
DESC Customer_profiles;
DESC product_inventory;
DESC sales_transaction;

-- Cleaning
ALTER TABLE Customer_profiles
RENAME COLUMN ï»¿CustomerID TO CustomerID;

ALTER TABLE product_inventory
RENAME COLUMN ï»¿ProductID TO ProductID;

ALTER TABLE sales_transaction
RENAME COLUMN ï»¿TransactionID TO TransactionID;

SELECT * FROM Customer_profiles;
SELECT * FROM product_inventory;
SELECT * FROM sales_transaction;

-- Problem Statement 1 = Removing Duplicate Transactions
SELECT 
	CustomerID,
    ProductID,
    TransactionID,
    TransactionDate,
    COUNT(*) AS duplicate_count
FROM sales_transaction
GROUP BY CustomerID, ProductID, TransactionID, TransactionDate
HAVING COUNT(*) > 1;

CREATE TABLE Sales_Transaction_Unique AS
SELECT
	DISTINCT *
FROM sales_transaction;
    
DROP TABLE sales_transaction;

ALTER TABLE sales_transaction_unique
RENAME TO sales_transaction;

-- Problem Statement 2 = Fix Price Discrepancies
SELECT 
	s.ProductID,
    s.TransactionID,
    s.price AS TransctionPrice,
    p.price AS InventoryPrice
FROM sales_transaction s
JOIN product_inventory p ON s.productID = p.ProductID
WHERE p.price != s.price;

UPDATE sales_transaction AS s
SET Price = (
	SELECT 
		p.price 
	FROM product_inventory AS p 
    WHERE s.productID = p.productID
)
WHERE s.ProductID IN (
	SELECT ProductID FROM product_inventory AS p
    WHERE s.Price != p.Price
);

SET SQL_SAFE_UPDATES = 0;


-- Problem Statement 3 = Handle NUll Values
SELECT 
    COUNT(Location) AS Location
FROM customer_profiles
WHERE Location = "";

-- Update with Unknown 
UPDATE customer_profiles
SET Location = "Unknown"
WHERE Location = "";

ALTER TABLE Sales_transaction
MODIFY COLUMN TransactionDate DATE;

-- Problem Statement 5 = Product Performance overview
SELECT 
    ProductID,
    ROUND(SUM(QuantityPurchased * Price), 0) AS Total_Sales,
    SUM(QuantityPurchased) AS TotalUniteSold
FROM sales_transaction
GROUP BY ProductID
ORDER BY Total_Sales;

-- Problem Statement 6 = Customer Purchase frequency
SELECT
	CustomerID,
    COUNT(TransactionID) AS PurchaseCount
FROM sales_transaction
GROUP BY CustomerID
ORDER BY PurchaseCount DESC;


-- Problem Statement 7 = Product Category Performance
SELECT
    p.Category,
    ROUND(SUM(s.QuantityPurchased * s.Price), 2) AS Revenue,
    SUM(s.QuantityPurchased) AS TotalUnitSold
FROM product_inventory p JOIN sales_transaction s ON p.ProductID = s.ProductID
GROUP BY p.Category
ORDER BY Revenue DESC;


-- Problem Statment 8 = High Sales Products
SELECT 
	ProductID,
    ROUND(SUM(QuantityPurchased * Price), 2) AS TotalRevenue
FROM sales_transaction
GROUP BY ProductID
ORDER BY TotalRevenue
LIMIT 10;


-- Problem Statement 9 = Low Sales Products
SELECT 
    ProductID,
    SUM(QuantityPurchased) AS TotalSold
FROM sales_transaction
GROUP BY ProductID
HAVING TotalSold > 0
ORDER BY TotalSold ASC
LIMIT 10;


-- Problem Statement 10 = Daily Sales Trends
SELECT 
    CAST(TransactionDate AS DATE) AS Sale_date,
    COUNT(*) AS Daily_Transaction,
    SUM(QuantityPurchased) AS Total_UnitSold,
    ROUND(SUM(price * QuantityPurchased), 2) AS Total_sales
FROM sales_transaction
GROUP BY 1
ORDER BY 1 DESC;


-- Problem Statement 11 = Month-on-Month Sales Growth
SELECT * FROM sales_transaction;
WITH Monthly_sales AS (
	SELECT 
		EXTRACT(MONTH FROM TransactionDate) As month,
		ROUND(SUM(QuantityPurchased * Price),0) AS total_sales
     FROM sales_transaction
     GROUP BY EXTRACT(MONTH FROM TransactionDate)
)
SELECT month,
total_sales,
LAG(total_sales) OVER (Order BY Month) AS previous_month_sales,
ROUND(((total_sales - LAG(total_sales) OVER (Order BY Month))/
LAG(total_sales) OVER (Order BY Month)) * 100,2) AS mom_growth_percentage
FROM Monthly_sales
ORDER BY Month;


-- Problem Statement 12 = High Value Customers
SELECT
    CustomerID,
    COUNT(*) AS number_of_transactions,
    ROUND(SUM(QuantityPurchased * Price), 2) AS total_spent
FROM
    sales_transaction
GROUP BY CustomerID
HAVING
    total_spent > 1000 AND number_of_transactions > 10
ORDER BY
    total_spent DESC;
    
-- Problem Statement 13 = Occasional Customers
SELECT
     CustomerID,
     COUNT(*) AS number_of_transactions,
     SUM(QuantityPurchased * Price) AS total_spent
FROM sales_transaction
GROUP BY CustomerID
HAVING number_of_transactions <= 2
ORDER BY number_of_transactions, total_spent DESC;


-- Problem Statement 14 = Repeat Purchase Behavior
SELECT 
    CustomerID,
    ProductID,
    COUNT(*) AS Time_purchased
FROM sales_transaction
GROUP BY CustomerID, ProductID
HAVING Time_purchased > 1
ORDER BY Time_purchased DESC;


-- Problem Statement 15 = Loyalty Indicator
WITH transactionDate AS(
	SELECT
		CustomerID,
        STR_TO_DATE(TransactionDate, '%Y-%m-%d') AS TransactionDate
	FROM sales_transaction
)
SELECT
	CustomerID,
    MIN(TransactionDate) AS FirstPurchase,
    MAX(TransactionDate) AS LastPurchase,
    DATEDIFF(MAX(TransactionDate),MIN(TransactionDate)) AS DaysBetweenPurchases
FROM transactionDate
GROUP BY CustomerID
HAVING DaysBetweenPurchases > 0
ORDER BY DaysBetweenPurchases DESC;


-- Problem Statement 16 = Customer Segmentation by Quantity
CREATE TABLE customer_segment AS 
SELECT	
	CustomerID,
    CASE
		WHEN TotalQty > 30 THEN 'High'
        WHEN TotalQty BETWEEN 11 AND 30 THEN 'Mid'
        WHEN TotalQty BETWEEN 1 AND 10 THEN 'Low'
    END AS CustomerSegment
FROM (
	SELECT
		c.CustomerID,
        SUM(s.QuantityPurchased) AS TotalQty
	FROM customer_profiles c 
    JOIN sales_transaction s 
    ON c.CustomerID = s.CustomerID
    GROUP BY c.CustomerID
) AS customer_total;
  
SELECT 
	CustomerSegment,
    COUNT(*) AS NumberOfPurchased
FROM customer_segment;