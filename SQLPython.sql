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

-- identify the busiest day in the month 
SELECT branch, txn_date, no_transactions
FROM (
    SELECT 
        branch,
        CAST(date AS DATE) AS txn_date,           -- exact calendar day
        COUNT(*) AS no_transactions,
        RANK() OVER(
            PARTITION BY branch, YEAR(CAST(date AS DATE)), MONTH(CAST(date AS DATE)) -- Creates a separate ranking for each branch and for each month.
            ORDER BY COUNT(*) DESC
        ) AS rank
    FROM CleanedData
    GROUP BY branch, CAST(date AS DATE)
) AS ranked
WHERE rank = 1;


--Calculate the total quantity of items sold per payment method
SELECT payment_method, SUM(quantity) as quantity_sold FROM CleanedData GROUP BY payment_method;

-- Determine the average, minimum, and maximum rating of categories for each city
SELECT category, City, AVG(rating) as avg_rating, MAX(rating) as max_rating, MIN(rating)as min_rating FROM CleanedData GROUP BY category,City;
 
 --Calculate the total profit for each category
 SELECT category, SUM(unit_price*quantity*profit_margin) as total_profit FROM CleanedData GROUP BY category ORDER BY total_profit DESC;

 --  Determine the most common payment method
 SELECT TOP 1 payment_method, count(invoice_id) as nb_transaction FROM CleanedData GROUP BY payment_method  ORDER BY nb_transaction DESC;

 -- Determine the most common payment method for each branch
 WITH cte as (
SELECT branch , payment_method, COUNT(invoice_id) as nb_transaction , rank() over(partition by branch ORDER BY COUNT(invoice_id) DESC  ) as rank
FROM CleanedData GROUP BY Branch, payment_method ) 
SELECT branch, payment_method AS preferred_payment_method
FROM cte
WHERE rank = 1;

-- Categorize sales into Morning, Afternoon, and Evening shifts

SELECT
    branch,
    CASE 
        WHEN DATEPART(HOUR, time) < 12 THEN 'Morning'
        WHEN DATEPART(HOUR, time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
    COUNT(*) AS num_invoices
FROM CleanedData
GROUP BY branch,
         CASE 
             WHEN DATEPART(HOUR, time) < 12 THEN 'Morning'
             WHEN DATEPART(HOUR, time) BETWEEN 12 AND 17 THEN 'Afternoon'
             ELSE 'Evening'
         END
ORDER BY branch, num_invoices DESC;

-- Identify the 5 branches with the highest revenue decrease ratio from last year to current year (e.g., 2022 to 2023)

WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM CleanedData
    WHERE YEAR(CAST(date AS DATE)) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM CleanedData
    WHERE YEAR(CAST(date AS DATE)) = 2023
    GROUP BY branch
)
SELECT TOP 5
    r2022.branch,
    r2022.revenue AS last_year_revenue,
    r2023.revenue AS current_year_revenue,
    ROUND(((r2022.revenue - r2023.revenue) * 100.0 / r2022.revenue), 2) AS revenue_decrease_ratio
FROM revenue_2022 AS r2022
JOIN revenue_2023 AS r2023 ON r2022.branch = r2023.branch
WHERE r2022.revenue > r2023.revenue
ORDER BY revenue_decrease_ratio DESC;

