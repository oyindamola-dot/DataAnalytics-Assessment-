USE adashi_staging;

-- Checking through the data in each tables

SELECT * FROM plans_plan;
SELECT * FROM savings_savingsaccount;
SELECT * FROM users_customuser;
SELECT * FROM withdrawals_withdrawal;

/* Question 2

Transaction Frequency Analysis
Scenario: The finance team wants to analyze how often customers transact to segment them (e.g., frequent vs. occasional users).
Task: Calculate the average number of transactions per customer per month and categorize them:
"High Frequency" (≥10 transactions/month)
"Medium Frequency" (3-9 transactions/month)
"Low Frequency" (≤2 transactions/month) */

WITH customer_transaction_status AS (
    SELECT 
        s.owner_id,
        COUNT(*) AS total_transactions, -- counts the total number of savings transactions per customer.
        COUNT(DISTINCT DATE_FORMAT(s.transaction_date, '%Y-%m')) AS active_months -- extracts year and month to count how many different months the customer was active.
    FROM 
        savings_savingsaccount s
    WHERE 
        s.transaction_date IS NOT NULL
    GROUP BY 
        s.owner_id
    HAVING 
        active_months > 0  -- ensures we only include users with at least one month of activity (prevents division by zero later).
),
customer_transaction_with_category AS (
    SELECT 
        owner_id,
        total_transactions,
        active_months,
        ROUND(total_transactions / active_months, 2) AS avg_tx_per_month, -- gives the average monthly transactions per customer.
        CASE -- assign a label
            WHEN (total_transactions / active_months) >= 10 THEN 'High Frequency'
            WHEN (total_transactions / active_months) BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM 
        customer_transaction_status
)
SELECT 
    frequency_category,
    COUNT(*) AS customer_count,  -- number of customers in each category
    ROUND(AVG(avg_tx_per_month), 1) AS avg_transactions_per_month  -- average of all customers’ avg monthly transaction within each group
FROM 
    customer_transaction_with_category
GROUP BY 
    frequency_category
ORDER BY 
    FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency');  -- ensures the rows appear in the desired order (High → Medium → Low), rather than alphabetically

/* My approach in Solving the Problem:
Established a CTE for Transaction Aggregation
I began by creating a Common Table Expression (CTE) named customer_transaction_status to streamline the logic and improve query readability.

Calculated Transaction Volume and Activity Span
For each customer, I computed the total number of savings transactions. 
To determine the span of activity, I formatted the transaction_date into YYYY-MM format and counted the distinct months in which each customer was active.

Filtered and Grouped the Core Dataset
I excluded any records with NULL transaction dates to ensure data quality. 
The data was then grouped by customer (owner_id), and I filtered out customers with zero active months to prevent division-by-zero issues in subsequent steps.

Introduced a Second CTE for Frequency Classification
Using the output of the first CTE, I defined a second CTE—customer_transaction_with_category. 
This layer added a calculated field for average transactions per month, rounded to two decimal places, and introduced a categorization logic based on transaction frequency.

Classified Customers by Engagement Levels
Based on their transaction behavior, I segmented customers into three meaningful groups:

High Frequency: 10 or more transactions per month

Medium Frequency: Between 3 and 9 transactions per month

Low Frequency: Fewer than 3 transactions per month

Aggregated and Presented the Final Results
In the final step, I grouped customers by their frequency category, counted the number of customers in each group, and computed the average of their average monthly transactions. 
I used the FIELD function to sort the output in a business-relevant order: High, Medium, then Low Frequency. */

