SELECT TOP 10 * FROM CleanedData;
SELECT COUNT(*) FROM CleanedData;
SELECT DISTINCT payment_method FROM CleanedData;

SELECT payment_method, COUNT(*) FROM CleanedData GROUP BY payment_method;
SELECT COUNT(DISTINCT Branch) FROM CleanedData;
SELECT Branch, COUNT(*) FROM CleanedData GROUP BY Branch;
SELECT MAX(quantity), MIN(quantity) FROM CleanedData;
-- Find diffrent payement methods and number of transaction and nb of quantity sold
SELECT payment_method, COUNT(invoice_id) as number_transaction, SUM(quantity) as quantity_sold FROM CleanedData GROUP BY payment_method;

-- Identify highest rated category in each branch display branch,category and avg rating

SELECT Branch, category, AVG(rating) as avg_rating FROM CleanedData GROUP BY Branch, category ORDER BY Branch, avg(rating);
SELECT *
FROM (
    SELECT Branch, category, AVG(rating) AS avg_rating,
           RANK() OVER (PARTITION BY Branch ORDER BY AVG(rating) DESC) AS rank
    FROM CleanedData
    GROUP BY Branch, category
) AS sub
WHERE rank = 1;

-- Identify busiest day for each branch based on the number of transactions
SELECT branch, day_name, no_transactions
FROM (
    SELECT 
        branch, -- DATENAME extracts a textual name of a part of a date.
        DATENAME(WEEKDAY, CAST(date AS DATE)) AS day_name, --This converts the column called date into a DATE data type.
        COUNT(*) AS no_transactions,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
    FROM CleanedData
    GROUP BY branch, DATENAME(WEEKDAY, CAST(date AS DATE))
) AS ranked
WHERE rank = 1;

SELECT branch, txn_date, no_transactions
FROM (
    SELECT 
        branch,
        CAST(date AS DATE) AS txn_date,           -- exact calendar day
        COUNT(*) AS no_transactions,
        RANK() OVER(
            PARTITION BY branch, YEAR(CAST(date AS DATE)), MONTH(CAST(date AS DATE))
            ORDER BY COUNT(*) DESC
        ) AS rank
    FROM CleanedData
    GROUP BY branch, CAST(date AS DATE)
) AS ranked
WHERE rank = 1;

