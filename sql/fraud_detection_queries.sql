CREATE TABLE transactions (
    transaction_id BIGINT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    amount NUMERIC(12,2) NOT NULL CHECK (amount > 0),
    transaction_time TIMESTAMP NOT NULL,
    merchant_category VARCHAR(100) NOT NULL,
    location VARCHAR(100) NOT NULL,
    device_type VARCHAR(50) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    failed_attempts INT DEFAULT 0 CHECK (failed_attempts >= 0),
    is_fraud BOOLEAN NOT NULL
);

-- Check total records
SELECT COUNT(*) FROM transactions;

-- Check sample data
SELECT * FROM transactions
LIMIT 10;

-- Check for NULL values
SELECT *
FROM transactions
WHERE amount IS NULL;

-- Check duplicates
SELECT transaction_id, COUNT(*)
FROM transactions
GROUP BY transaction_id
HAVING COUNT(*) > 1;

-- Check invalid amounts
SELECT *
FROM transactions
WHERE amount <= 0;

-- 1. Show all fraud transactions
SELECT *
FROM transactions
WHERE is_fraud = TRUE;

-- 2. Show transactions above 50000
SELECT *
FROM transactions
WHERE amount > 50000;

-- 3. Show all transactions from Mumbai
SELECT *
FROM transactions
WHERE location = 'Mumbai';

-- 4. Top 5 highest transactions
SELECT *
FROM transactions
ORDER BY amount DESC
LIMIT 5;

-- 5. Count fraud records
SELECT *
FROM transactions
WHERE is_fraud = TRUE;

-- 6. High-value transactions
SELECT *
FROM transactions
WHERE amount > 50000;

-- 7. Fraud in Mumbai
SELECT *
FROM transactions
WHERE location = 'Mumbai'
AND is_fraud = TRUE;

-- 8. Top 3 highest transactions
SELECT *
FROM transactions
ORDER BY amount DESC
LIMIT 3;

-- 9. Total fraud count
SELECT COUNT(*)
FROM transactions
WHERE is_fraud = TRUE;

-- 10. Total fraud amount
SELECT SUM(amount)
FROM transactions
WHERE is_fraud = TRUE;

-- 11. Fraud by city
SELECT location, COUNT(*)
FROM transactions
WHERE is_fraud = TRUE
GROUP BY location;

-- 12. Fraud by payment method
SELECT payment_method, COUNT(*)
FROM transactions
WHERE is_fraud = TRUE
GROUP BY payment_method;

-- 13. Average fraud amount
SELECT AVG(amount)
FROM transactions
WHERE is_fraud = TRUE;

-- 14. Cities with repeated fraud
SELECT location, COUNT(*)
FROM transactions
WHERE is_fraud = TRUE
GROUP BY location
HAVING COUNT(*) >= 2;

-- 15. Classify amount risk
SELECT transaction_id,
       amount,
       CASE
           WHEN amount > 50000 THEN 'High Risk'
           ELSE 'Low Risk'
       END AS risk_level
FROM transactions;

-- 16. Classify failed attempts
SELECT transaction_id,
       failed_attempts,
       CASE
           WHEN failed_attempts >= 4 THEN 'Suspicious'
           ELSE 'Normal'
       END AS attempt_status
FROM transactions;

-- 17. Find all night-time frauds
SELECT *
FROM transactions
WHERE is_fraud = TRUE
AND EXTRACT(HOUR FROM transaction_time) BETWEEN 0 AND 4;

-- 18. Fraud count by hour
SELECT EXTRACT(HOUR FROM transaction_time) AS hour,
       COUNT(*)
FROM transactions
WHERE is_fraud = TRUE
GROUP BY hour
ORDER BY hour;

-- 19. Unique cities
SELECT DISTINCT location
FROM transactions;

-- 20. Transactions from Mumbai and Pune
SELECT *
FROM transactions
WHERE location IN ('Mumbai', 'Pune');

-- 21. Transactions above average
SELECT *
FROM transactions
WHERE amount > (
    SELECT AVG(amount)
    FROM transactions
);

