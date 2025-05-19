USE adashi_staging;

-- Checking through the data from provided tables
SELECT * FROM plans_plan;
SELECT * FROM savings_savingsaccount;
SELECT * FROM users_customuser;
SELECT * FROM withdrawals_withdrawal;

-- Question 4

SELECT 
    u.id AS customer_id,
    u.name,					-- selecting customer_id and name from the users_customuser table
    TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) AS tenure_months,	-- how long the customer has been with us, in months, using TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE())
    COUNT(s.id) AS total_transactions,		-- number of savings transactions made by the user (using COUNT(s.id)).
    ROUND(
        (COUNT(s.id) / NULLIF(TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()), 0)) 		-- Average number of transactions per month. NULLIF was used to avoids division by zero for new users who have 0 months of tenure.
        * 12 						-- Scales this to an annual rate of transactions.
        * (0.001 * AVG(s.amount)),	-- applying a profit margin (0.1%). Multiply annual transaction count by average amount * margin = Estimated Customer Lifetime
        2							-- Round the result to 2 decimal places.
    ) AS estimated_clv
FROM 
    users_customuser u
JOIN 								-- join users_customuser with savings_savingsaccount to get each user’s transactions
    savings_savingsaccount s ON u.id = s.owner_id
WHERE 
    s.amount IS NOT NULL			-- exclude null transactions (only valid transactions are counted).		
GROUP BY 							-- Aggregates the result per user
    u.id, u.name, u.date_joined
ORDER BY 							-- Sorts the final result to show users with the highest estimated lifetime value first.
    estimated_clv DESC;