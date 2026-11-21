-- 1. Create Dataset Table

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
  

-- 2. Generate at Least 10,000 Records

SET SESSION cte_max_recursion_depth = 11000;

INSERT INTO SalesAnalytics
(OrderID, CustomerID, CustomerName, Region, OrderDate, Status, ProductCategory, Quantity, Amount)

WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL SELECT n + 1 FROM seq WHERE n < 10000
)

SELECT n,
    1000 + MOD(n, 2500),
    CONCAT('Customer_', MOD(n, 1800) + 1),
    ELT(MOD(n, 4) + 1, 'North', 'South', 'East', 'West'),
    DATE_ADD('2026-01-01', INTERVAL MOD(n, 365) DAY),
    ELT(MOD(n, 4) + 1, 'Delivered', 'Pending', 'Cancelled', 'Returned'),
    ELT(MOD(n, 5) + 1, 'Electronics', 'Clothing', 'Books', 'Home', 'Sports'),
    MOD(n, 8) + 1,
    500 + MOD(n * 37, 12000)
FROM seq;

SELECT COUNT(*) AS TotalRows FROM SalesAnalytics;


-- 3. Five Slow Queries and EXPLAIN Analysis


-- QUERY 1: Filter by Region

-- Before Optimization

EXPLAIN
SELECT * FROM SalesAnalytics
WHERE Region = 'North';

-- Optimization: Create an index on Region
-- and select only the required columns.

CREATE INDEX idx_region ON SalesAnalytics(Region);

SELECT OrderID, CustomerName, OrderDate, Amount
FROM SalesAnalytics WHERE Region = 'North';


-- QUERY 2: Filter by Status and Date

-- Before Optimization

EXPLAIN
SELECT OrderID, OrderDate, Amount FROM SalesAnalytics
WHERE OrderDate BETWEEN '2026-01-01' AND '2026-03-31'
AND Status = 'Delivered';

-- Optimization: Use a composite index on Status and OrderDate.
-- Put the equality condition first, followed by the date range.

CREATE INDEX idx_status_date ON SalesAnalytics(Status, OrderDate);

SELECT OrderID, OrderDate, Amount FROM SalesAnalytics
WHERE Status = 'Delivered'
AND OrderDate BETWEEN '2026-01-01' AND '2026-03-31';


-- QUERY 3: Filter by Region and Amount

-- Before Optimization

EXPLAIN
SELECT Region, SUM(Amount) FROM SalesAnalytics
WHERE Region = 'West' AND Amount >= 5000
GROUP BY Region;

-- Optimization: Create a composite index on Region and Amount.

CREATE INDEX idx_region_amount ON SalesAnalytics(Region, Amount);

SELECT Region, SUM(Amount) FROM SalesAnalytics
WHERE Region = 'West' AND Amount >= 5000
GROUP BY Region;


-- QUERY 4: Function on Date Column

-- Before Optimization

EXPLAIN
SELECT COUNT(*) FROM SalesAnalytics
WHERE YEAR(OrderDate) = 2026;

-- Optimization: Avoid applying YEAR() to the indexed column.
-- Rewrite the condition as a date range.

CREATE INDEX idx_order_date ON SalesAnalytics(OrderDate);

SELECT COUNT(*) FROM SalesAnalytics
WHERE OrderDate >= '2026-01-01'
AND OrderDate < '2027-01-01';


-- QUERY 5: Subquery Rewritten as JOIN

-- Before Optimization

EXPLAIN
SELECT CustomerID, CustomerName FROM SalesAnalytics
WHERE CustomerID IN (
    SELECT CustomerID FROM SalesAnalytics
    WHERE Status = 'Delivered'
);

-- Optimization: Use DISTINCT with a JOIN
-- to return each qualifying customer once.

CREATE INDEX idx_status_customer ON SalesAnalytics(Status, CustomerID);

SELECT DISTINCT a.CustomerID, a.CustomerName
FROM SalesAnalytics a
JOIN SalesAnalytics d ON d.CustomerID = a.CustomerID
WHERE d.Status = 'Delivered';


-- 4. Compare Actual Execution Time

-- Use EXPLAIN ANALYZE for the composite-index query.

EXPLAIN ANALYZE
SELECT OrderID, OrderDate, Amount FROM SalesAnalytics
WHERE Status = 'Delivered'
AND OrderDate BETWEEN '2026-01-01' AND '2026-03-31';
