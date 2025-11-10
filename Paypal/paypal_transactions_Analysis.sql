USE Paypal;

SELECT * FROM  countries;
SELECT * FROM  currencies;
SELECT * FROM  merchants;
SELECT * FROM  Transactions;
SELECT * FROM  Users;

-- Top Transactions Sender, Recevier country

SELECT c.country_name AS country,
       ROUND(SUM(t.transaction_amount), 2) AS total_sent
FROM countries c
JOIN users u ON c.country_id = u.country_id
JOIN transactions t ON u.user_id = t.sender_id
WHERE t.transaction_date BETWEEN '2023-10-01' AND '2023-12-31'
GROUP BY c.country_name
ORDER BY total_sent DESC
LIMIT 5;

SELECT c.country_name AS country,
	   ROUND(SUM(t.transaction_amount), 2) AS total_received
FROM countries c
JOIN users u ON c.country_id = u.country_id
JOIN transactions t ON u.user_id = t.recipient_id
WHERE t.transaction_date BETWEEN '2023-10-01' AND '2023-12-31'
GROUP BY c.country_name
ORDER BY total_received DESC
LIMIT 5;

-- High value transactions
SELECT transaction_id,
       sender_id,
       recipient_id,
       transaction_amount,
       currency_code
FROM Transactions
WHERE transaction_amount > 10000
AND EXTRACT(YEAR FROM transaction_date) = 2023;

-- Merchant performance
SELECT 
       m.merchant_id,
       m.business_name,
       SUM(t.transaction_amount) AS total_received,
       AVG(t.transaction_amount) AS average_transaction
FROM Transactions t 
JOIN Merchants m ON t.recipient_id = m.merchant_id
WHERE t.transaction_date BETWEEN '2023-11-01' AND '2024-04-30'
GROUP BY m.merchant_id, m.business_name
ORDER BY total_received DESC
LIMIT 10;

-- Conversion Trend
SELECT t.currency_code,
            SUM(t.transaction_amount) AS total_converted
FROM transactions t
WHERE t.transaction_date BETWEEN '2023-05-22' AND '2024-05-22'
GROUP BY t.currency_code
ORDER BY total_converted DESC
LIMIT 3;

-- Transactions Classification
SELECT 
        CASE 
            WHEN transaction_amount > 10000 THEN 'High Value'
            ELSE 'Regular'
            END AS transaction_category,
        SUM(transaction_amount) AS total_amount
FROM transactions
WHERE YEAR(transaction_date) = 2023
GROUP BY transaction_category;

-- Nature of Transactions
SELECT
        CASE
            WHEN u1.country_id != u2.country_id THEN 'International'
            ELSE 'Domestic'
        END AS transaction_type,
        COUNT(*) AS transaction_count
FROM transactions t 
JOIN Users u1 ON t.sender_id = u1.user_id
JOIN Users u2 ON t.recipient_id = u2.user_id
WHERE t.transaction_date BETWEEN '2024-01-01' AND '2024-04-01'
GROUP BY transaction_type;


-- Transaction Behavior
SELECT  
        u.user_id,
        u.email,
        ROUND(AVG(t.transaction_amount), 2) AS avg_amount
FROM Users u 
JOIN Transactions t ON u.user_id = t.sender_id
WHERE t.transaction_date BETWEEN '2023-11-01' AND '2024-05-01'
GROUP BY u.user_id, u.email
HAVING AVG(t.transaction_amount) > 5000
ORDER BY u.user_id ASC;

-- Monthly Transaction
SELECT
       YEAR(transaction_date) AS transaction_year,
       MONTH(transaction_date) AS transaction_month,
       SUM(transaction_amount) AS total_amount
FROM Transactions 
WHERE transaction_date >= '2023-01-01' AND transaction_date < '2024-01-01'
GROUP BY transaction_year, transaction_month
ORDER BY transaction_year ASC, transaction_month ASC;

-- Loyal Customer
SELECT 
       u.user_id,
       u.email,
       u.name,
       ROUND(SUM(t.transaction_amount), 2) AS total_amount
FROM Users u 
JOIN Transactions t ON u.user_id = t.sender_id
WHERE transaction_date BETWEEN '2023-05-22' AND '2024-05-22'
GROUP BY u.user_id, u.email, u.name
ORDER BY total_amount DESC
LIMIT 1;

--
SELECT c.currency_code, SUM(t.transaction_amount) AS total_transactions
FROM currencies c
JOIN transactions t ON c.currency_code = t.currency_code
WHERE t.transaction_date BETWEEN '2023-05-22' AND '2024-05-22'
GROUP BY c.currency_code;


-- Count Transaction based on category
SELECT 
	CASE 
      WHEN t.transaction_amount > 10000 AND u1.country_id != u2.country_id THEN 'High Value International'
      WHEN t.transaction_amount > 10000 AND u1.country_id = u2.country_id THEN 'High Value Domestic'
      WHEN t.transaction_amount <= 10000 AND u1.country_id != u2.country_id THEN 'Regular International'
      WHEN t.transaction_amount <= 10000 AND u1.country_id = u2.country_id THEN 'Regular Domestic'
	END AS transaction_category,
    COUNT(*) AS transaction_count
