-- Create creditCard
CREATE TABLE creditCard (
    Client_Num INT,
    Card_Category VARCHAR(20),
    Annual_Fees INT,
    Activation_30_Days INT,
    Customer_Acq_Cost INT,
    Week_Start_Date DATE,
    Week_Num VARCHAR(20),
    Qtr VARCHAR(10),
    current_year INT,
    Credit_Limit DECIMAL(10,2),
    Total_Revolving_Bal INT,
    Total_Trans_Amt INT,
    Total_Trans_Ct INT,
    Avg_Utilization_Ratio DECIMAL(10,3),
    Use_Chip VARCHAR(10),
    Exp_Type VARCHAR(50),
    Interest_Earned DECIMAL(10,3),
    Delinquent_Acc VARCHAR(5)
);


-- Create customer table
CREATE TABLE customer (
    Client_Num INT,
    Customer_Age INT,
    Gender VARCHAR(5),
    Dependent_Count INT,
    Education_Level VARCHAR(50),
    Marital_Status VARCHAR(20),
    State_cd VARCHAR(50),
    Zipcode VARCHAR(20),
    Car_Owner VARCHAR(5),
    House_Owner VARCHAR(5),
    Personal_Loan VARCHAR(5),
    Contact VARCHAR(50),
    Customer_Job VARCHAR(50),
    Income INT,
    Cust_Satisfaction_Score INT
);


-- Create temporary Tables for creditCard & customer
CREATE VIEW temp_cc_table AS
SELECT 
	*,
	(Annual_Fees + Total_Trans_Amt + Interest_Earned) AS Revenue,
	RIGHT(Week_Num,LEN(Week_Num)-CHARINDEX('-',Week_Num)) AS Week_Num2
FROM dbo.credit_card

-- 
CREATE VIEW temp_customer_table AS 
SELECT 
	*,
	CASE
		WHEN Customer_Age < 31 THEN '20-30'
		WHEN Customer_Age BETWEEN 31 AND 40 THEN '31-40'
		WHEN Customer_Age BETWEEN 41 AND 50 THEN '41-50'
		WHEN Customer_Age BETWEEN 51 AND 60 THEN '51-60'
		WHEN Customer_Age > 60 THEN '60+'
		ELSE 'Unknown'
	END AS AgeGroup,
	CASE 
		WHEN Income <= 35000 THEN 'Low'
		WHEN Income BETWEEN 35000 AND 75000 THEN 'Medium'
		WHEN Income > 75000 THEN 'High'
		ELSE 'Unkown'
	END AS IncomeGroup
FROM
	dbo.customer
	
--------------------------------------------------- KPIs ----------------------------------------------------
-- Total Revenue
SELECT ROUND(SUM(Revenue), 0) AS total_revenue
FROM temp_cc_table

-- Total Transactions Amount
SELECT SUM(total_trans_Amt) AS total_trans_amt
FROM temp_cc_table

-- Total Interest Amount
SELECT ROUND(SUM(Interest_Earned), 0)
FROM temp_cc_table

-- Total Transactions
SELECT SUM(Total_Trans_Vol) AS total_transactions
FROM temp_cc_table

-- Total Income
SELECT SUM(Income) AS total_transactions
FROM temp_customer_table

-- Average Customer Satisfaction Score
SELECT ROUND(AVG(CAST(Cust_Satisfaction_Score AS FLOAT)), 2) AS total_transactions
FROM dbo.customer

----------------------------------------------------------------------------------------------
-- Revenue Breakdown by Age
SELECT
	temp_customer_table.AgeGroup,
	ROUND(SUM(Revenue), 0) AS total_revenue
FROM 
	temp_cc_table JOIN temp_customer_table
	ON temp_cc_table.Client_Num = temp_customer_table.Client_Num
GROUP BY temp_customer_table.AgeGroup
ORDER BY total_revenue DESC

-- Top 5 Revenue Generator States
SELECT TOP(5)
	temp_customer_table.state_cd,
	ROUND(SUM(Revenue), 0) AS total_revenue
FROM 
	temp_cc_table JOIN temp_customer_table
	ON temp_cc_table.Client_Num = temp_customer_table.Client_Num
GROUP BY temp_customer_table.state_cd
ORDER BY total_revenue DESC

-- Revenue Breakdown by Occupation
SELECT
	temp_customer_table.Customer_Job,
	ROUND(SUM(Revenue), 0) AS total_revenue
FROM 
	temp_cc_table JOIN temp_customer_table
	ON temp_cc_table.Client_Num = temp_customer_table.Client_Num
GROUP BY temp_customer_table.Customer_Job
ORDER BY total_revenue DESC

-- Revenue Breakdown by Income
SELECT TOP(5)
	temp_customer_table.IncomeGroup,
	ROUND(SUM(Revenue), 0) AS total_revenue
FROM 
	temp_cc_table JOIN temp_customer_table
	ON temp_cc_table.Client_Num = temp_customer_table.Client_Num
GROUP BY temp_customer_table.IncomeGroup
ORDER BY total_revenue DESC


-- Revenue Breakdown by Gender
SELECT
	temp_customer_table.Gender,
	ROUND(SUM(Revenue), 0) AS total_revenue
FROM 
	temp_cc_table JOIN temp_customer_table
	ON temp_cc_table.Client_Num = temp_customer_table.Client_Num
GROUP BY temp_customer_table.Gender
ORDER BY total_revenue DESC

-- Revenue Breakdown by Use (Chip, Swipe, Online)
SELECT 
	Use_Chip,
	ROUND(SUM(Revenue), 0) AS total_revenue
FROM temp_cc_table
GROUP BY 
	Use_Chip
ORDER BY
	total_revenue DESC

-- Revenue Breakdown by Education Level
SELECT 
	temp_customer_table.Education_Level,
	ROUND(SUM(Revenue), 0) AS total_revenue
FROM 
	temp_cc_table JOIN temp_customer_table
	ON temp_cc_table.Client_Num = temp_customer_table.Client_Num
GROUP BY 
	temp_customer_table.Education_Level
ORDER BY
	total_revenue DESC
	
-- Revenue Breakdown by Expenditure Type
SELECT 
	Exp_Type,
	ROUND(SUM(Revenue), 0) AS total_revenue
FROM temp_cc_table
GROUP BY Exp_Type 
ORDER BY total_revenue DESC

-- Revenue Trend by Week
SELECT
	WEEK_NUM2,
	ROUND(SUM(Revenue), 0) AS total_revenue
FROM temp_cc_table
GROUP BY WEEK_NUM2
ORDER BY total_revenue DESC

-- Revenue Trend by Quarters
SELECT
	Qtr AS quarter,
	ROUND(SUM(Revenue), 0) AS total_revenue
FROM temp_cc_table
GROUP BY Qtr
ORDER BY total_revenue DESC

-- Revenue WoW Analysis
SELECT
	WEEK_NUM2,
	SUM(Revenue) AS total_revenue,
	LAG(SUM(Revenue)) OVER (ORDER BY CAST(WEEK_NUM2 AS float)) AS previous_month_revenue,
	ROUND(((SUM(Revenue) - LAG(SUM(Revenue)) OVER (ORDER BY CAST(WEEK_NUM2 AS float)))/LAG(SUM(Revenue)) OVER (ORDER BY CAST(WEEK_NUM2 AS float)))*100, 2) AS pct_revenue_diff
FROM
	temp_cc_table
GROUP BY
	WEEK_NUM2