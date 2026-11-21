-- STEP 1: CREATE DATABASE

CREATE DATABASE DBMS_Experiment8;
USE DBMS_Experiment8;


-- STEP 2: CREATE BANKING TABLE

CREATE TABLE Accounts (
    AccountID INT PRIMARY KEY,
    AccountHolder VARCHAR(50) NOT NULL,
    Balance DECIMAL(12,2) NOT NULL CHECK (Balance >= 0)
) ENGINE = InnoDB;


-- STEP 3: INSERT INITIAL RECORDS

INSERT INTO Accounts
(AccountID, AccountHolder, Balance)
VALUES
(101, 'Aarav', 5000.00),
(102, 'Diya', 3000.00);


-- DISPLAY ACCOUNT DETAILS

SELECT *
FROM Accounts
ORDER BY AccountID;


-- ==================================================
-- STEP 4: BANKING TRANSACTION USING BEGIN AND COMMIT
-- Transfer Rs. 500 from account 101 to account 102
-- ==================================================

START TRANSACTION;

-- Deduct Rs. 500 from sender account

UPDATE Accounts
SET Balance = Balance - 500
WHERE AccountID = 101 AND Balance >= 500;

-- Add Rs. 500 to receiver account

UPDATE Accounts
SET Balance = Balance + 500
WHERE AccountID = 102;

-- Permanently save both changes

COMMIT;

-- Check updated balances

SELECT AccountID, Balance
FROM Accounts
ORDER BY AccountID;


-- ==================================================
-- STEP 5: PARTIAL ROLLBACK USING SAVEPOINT
-- Transfer Rs. 300 and cancel optional Rs. 50 fee
-- ==================================================

START TRANSACTION;

-- Deduct Rs. 300 from account 101

UPDATE Accounts
SET Balance = Balance - 300
WHERE AccountID = 101;

-- Create savepoint

SAVEPOINT after_debit;

-- Deduct optional service fee of Rs. 50

UPDATE Accounts
SET Balance = Balance - 50
WHERE AccountID = 101;

-- Undo only the service fee deduction

ROLLBACK TO SAVEPOINT after_debit;

-- Credit Rs. 300 to account 102

UPDATE Accounts
SET Balance = Balance + 300
WHERE AccountID = 102;

-- Save the transaction

COMMIT;

-- Display final balances

SELECT AccountID, Balance
FROM Accounts
ORDER BY AccountID;


-- ==================================================
-- STEP 6: SIMULATE TRANSACTION FAILURE USING ROLLBACK
-- Recipient account 999 does not exist
-- ==================================================

START TRANSACTION;

-- Deduct Rs. 200 from account 101

UPDATE Accounts
SET Balance = Balance - 200
WHERE AccountID = 101 AND Balance >= 200;

-- Attempt to credit invalid account 999

UPDATE Accounts
SET Balance = Balance + 200
WHERE AccountID = 999;

-- Check affected rows

SELECT ROW_COUNT();

-- Since recipient account does not exist,
-- cancel the entire transaction

ROLLBACK;

-- Verify original balance is restored

SELECT AccountID, Balance
FROM Accounts
WHERE AccountID = 101;


-- ==================================================
-- STEP 7: DEMONSTRATE ISOLATION LEVELS
-- ==================================================

-- READ UNCOMMITTED

SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- READ COMMITTED

SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- REPEATABLE READ

SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- SERIALIZABLE

SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;


-- ==================================================
-- STEP 8: RESET BALANCE FOR CONCURRENCY TESTS
-- Execute when no transaction is open
-- ==================================================

UPDATE Accounts
SET Balance = 1000
WHERE AccountID = 101;


-- ==================================================
-- STEP 9: DIRTY READ DEMONSTRATION
-- TWO DIFFERENT SESSIONS ARE REQUIRED
-- ==================================================


-- SESSION A:

START TRANSACTION;

-- Update balance but do not commit

UPDATE Accounts
SET Balance = 700
WHERE AccountID = 101;

-- Keep transaction open


-- SESSION B:

-- Allow reading uncommitted data

SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

START TRANSACTION;

-- Read Session A's uncommitted balance

SELECT Balance
FROM Accounts
WHERE AccountID = 101;


-- SESSION A:

-- Cancel the uncommitted change

ROLLBACK;


-- SESSION B:

-- End the read transaction

COMMIT;


-- ==================================================
-- STEP 10: NON-REPEATABLE READ DEMONSTRATION
-- TWO DIFFERENT SESSIONS ARE REQUIRED
-- ==================================================


-- SESSION A:

SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

START TRANSACTION;

-- First read

SELECT Balance
FROM Accounts
WHERE AccountID = 101;


-- SESSION B:

-- Update the same account

UPDATE Accounts
SET Balance = 900
WHERE AccountID = 101;

-- Commit the update

COMMIT;


-- SESSION A:

-- Second read gives the newly committed value

SELECT Balance
FROM Accounts
WHERE AccountID = 101;

COMMIT;


-- ==================================================
-- STEP 11: REPEATABLE READ DEMONSTRATION
-- TWO DIFFERENT SESSIONS ARE REQUIRED
-- ==================================================


-- SESSION A:

SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;

START TRANSACTION;

-- First read

SELECT Balance
FROM Accounts
WHERE AccountID = 101;


-- SESSION B:

-- Update balance and commit

UPDATE Accounts
SET Balance = 800
WHERE AccountID = 101;

COMMIT;


-- SESSION A:

-- Second read uses the same consistent snapshot

SELECT Balance
FROM Accounts
WHERE AccountID = 101;

COMMIT;


-- ==================================================
-- STEP 12: FINAL ACCOUNT VERIFICATION
-- ==================================================

SELECT *
FROM Accounts
ORDER BY AccountID;
