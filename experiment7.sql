-- STEP 1: CREATE DATABASE

CREATE DATABASE DBMS_Experiment10;
USE DBMS_Experiment10;


-- STEP 2: CREATE SALES TABLE

CREATE TABLE SalesAnalytics (
    OrderID INT PRIMARY KEY,
    CustomerID INT NOT NULL,
    CustomerName VARCHAR(60),
    Region VARCHAR(20),
    OrderDate DATE NOT NULL,
    Status VARCHAR(20),
    ProductCategory VARCHAR(30),
    Quantity INT,
    Amount DECIMAL(10,2)
) ENGINE = InnoDB;


-- STEP 3: GENERATE 10,000 RECORDS

SET SESSION cte_max_recursion_depth = 11000;

INSERT INTO SalesAnalytics
(OrderID, CustomerID, CustomerName, Region, OrderDate,
 Status, ProductCategory, Quantity, Amount)

WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 10000
)

SELECT
    n,
    1000 + MOD(n, 2500),
    CONCAT('Customer_', MOD(n, 1800) + 1),
    ELT(MOD(n, 4) + 1, 'North', 'South', 'East', 'West'),
    DATE_ADD('2026-01-01', INTERVAL MOD(n, 365) DAY),
    ELT(MOD(n, 4) + 1,
        'Delivered', 'Pending', 'Cancelled', 'Returned'),
    ELT(MOD(n, 5) + 1,
        'Electronics', 'Clothing', 'Books', 'Home', 'Sports'),
    MOD(n, 8) + 1,
    500 + MOD(n * 37, 12000)
FROM seq;


-- VERIFY TOTAL RECORDS

SELECT COUNT(*) AS TotalRows
FROM SalesAnalytics;


-- ============================================
-- QUERY 1: FILTER RECORDS BY REGION
-- ============================================

-- BEFORE OPTIMIZATION

EXPLAIN
SELECT *
FROM SalesAnalytics
WHERE Region = 'North';

-- OPTIMIZATION: CREATE INDEX

CREATE INDEX idx_region
ON SalesAnalytics(Region);

-- AFTER OPTIMIZATION

EXPLAIN
SELECT OrderID, CustomerName, OrderDate, Amount
FROM SalesAnalytics
WHERE Region = 'North';


-- ============================================
-- QUERY 2: FILTER BY STATUS AND DATE
-- ============================================

-- BEFORE OPTIMIZATION

EXPLAIN
SELECT OrderID, OrderDate, Amount
FROM SalesAnalytics
WHERE OrderDate BETWEEN '2026-01-01' AND '2026-03-31'
AND Status = 'Delivered';

-- OPTIMIZATION: COMPOSITE INDEX

CREATE INDEX idx_status_date
ON SalesAnalytics(Status, OrderDate);

-- AFTER OPTIMIZATION

EXPLAIN
SELECT OrderID, OrderDate, Amount
FROM SalesAnalytics
WHERE Status = 'Delivered'
AND OrderDate BETWEEN '2026-01-01' AND '2026-03-31';


-- ============================================
-- QUERY 3: FILTER BY REGION AND AMOUNT
-- ============================================

-- BEFORE OPTIMIZATION

EXPLAIN
SELECT Region, SUM(Amount)
FROM SalesAnalytics
WHERE Region = 'West'
AND Amount >= 5000
GROUP BY Region;

-- OPTIMIZATION: COMPOSITE INDEX

CREATE INDEX idx_region_amount
ON SalesAnalytics(Region, Amount);

-- AFTER OPTIMIZATION

EXPLAIN
SELECT Region, SUM(Amount)
FROM SalesAnalytics
WHERE Region = 'West'
AND Amount >= 5000
GROUP BY Region;


-- ============================================
-- QUERY 4: SEARCH USING YEAR FUNCTION
-- ============================================

-- BEFORE OPTIMIZATION

EXPLAIN
SELECT COUNT(*)
FROM SalesAnalytics
WHERE YEAR(OrderDate) = 2026;

-- OPTIMIZATION: CREATE DATE INDEX

CREATE INDEX idx_order_date
ON SalesAnalytics(OrderDate);

-- REWRITE QUERY USING DATE RANGE

EXPLAIN
SELECT COUNT(*)
FROM SalesAnalytics
WHERE OrderDate >= '2026-01-01'
AND OrderDate < '2027-01-01';


-- ============================================
-- QUERY 5: SUBQUERY OPTIMIZATION
-- ============================================

-- BEFORE OPTIMIZATION

EXPLAIN
SELECT CustomerID, CustomerName
FROM SalesAnalytics
WHERE CustomerID IN (
    SELECT CustomerID
    FROM SalesAnalytics
    WHERE Status = 'Delivered'
);

-- OPTIMIZATION: COMPOSITE INDEX

CREATE INDEX idx_status_customer
ON SalesAnalytics(Status, CustomerID);

-- AFTER OPTIMIZATION: JOIN

EXPLAIN
SELECT DISTINCT a.CustomerID, a.CustomerName
FROM SalesAnalytics a
JOIN SalesAnalytics d
ON d.CustomerID = a.CustomerID
WHERE d.Status = 'Delivered';


-- ============================================
-- FINAL PERFORMANCE ANALYSIS
-- ============================================

-- ACTUAL EXECUTION PLAN (MySQL 8.0.18+)

EXPLAIN ANALYZE
SELECT OrderID, OrderDate, Amount
FROM SalesAnalytics
WHERE Status = 'Delivered'
AND OrderDate BETWEEN '2026-01-01' AND '2026-03-31';


-- CHECK ALL CREATED INDEXES

SHOW INDEX FROM SalesAnalytics;

-- CHECK TOTAL RECORDS AGAIN

SELECT COUNT(*) AS TotalRows
FROM SalesAnalytics;