-- 22. High-value frauds
SELECT *
FROM transactions
WHERE is_fraud = TRUE
AND amount > (
    SELECT AVG(amount)
    FROM transactions
    WHERE is_fraud = TRUE
);

-- 23. Fraud count by city using CTE
WITH fraud_transactions AS (
    SELECT *
    FROM transactions
    WHERE is_fraud = TRUE
)
SELECT location, COUNT(*)
FROM fraud_transactions
GROUP BY location;

-- 24. Rank all transactions
SELECT transaction_id,
       amount,
       ROW_NUMBER() OVER (ORDER BY amount DESC) AS row_num
FROM transactions;

-- 25. Rank fraud transactions only
SELECT transaction_id,
       amount,
       RANK() OVER (ORDER BY amount DESC) AS fraud_rank
FROM transactions
WHERE is_fraud = TRUE;

-- 26. Rank transactions within each city
SELECT transaction_id,
       location,
       amount,
       RANK() OVER (
           PARTITION BY location
           ORDER BY amount DESC
       ) AS city_rank
FROM transactions;

SELECT COUNT(*) FROM transactions;

-- 27. Overall Fraud KPIs
SELECT 
    COUNT(*) AS total_transactions,
    COUNT(CASE WHEN is_fraud = TRUE THEN 1 END) AS fraud_transactions,
    SUM(CASE WHEN is_fraud = TRUE THEN amount ELSE 0 END) AS total_fraud_amount,
    AVG(CASE WHEN is_fraud = TRUE THEN amount END) AS avg_fraud_amount
FROM transactions;

-- 28. Fraud by City
SELECT location,
	   COUNT(*) AS fraud_count,
	   SUM(amount) AS fraud_amount
FROM transactions
WHERE is_fraud = TRUE
GROUP BY location
ORDER BY fraud_count DESC;

-- 29. Fraud by Payment Method
SELECT payment_method, 
	   COUNT(*) AS fraud_count,
	   SUM(amount) AS fraud_amount
FROM transactions
WHERE is_fraud = TRUE
GROUP BY payment_method
ORDER BY fraud_count DESC;

-- 30. Fraud by Merchant Category
SELECT merchant_category,
	   COUNT(*) AS fraud_count,
	   SUM(amount) AS fraud_amount
FROM transactions
WHERE is_fraud = TRUE
GROUP BY merchant_category
ORDER BY fraud_count DESC;

--  31. Fraud by Hour
SELECT 
	EXTRACT(HOUR FROM transaction_time) AS fraud_hour,
	COUNT(*) AS fraud_count
FROM transactions
WHERE is_fraud = TRUE
GROUP BY fraud_hour
ORDER BY fraud_count DESC;

-- RISK SCORING MODEL

-- 1. Count transactions by risk level
SELECT 
	CASE
		WHEN amount > 50000 
			AND failed_attempts >= 3
			AND EXTRACT(HOUR FROM transaction_time) BETWEEN 0 AND 4
		THEN 'High Risk'

		WHEN amount > 30000
			AND failed_attempts >= 2
		THEN 'Medium Risk'

		ELSE 'Low Risk'
	END AS risk_level,
	COUNT(*) AS total_transactions
FROM transactions
GROUP BY risk_level
ORDER BY total_transactions DESC;

-- 2. Total amount by risk level
SELECT 
	CASE 
		WHEN amount > 50000 
			AND failed_attempts >= 3
			AND EXTRACT(HOUR FROM transaction_time) BETWEEN 0 AND 4
		THEN 'High Risk'

		WHEN amount > 30000
			AND failed_attempts >= 2
		THEN 'Medium Risk'

		ELSE 'Low Risk'
	END AS risk_level,
	SUM(amount) AS total_amount
FROM transactions
GROUP BY risk_level;

-- 3. High-risk cities
SELECT 
	location, 
	COUNT(*) AS high_risk_count
FROM transactions
WHERE amount > 50000
	AND failed_attempts >= 3
	AND EXTRACT(HOUR FROM transaction_time) BETWEEN 0 AND 4
GROUP BY location
ORDER BY high_risk_count DESC;