FROM transactions t
JOIN Users u1 ON t.sender_id = u1.user_id
JOIN Users u2 ON t.recipient_id = u2.user_id
WHERE transaction_date BETWEEN  '2023-01-01' AND '2023-12-31'
GROUP BY transaction_category;

-- Group wise Transactions
SELECT 
        EXTRACT(YEAR FROM t.transaction_date)  AS transaction_year,
        EXTRACT(MONTH FROM t.transaction_date) AS transaction_month,
        CASE 
               WHEN t.transaction_amount > 10000 THEN 'High Value'
               ELSE 'Regular'
        END AS value_category,
        CASE 
               WHEN u1.country_id <> u2.country_id THEN 'International'
               ELSE 'Domestic'
        END AS location_category,
        ROUND(SUM(t.transaction_amount), 2) AS total_amount,
        ROUND(AVG(t.transaction_amount), 2) AS average_amount
FROM Transactions t 
JOIN Users u1 ON t.sender_id = u1.user_id
JOIN Users u2 ON t.recipient_id = u2.user_id
WHERE 
        t.transaction_date >= '2023-01-01' AND t.transaction_date < '2024-01-01'
GROUP BY 
        transaction_year,
        transaction_month,
        value_category,
        location_category
ORDER BY 
        transaction_year,
        transaction_month,
        value_category,
        location_category;
        
-- Average amount
SELECT 
        m.merchant_id,
        m.business_name,
        ROUND(SUM(t1.transaction_amount), 2) AS total_received,
        CASE 
              WHEN SUM(t1.transaction_amount) > 50000 THEN 'Excellent'
              WHEN SUM(t1.transaction_amount) > 20000 AND SUM(t1.transaction_amount) <= 50000 THEN 'Good'
              WHEN SUM(t1.transaction_amount) > 10000 AND SUM(t1.transaction_amount) <= 20000 THEN 'Average'
              ELSE 'Below Average'
        END AS performance_score,
        ROUND(AVG(t1.transaction_amount), 2) AS average_transaction
FROM Merchants m 
JOIN Transactions t1 ON m.merchant_id = t1.recipient_id
WHERE
    t1.transaction_date >= '2023-11-01'
    AND t1.transaction_date < '2024-05-01'
GROUP BY m.merchant_id, m.business_name
ORDER BY CASE 
              WHEN SUM(t1.transaction_amount) > 50000 THEN 1
              WHEN SUM(t1.transaction_amount) > 20000 AND SUM(t1.transaction_amount) <= 50000 THEN 2
              WHEN SUM(t1.transaction_amount) > 10000 AND SUM(t1.transaction_amount) <= 20000 THEN 3
              ELSE 4
        END,
        total_received DESC;
        
-- Customer engagement
WITH monthly_active AS (
      SELECT
            u.user_id,
            EXTRACT(MONTH FROM t.transaction_date) AS active_month
      FROM Users u 
      JOIN Transactions t ON u.user_id = t.sender_id
      WHERE
        t.transaction_date >= '2023-05-01'
        AND t.transaction_date < '2024-05-01'
        GROUP BY u.user_id,
        EXTRACT(MONTH FROM t.transaction_date)
),
active_user_count AS (
      SELECT 
           ma.user_id,
           COUNT(DISTINCT active_month) AS active_months
      FROM monthly_active ma
      GROUP BY ma.user_id
)
SELECT 
      u.user_id,
      u.email
FROM active_user_count a 
JOIN Users u ON a.user_id = u.user_id
WHERE
    a.active_months >= 6
ORDER BY
    u.user_id ASC;

SELECT  
	transaction_id,
    transaction_amount
FROM Transactions 
WHERE transaction_amount > 50000
ORDER BY transaction_id;

-- Monthly Transactions
WITH MonthlyMerchantTransactions AS ( 
    SELECT m.merchant_id, 
                 m.business_name, 
                 year(transaction_date) AS transaction_year, 
                 month(transaction_date) AS transaction_month, 
                 SUM(t.transaction_amount) AS total_transaction_amount 
    FROM Transactions t 
    JOIN Merchants m ON t.recipient_id = m.merchant_id 
    WHERE t.transaction_date >= '2023-11-01' AND t.transaction_date < '2024-05-01' 
    GROUP BY m.merchant_id, 
                    m.business_name, 
                    transaction_year, 
                    transaction_month ) 

SELECT merchant_id, 
             business_name, 
             transaction_year, 
             transaction_month, 
             total_transaction_amount, 
CASE 
    WHEN total_transaction_amount > 50000 THEN 'Exceeded $50,000' 
    ELSE 'Did Not Exceed $50,000' 
END AS performance_status 
FROM MonthlyMerchantTransactions 
ORDER BY merchant_id, 
                 transaction_year,
                transaction_month;
                
-- Higest Transactions
SELECT currency_code, SUM(transaction_amount) AS total_amount
FROM transactions
WHERE transaction_date BETWEEN '2023-05-22' AND '2024-05-22'
GROUP BY currency_code
ORDER BY total_amount DESC
LIMIT 1;

-- Top Performing Merchant
SELECT m.business_name, SUM(t.transaction_amount) AS total_received
FROM transactions t
JOIN merchants m ON t.recipient_id = m.merchant_id
WHERE t.transaction_date BETWEEN '2023-11-01' AND '2024-04-30'
GROUP BY m.business_name
ORDER BY total_received DESC
LIMIT 1;