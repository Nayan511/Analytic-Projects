CREATE DATABASE airbnb;
USE airbnb;

DESC countries;
DESC sessions_data;
DESC users;

SELECT * FROM countries;
SELECT * FROM sessions_data;
SELECT * FROM users;

-- Most active users
SELECT
    user_id
FROM sessions_data
WHERE user_id IN (
     SELECT user_id
     FROM sessions_data
     WHERE secs_elapsed > 10000
)
GROUP BY user_id
ORDER BY COUNT(user_id) DESC
LIMIT 5;

-- Common country
SELECT 
    country_destination,
    COUNT(*)
FROM users
WHERE country_destination != 'NDF'
GROUP BY country_destination
ORDER BY COUNT(*) DESC;
 
-- Gender Categories
SELECT 
    Gender,
    Signup_Method,
    COUNT(*)
FROM users
WHERE countr_destination != 'NDF' AND date_first_booking IS NOT NULL
GROUP BY gender, signup_method;

-- Frequently Signup method
SELECT 
    gender,
    signup_method,
    COUNT(*)
FROM users
WHERE country_destination != 'NDF'
GROUP BY gender, signup_method
ORDER BY COUNT(*) DESC;

-- Average Age
SELECT 
    country_destination,
    AVG(age) AS average_age
FROM users
WHERE country_destination != 'NDF'
GROUP BY country_destination
ORDER BY average_age ASC;

-- Age Anomalies
SELECT COUNT(*) FROM users
WHERE age > 100;

-- Number of sessions
SELECT
    u.id,
    COUNT(s.user_id) AS session_count
FROM users u 
JOIN sessions_data s ON u.id = s.user_id
WHERE country_destination = 'US'
GROUP BY u.id
HAVING COUNT(s.user_id) < 5
ORDER BY session_count DESC;

-- Organic Clicks
SELECT
    COUNT(s.action) AS total_clicks
FROM users u
JOIN sessions_data S ON u.id = s.id
WHERE u.affiliate_provider = 'direct' AND s.action_type = 'click';

-- Top common actions
SELECT 
	s.action AS action,
    s.device_type,
    COUNT(*) AS action_count
FROM sessions_data s
JOIN users u ON s.user_id = u.id
WHERE u.country_destination != 'NDF'
GROUP BY s.action, s.device_type
ORDER BY COUNT(*) DESC
LIMIT 5;

-- Average time spent
SELECT 
    s.action_type,
    s.device_type,
    AVG(s.secs_elapsed) AS average_time_spent
FROM sessions_data s
JOIN users u ON s.user_id = u.id
WHERE u.country_destination != 'NDF'
GROUP BY s.action_type, s.device_type
ORDER BY average_time_spent DESC;

-- Frequent Combination
SELECT 
    sd1.action AS action1,
    sd2.action AS action2,
    COUNT(*) AS action_pair_count,
    SUM(sd1.secs_elapsed + sd2.secs_elapsed) AS total_time_spent
FROM users u
JOIN sessions_data sd1 
    ON u.id = sd1.user_id
JOIN sessions_data sd2 
    ON u.id = sd2.user_id
   AND sd1.session_id < sd2.session_id
WHERE u.country_destination <> 'NDF'
  AND sd1.device_type = 'Windows Desktop'
  AND sd2.device_type = 'Windows Desktop'
GROUP BY sd1.action, sd2.action
ORDER BY action_pair_count DESC, total_time_spent DESC
LIMIT 10;

-- Number of Bookings 
SELECT 
   first_affiliate_tracked AS affiliate_channel,
   COUNT(*) AS total_users,
   SUM(CASE WHEN country_destination != 'NDF' THEN 1 ELSE 0 END) AS bookings,
   ROUND(SUM(CASE WHEN country_destination != 'NDF' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 4) AS conversion_rate
FROM Users 
GROUP BY first_affiliate_tracked
ORDER BY conversion_rate DESC;

-- Conversion_rate
SELECT 
    affiliate_provider,
    signup_method,
    COUNT(*) AS total_users,
    SUM(CASE WHEN country_destination <> 'NDF' THEN 1 ELSE 0 END) AS bookings,
    ROUND(
        (SUM(CASE WHEN country_destination <> 'NDF' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 
        4
    ) AS conversion_rate
FROM 
    users
GROUP BY 
    affiliate_provider, signup_method
ORDER BY 
    conversion_rate DESC;

-- Affiliate_channels
SELECT 
    affiliate_channel,
    COUNT(*) AS total_users,
    SUM(CASE WHEN country_destination <> 'NDF' THEN 1 ELSE 0 END) AS bookings,
    ROUND(
        (SUM(CASE WHEN country_destination <> 'NDF' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 
        4
    ) AS conversion_rate
FROM 
    users
GROUP BY 
    affiliate_channel
ORDER BY 
    conversion_rate DESC;
