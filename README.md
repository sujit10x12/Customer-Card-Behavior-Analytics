# 💳 Credit Card Analysis using PowerBi and SQL
![credit_card1](https://github.com/user-attachments/assets/8180e624-f85a-4463-a52f-8cf621945c4d)

---

## 👀 What’s This Project About?

This project focuses on analyzing credit card transaction data to uncover key insights, trends, and performance metrics. Using SQL for data extraction and transformation, and Power BI for visualization, the goal is to build a dynamic weekly dashboard that empowers stakeholders with real-time, data-driven insights into credit card operations.

> ✅ And **SQL Queries** here:** [🔗 View SQL queries](queries.sql)

---

## 🎯 Objective
Built a dynamic weekly dashboard for credit card operations using Power BI and SQL, delivering real-time insights into key performance metrics and trends. Empowers stakeholders to monitor and analyze activities efficiently.

---

## ❓ Key Business Questions
 - What are our key financial metrics?
 - Which card category generates the most revenue and fees?
 - What are the top spending (expenditure) categories?
 - Which job segments are most profitable?
 - How do customers use their cards (Swipe, Chip, Online)?
 - What is the revenue trend over time by gender?
 - Which customer professions generate the most revenue and transactions?
 - Which age groups are most valuable?
 - Which states generate the most revenue?
 - How does salary group impact revenue?
 - How does education level relate to revenue?
 - Are there seasonal trends (Weekly) in revenue?

---

## 🛠️ Tech Stack
 - SQL Server Management Studio
 - Power Bi
 - Github

---

## 📁 Dataset Details

This analysis is based on a structured dataset in CSV format, containing 10,108 records across 18 features.

### 📊 Columns Description

- Dataset: <a href="">credit_card.csv</a> 

| Column Name    | Description |
|----------------|-------------|
| `Client_Num`      | Client’s transaction number |
| `Card_Category`         | Type of card  |
| `Annual_Fees`        | Annual Fees Paid for card by client |
| `Activation_30_Days`     | Whether the client activated their card within 30 days or not |
| `Customer_Acq_Cost`         | Amount spent for acquiring the client |
| `Week_Start_Date`      | Date of the first day of each week of the year |
| `Week_Num`   | Rolling count of the number of weeks |
| `Qtr` | Quarter of the year |
| `current_year`       | Operational Year |
| `Credit_Limit`     | Amount limit of the card |
| `Total_Revolving_Bal`    | Balance amount that carries over from one month to the next month |
| `Total_Trans_Amt`  | Amount that has been transacted by the client |
| `Total_Trans_Vol`  | Number of times that the client has trasacted from their card |
| `Avg_Utilization_Ratio`  | Ratio of the amount of revolving credit and the total available credit to the client |
| `Use Chip`  | Type of method the client used for their card |
| `Exp Type`  | Type of bills that the client used their card for |
| `Interest_Earned`  | Amount of interest that the company earned through the card |
| `Deliquent_Acc`  | Whether a payment not paid for 30 days or more |


- Dataset: <a href="">customer.csv</a> 

| Column Name    | Description |
|----------------|-------------|
| `Client_Num`      | It is the client’s transaction number |
| `Customer_Age `      | SELF-EXPLANATORY |
| `Gender`      | SELF-EXPLANATORY |
| `Dependent_Count`         | Number of people that the client supports financially  |
| `Education_Level`        | Highest level of education that the client has received |
| `Marital_Status`     | SELF-EXPLANATORY |
| `state_cd`         | Short code of the state that the client resides in |
| `Zipcode`         | SELF-EXPLANATORY |
| `Car_Owner`      | Client owns a car or not |
| `House_Owner`   | Client owns a house or not |
| `Personal_loan` | Client has personal loan or not. |
| `contact`       | Type of contact that the client has provided |
| `Customer_Job`       | Job that client has |
| `Income`       | SELF-EXPLANATORY |
| `Cust_Satisfaction_Score` | Satisfaction score out of 5 |

---

## 📥 Loading the Data

Rather than loading the data directly into Power BI, I chose to connect it through an SQL Server. This setup allows all visualizations to update dynamically whenever new data is added to the source

For this project, I used SQL Server Management Studio to manage and query the database efficiently.

- Once the database was set up in SQL Server Management Studio I created two tables with the same columns as the source CSVs—one for transactions and one for customers

```SQL
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
```
- Next, I imported all the raw data from the source CSV files into the newly created tables using SQL Server Management Studio’s Import Data wizard.

---

## 🧼 Data Cleaning & Transformation

- Each column across both tables was thoroughly reviewed to gain a clear understanding of the data and its relevance within the business domain. No missing values or inconsistencies were identified.

- To support analysis, I created two SQL views—temp_cc_table and temp_customer_table—by adding calculated columns like Revenue, Week_Num2, AgeGroup, and IncomeGroup to the original credit_card and customer tables.

```SQL
-- Create view for creditCard Table
CREATE VIEW temp_cc_table AS
SELECT 
	*,
	(Annual_Fees + Total_Trans_Amt + Interest_Earned) AS Revenue,
	RIGHT(Week_Num,LEN(Week_Num)-CHARINDEX('-',Week_Num)) AS Week_Num2
FROM dbo.credit_card

-- Create view for customer table
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
```

- 📄 Note: For better readability, only key snippets are shown in this README. You can view the full set of SQL queries <a href="">**in this file**</a>

---

## 🔌 Connecting SQL Server Database to Power BI
Linking SQL Server Management Studio database directly to Power BI in order to easily visualize and analyze the data in real-time.

<img width="581" height="290" alt="sql-powerbi" src="https://github.com/user-attachments/assets/47438b6a-1895-483b-8311-dd056677b27c" />

Before diving into the analysis and visualization with the help of DAX queries, additional calculated columns and measures were created. These included key business metrics and performance indicators tailored to support effective dashboard insights.

- AgeGroup
- IncomeGroup
- Week_Num2
- Revenue
- Current_Week_Revenue
- Previous_Week_Revenue
- WoW_Revenue

```dax
AgeGroup = SWITCH(
    TRUE(),
    customer[Customer_Age] < 31, "20-30",
    customer[Customer_Age] >= 31 && customer[Customer_Age] < 41, "31-40",
    customer[Customer_Age] >= 41 && customer[Customer_Age] < 51, "41-50",
    customer[Customer_Age] >= 51 && customer[Customer_Age] < 61, "51-60",
    customer[Customer_Age] > 60, "60+",
    "Unknown"
)

IncomeGroup = SWITCH(
    TRUE(),
    customer[Income] <= 35000, "Low",
    customer[Income] > 35000 && customer[Income] <= 75000, "Medium",
    customer[Income] > 75000, "High",
    "Unknwn"
)

Week_NUM2 = WEEKNUM(credit_card[Week_Start_Date])

Revenue = credit_card[Annual_Fees] + credit_card[Total_Trans_Amt] + credit_card[Interest_Earned]

Current_Week_Revenue = CALCULATE(
    SUM(credit_card[Revenue]),
    FILTER(ALL(credit_card),
        credit_card[Week_NUM2] = MAX(credit_card[Week_NUM2])
    )
)

Previous_Week_Revenue = CALCULATE(
    SUM(credit_card[Revenue]),
    FILTER(ALL(credit_card),
        credit_card[Week_NUM2] = MAX(credit_card[Week_NUM2])-1
    )
)

WOW_Revenue = DIVIDE([Current_Week_Revenue]-[Previous_Week_Revenue],[Previous_Week_Revenue])
```

---

## 📈 Dashboard Development

The dashboard is split into two parts: one for detailed transaction analysis and another for customer-level insights, enabling focused and comprehensive reporting.

**Transaction Analysis**  
![transactions_report](https://github.com/user-attachments/assets/2b35af12-d292-452e-9eda-9fc2933cd07a)

- **KPIs** : There are 4 main KPIs present. They are Revenue, Total Transacted Amount, Total Interest & Count of Transaction.
- **Filters** : For filters I used Card Type, Quarter, Customer Income Groups & their genders.
- **Slicer** : I used Week numbers as a slicer.

**Customer Analysis**  
![customer_dasboard](https://github.com/user-attachments/assets/ae96a740-383d-45ec-9768-a80f2241e2c7)

- **KPIs** : There are 4 main KPIs present here as well. They are Revenue, Total Transacted Amount, Customer’s Total Income & CSS or Customer Satisfaction Score.
- **Filters** : Here, for filters I used Customer gender as a general divider between almost all the data. I also used Card Type & Quarter as before, but introduced Card Type.
- **Slicer** : I used Week numbers as the slicer here as well.

---

## ✅ Solution

- Total Revenue: $55.4 Million.

- Total Interest Earned: $7.9 Million.

- Total Income: $577 Million.

- CSS (Credit Score Segment Avg): 3.19.

-  Self-employed customers bring in the most revenue and transactions, though businessmen lead in income.

-  Highest Revenue Age Group: 40–50 years (around $25M).

-  Texas (TX), New York (NY) and California (CA) are the top 3 revenue generator states.

-  High Salary Customers (>$70,000) contribute more to revenue — a clear tiering opportunity.

-  Graduates and High School level customers are top contributors.

-  Peaks around March, July, and October & dips in April and September.

-  Blue cards dominate in revenue, interest, and fees — but they also have the highest acquisition cost.

-  Bills, Entertainment, Fuel & Grocery are the top spending (expenditure) categories.

-  Physical transactions dominate; digital/online spending is low — possible opportunity for online usage incentives.

-  Blue card customers are expensive to acquire — consider retention programs or optimizing CAC.

---

