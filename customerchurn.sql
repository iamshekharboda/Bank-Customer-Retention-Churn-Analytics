Create Database Customer_Churn

-- ==========================================
-- SETUP DATABASE & TABLE
-- ==========================================




-- ==========================================
-- 1. KEY PERFORMANCE INDICATORS (KPIs)
-- ==========================================

-- Total Customers: What is the total number of customers in the dataset?
SELECT COUNT(*) AS Total_Customers
FROM customer;

-- Total Exited: How many total customers have churned/exited?
SELECT SUM(Exited) AS Total_Exited
FROM customer;

-- Average Age: What is the average age of the customer base?
SELECT AVG(Age) AS Average_Age
FROM customer;

-- Average Balance: What is the average account balance?
SELECT AVG(Balance) AS Average_Balance
FROM customer;

-- Average Credit Score: What is the average credit score of our customers?
SELECT AVG(CreditScore) AS Average_Credit_Score
FROM customer;

-- Average Tenure: What is the average number of years customers have been with the bank?
SELECT AVG(Tenure) AS Average_Tenure
FROM customer;

-- Average Salary: What is the average estimated salary of the customers?
SELECT AVG(EstimatedSalary) AS Average_Salary
FROM customer;

-- Average Products: What is the average number of products held by a customer?
SELECT AVG(NumOfProducts) AS Average_Products
FROM customer;

-- Credit Card Holders: How many customers own a credit card?
SELECT SUM(HasCrCard) AS Credit_Card_Holders
FROM customer;

-- Active Members: How many customers are considered active members?
SELECT SUM(IsActiveMember) AS Active_Members
FROM customer;


-- ==========================================
-- 2. DEMOGRAPHIC & GEOGRAPHIC ANALYSIS
-- ==========================================

-- Exited by Gender: Number and percentage of churned customers broken down by Gender (using Gender_Male flag: 1 = Male, 0 = Female)
SELECT 
    CASE WHEN Gender_Male = 1 THEN 'Male' ELSE 'Female' END AS Gender, 
    SUM(Exited) AS Churned_Customers,
    COUNT(*) AS Total_Customers,
    ROUND(CAST(SUM(Exited) AS FLOAT) / COUNT(*) * 100, 2) AS Churn_Percentage
FROM customer
GROUP BY Gender_Male;

-- Exited by Geography: How many customers exited broken down by regional indicators
-- (Adjust column names based on your full geography dummy/encoded columns)
SELECT 
    'France/Region 1' AS Geography, -- Replace or map according to your exact geography columns
    SUM(Exited) AS Churned_Customers,
    COUNT(*) AS Total_Customers,
    ROUND(CAST(SUM(Exited) AS FLOAT) / COUNT(*) * 100, 2) AS Churn_Percentage
FROM customer
GROUP BY Geography_Hy... -- Use your specific geography indicator column here

UNION ALL

SELECT 
    'Germany/Region 2' AS Geography,
    SUM(Exited) AS Churned_Customers,
    COUNT(*) AS Total_Customers,
    ROUND(CAST(SUM(Exited) AS FLOAT) / COUNT(*) * 100, 2) AS Churn_Percentage
FROM customer
GROUP BY Geography_M...; -- Use your second geography indicator column here

-- Overall Churn Ratio: Proportion of customers who exited versus those who stayed
SELECT 
    Exited, 
    COUNT(*) AS Customer_Count,
    ROUND(CAST(COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM customer) * 100, 2) AS Percentage
FROM customer
GROUP BY Exited;


-- ==========================================
-- 3. BEHAVIORAL & DISTRIBUTION ANALYSIS
-- ==========================================

-- Age Distribution & Churn: Grouping customers into age brackets
SELECT 
    CASE 
        WHEN Age < 30 THEN 'Under 30'
        WHEN Age BETWEEN 30 AND 39 THEN '30-39'
        WHEN Age BETWEEN 40 AND 49 THEN '40-49'
        WHEN Age BETWEEN 50 AND 59 THEN '50-59'
        ELSE '60+' 
    END AS AgeBin,
    Exited,
    COUNT(*) AS Customer_Count
FROM customer
GROUP BY 
    CASE 
        WHEN Age < 30 THEN 'Under 30'
        WHEN Age BETWEEN 30 AND 39 THEN '30-39'
        WHEN Age BETWEEN 40 AND 49 THEN '40-49'
        WHEN Age BETWEEN 50 AND 59 THEN '50-59'
        ELSE '60+' 
    END,
    Exited
ORDER BY AgeBin, Exited;

-- Balance Distribution: Grouping customers into specific account balance ranges
SELECT 
    CASE 
        WHEN Balance = 0 THEN 'Zero Balance'
        WHEN Balance > 0 AND Balance <= 50000 THEN '1 - 50k'
        WHEN Balance > 50000 AND Balance <= 100000 THEN '50k - 100k'
        WHEN Balance > 100000 AND Balance <= 150000 THEN '100k - 150k'
        ELSE '150k+' 
    END AS BalanceBin,
    COUNT(*) AS Customer_Count
FROM customer
GROUP BY 
    CASE 
        WHEN Balance = 0 THEN 'Zero Balance'
        WHEN Balance > 0 AND Balance <= 50000 THEN '1 - 50k'
        WHEN Balance > 50000 AND Balance <= 100000 THEN '50k - 100k'
        WHEN Balance > 100000 AND Balance <= 150000 THEN '100k - 150k'
        ELSE '150k+' 
    END
ORDER BY BalanceBin;

-- Products vs. Churn: How the number of products held affects likelihood to exit
SELECT 
    NumOfProducts, 
    Exited, 
    COUNT(*) AS Customer_Count
FROM customer
GROUP BY NumOfProducts, Exited
ORDER BY NumOfProducts, Exited;









