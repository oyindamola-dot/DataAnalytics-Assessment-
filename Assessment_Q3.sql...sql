USE adashi_staging;

-- Checking through the tables in my database.
SELECT * FROM plans_plan;
SELECT * FROM savings_savingsaccount;
SELECT * FROM users_customuser;
SELECT * FROM withdrawals_withdrawal;

/* Question 3
	Account Inactivity Alert
	Scenario: The ops team wants to flag accounts with no inflow transactions for over one year.
	Task: Find all active accounts (savings or investments) with no transactions in the last 1 year (365 days). */
  
-- This Common Table Expression (CTE) below gets the last transaction date for each plan:

WITH last_transactions AS (             
    SELECT 
        plan_id,
        MAX(transaction_date) AS last_transaction_date
    FROM 
        savings_savingsaccount
    WHERE 
        transaction_date IS NOT NULL
    GROUP BY 
        plan_id					/* Looks at the savings_savingsaccount table and group by plan_id
									For each plan, selects the latest (most recent) transaction date and Ignores rows with NULL transaction dates. */
),
-- This CTE pulls in active financial plans from the plans_plan table
active_plans AS (
    SELECT 
        id AS plan_id,			-- Renames id to plan_id to match the previous CTE.
        owner_id,
        CASE
            WHEN is_regular_savings = TRUE THEN 'Savings'
            WHEN is_a_fund = TRUE OR is_fixed_investment = TRUE THEN 'Investment'
            ELSE 'Other'
        END AS type
    FROM 
        plans_plan
    WHERE 
        is_archived = FALSE AND (is_deleted_from_group IS NULL OR is_deleted_from_group = FALSE)		-- Filters only active and not deleted plans
)
SELECT						-- Now, join the two CTEs to find inactive plans
    ap.plan_id,
    ap.owner_id,
    ap.type,
    lt.last_transaction_date,
    DATEDIFF(CURRENT_DATE, lt.last_transaction_date) AS inactivity_days
FROM 
    active_plans ap
LEFT JOIN 					-- Uses a LEFT JOIN to include all active plans, and joins any matching last transaction.
    last_transactions lt ON ap.plan_id = lt.plan_id
WHERE 
    lt.last_transaction_date IS NOT NULL
    AND DATEDIFF(CURRENT_DATE, lt.last_transaction_date) > 365
ORDER BY 					-- Sorts the results to show the most inactive plans first
    inactivity_days DESC;


