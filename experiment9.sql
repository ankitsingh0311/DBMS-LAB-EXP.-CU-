-- 1. Create Railway Booking Table

CREATE TABLE RailwayBooking (
    BookingID INT PRIMARY KEY,
    PassengerName VARCHAR(60) NOT NULL,
    TrainNo INT NOT NULL,
    SourceStation VARCHAR(40) NOT NULL,
    DestinationStation VARCHAR(40) NOT NULL,
    JourneyDate DATE NOT NULL,
    TravelClass VARCHAR(20) NOT NULL,
    BookingStatus VARCHAR(20) NOT NULL,
    Fare DECIMAL(8,2) NOT NULL
) ENGINE = InnoDB;


-- 2. Insert at Least 5,000 Records

SET SESSION cte_max_recursion_depth = 6000;

INSERT INTO RailwayBooking
(BookingID, PassengerName, TrainNo, SourceStation, DestinationStation,
 JourneyDate, TravelClass, BookingStatus, Fare)

WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 5000
)

SELECT n,
    CONCAT('Passenger_', n),
    12000 + MOD(n, 50),
    ELT(MOD(n, 5) + 1, 'Delhi', 'Mumbai', 'Chennai', 'Kolkata', 'Pune'),
    ELT(MOD(n + 2, 5) + 1, 'Agra', 'Jaipur', 'Bhopal', 'Lucknow', 'Surat'),
    DATE_ADD('2026-12-01', INTERVAL MOD(n, 90) DAY),
    ELT(MOD(n, 3) + 1, 'Sleeper', 'AC 3 Tier', 'AC 2 Tier'),
    ELT(MOD(n, 3) + 1, 'CONFIRMED', 'WAITING', 'CANCELLED'),
    250 + MOD(n * 17, 2000)
FROM seq;

-- Verify total records

SELECT COUNT(*) AS TotalBookings
FROM RailwayBooking;


-- 3. Select a Benchmark Query

SELECT BookingID, PassengerName, Fare
FROM RailwayBooking
WHERE TrainNo = 12045
  AND BookingStatus = 'CONFIRMED'
  AND JourneyDate BETWEEN '2026-12-01' AND '2026-12-31';


-- 4. Query Plan Before Creating Indexes

EXPLAIN
SELECT BookingID, PassengerName, Fare
FROM RailwayBooking
WHERE TrainNo = 12045
  AND BookingStatus = 'CONFIRMED'
  AND JourneyDate BETWEEN '2026-12-01' AND '2026-12-31';


-- 5. Create a Single-Column Index

CREATE INDEX idx_train_no
ON RailwayBooking(TrainNo);

-- Execute EXPLAIN again

EXPLAIN
SELECT BookingID, PassengerName, Fare
FROM RailwayBooking
WHERE TrainNo = 12045
  AND BookingStatus = 'CONFIRMED'
  AND JourneyDate BETWEEN '2026-12-01' AND '2026-12-31';


-- 6. Create a Composite Index

CREATE INDEX idx_train_status_date
ON RailwayBooking(TrainNo, BookingStatus, JourneyDate);

-- Execute EXPLAIN again

EXPLAIN
SELECT BookingID, PassengerName, Fare
FROM RailwayBooking
WHERE TrainNo = 12045
  AND BookingStatus = 'CONFIRMED'
  AND JourneyDate BETWEEN '2026-12-01' AND '2026-12-31';


-- 7. Benchmark Actual Query Execution

EXPLAIN ANALYZE
SELECT BookingID, PassengerName, Fare
FROM RailwayBooking
WHERE TrainNo = 12045
  AND BookingStatus = 'CONFIRMED'
  AND JourneyDate BETWEEN '2026-12-01' AND '2026-12-31';
