CREATE DATABASE Ecommerce;
USE Ecommerce;

DESC customers;
DESC orderdetails;
DESC orders;
DESC products;

-- Market Segmentation Analysis 
SELECT 
	location,
    COUNT(customer_id) AS number_of_customers
FROM customers
GROUP BY location
ORDER BY 2 DESC
LIMIT 3;

-- Enagement Depth Analysis
SELECT 
	NumberOfOrders,
    COUNT(*) AS CustomerCount
FROM (
    SELECT
	   customer_id,
       COUNT(*) AS NumberOfOrders
	FROM 
       orders
	GROUP BY
       customer_id
) AS customerCounts
GROUP BY NumberOfOrders
ORDER BY NumberOfOrders ASC;

-- Purchase High-Value Products
SELECT
	product_id,
    AVG(quantity) AS AvgQuantity,
    SUM(quantity * price_per_unit) AS TotalRevenue
FROM OrderDetails
GROUP BY product_id
HAVING AVG(quantity) = 2
ORDER BY 2,3 DESC;

-- Category-wise Customer Reach
SELECT
   category,
   COUNT(DISTINCT customer_id) AS unique_customers
FROM products p 
JOIN orderdetails od ON p.product_id = od.product_id
JOIN orders o ON od.order_id = o.order_id
GROUP BY category
ORDER BY 2 DESC;

-- Sales Trend Analysis
SELECT 
	DATE_FORMAT(order_date, '%Y-%m') AS Month,
    SUM(total_amount) AS TotalSales,
    ROUND(
       (SUM(total_amount) - LAG(SUM(total_amount)) OVER (ORDER BY DATE_FORMAT(order_date, '%Y-%m')))
       / NULLIF(LAG(SUM(total_amount)) OVER (ORDER BY DATE_FORMAT(order_date, '%Y-%m')), 0)
       * 100,
       2
       ) AS PercentChange
FROM orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY Month;

-- Average Order Value Flucation
WITH Monthly AS (
SELECT
	DATE_FORMAT(order_Date, '%Y-%m') AS Month,
    ROUND(AVG(total_amount), 2) AS AvgOrderValue
FROM orders
GROUP BY DATE_FORMAT(order_Date, '%Y-%m')
)
SELECT 
   Month,
   AvgOrderValue,
   ROUND(AvgOrderValue - LAG(AvgOrderValue) OVER (ORDER BY Month), 2) AS ChangeInValue
FROM Monthly
ORDER BY ChangeInValue DESC;
  
-- Inventory Refresh Rate
SELECT
   product_id,
   COUNT(*) AS SalesFrequency
FROM OrderDetails
GROUP BY product_id
ORDER BY SalesFrequency DESC
LIMIT 5;

-- Low Enagement Products
SELECT
       p.product_id,
       p.name,
       COUNT(DISTINCT o.customer_id) AS UniqueCustomerCount
FROM OrderDetails od 
JOIN Orders o ON od.Order_id = o.Order_id
JOIN Products p ON od.Product_id = p.Product_id
GROUP BY p.Product_id, p.name
HAVING COUNT(DISTINCT o.customer_id) < (
       SELECT COUNT(DISTINCT customer_id) * 0.4 FROM Customers
)
ORDER BY UniqueCustomerCount;

-- Customer Acquisition Trends
WITH FirstOrder AS (
     SELECT
         customer_id,
         MIN(order_date) AS FirstOrderDate
	FROM orders
    GROUP BY customer_id
)
SELECT
    DATE_FORMAT(FirstOrderDate, '%Y-%m') AS FirstPurchaseMonth,
    COUNT(*) AS TotalNewCustomers
FROM FirstOrder
GROUP BY FirstPurchaseMonth
ORDER BY FirstPurchaseMonth;

-- Peak sales period identification
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS Month,
    SUM(total_amount) AS TotalSales
FROM Orders
GROUP BY Month 
ORDER BY 2 DESC 
LIMIT 3;

