USE adashi_staging;

-- Checking through the data in the tables

SELECT * FROM plans_plan;
SELECT * FROM savings_savingsaccount;
SELECT * FROM users_customuser;
SELECT * FROM withdrawals_withdrawal;

-- To start with the first query

 SELECT
    u.id AS owner_id,		-- Selects the user ID from the users_customuser table and renames it to owner_id
    u.name,
    COUNT(DISTINCT CASE WHEN p.is_regular_savings = TRUE THEN s.plan_id END) AS savings_count,		-- Counts unique saving plan IDs where the plan is marked as a regular savings plan.
    COUNT(DISTINCT CASE WHEN p.is_a_fund = TRUE OR p.is_fixed_investment = TRUE THEN s.plan_id END) AS investment_count,		-- Counts unique saving plan IDs that are either a fund or a fixed investment plan
    ROUND(SUM(s.amount), 2) AS total_deposits		-- rounding up the total deposit for each user to two decimal places.
FROM 
    users_customuser u		-- aliasing users_customuser as u
JOIN 
    savings_savingsaccount s ON u.id = s.owner_id		-- linking savings accounts to their owners.
JOIN 
    plans_plan p ON s.plan_id = p.id			-- linking each saving account to its specific plan details.
WHERE 
    s.amount IS NOT NULL		-- Filters out any savings accounts where the deposit amount is NULL
GROUP BY 
    u.id, u.name
HAVING 
    savings_count > 0 AND investment_count > 0		-- Filters groups (users) to only include those who have at least one regular saving plan and one investment plan > 0 
ORDER BY 
    total_deposits DESC;		-- Orders the resulting list of users by their total deposits in descending order

