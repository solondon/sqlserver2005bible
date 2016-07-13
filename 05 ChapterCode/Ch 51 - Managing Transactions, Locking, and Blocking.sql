-----------------------------------------------------------
-- SQL Server 2005 Bible 
-- Wiley Publishing 
-- Paul Nielsen

-- Chapter  51 - Transactions, Locking and Blocking

-----------------------------------------------------------
-----------------------------------------------------------

--------------------------------------------
-- Transactional Basics

USE CHA2;
SET Implicit_Transactions ON;
UPDATE CUSTOMER
  SET Nickname  = 'Nicky'
  WHERE CustomerID = 10;

COMMIT TRANSACTION;




-------------------------------------------
-- Dirty Read Transactional Fault
 
-- Transaction 1
USE CHA2
 
go
BEGIN TRANSACTION
  UPDATE Customer 
    SET Nickname = 'Transaction Fault'
    WHERE CustomerID = 1

-- Transaction 2
SET TRANSACTION ISOLATION LEVEL 
  READ UNCOMMITTED 
USE CHA2
SELECT NickName 
  FROM Customer
  WHERE CustomerID = 1


-- Transaction 1
COMMIT TRANSACTION

 
go

--------------------------------------------
-- Non-Repeatable Read Transactional Fault

-- Transaction 1
BEGIN TRANSACTION
SET TRANSACTION ISOLATION LEVEL 
  READ COMMITTED 
USE CHA2
SELECT NickName 
  FROM Customer
  WHERE CustomerID = 1

-- Transaction 2
USE CHA2
BEGIN TRANSACTION
  UPDATE Customer 
    SET Nickname = 'Transaction Fault'
    WHERE CustomerID = 1
COMMIT TRANSACTION

-- Transaction 3
USE CHA2
SELECT NickName 
  FROM Customer
  WHERE CustomerID = 1

COMMIT TRANSACTION


--------------------------------------------
-- Phantom Row Transactional Fault

-- Transaction 2
BEGIN TRANSACTION
  USE CHA2
  SELECT CustomerID, LastName 
    FROM Customer
    WHERE NickName = 'Missy'

-- Transaction 1
USE CHA2
BEGIN TRANSACTION
  UPDATE Customer 
    SET NickName = 'Missy'
    WHERE CustomerID = 3
--COMMIT TRANSACTION

-- Transaction 2
  USE CHA2
  SELECT CustomerID, LastName 
    FROM Customer
    WHERE NickName = 'Missy'

COMMIT TRANSACTION


--------------------------------------------------
-- Transaction Log sequence 

-- Reset the data 



-- The test transaction

USE OBXKites;
BEGIN TRANSACTION;

UPDATE Product
  SET ProductDescription = 'Transaction Log Test A',
      DiscontinueDate = '12/31/2003'
  WHERE Code = '1001';

UPDATE Product
  SET ProductDescription = 'Transaction Log Test B',
      DiscontinueDate = '4/1/2003'
  WHERE Code = '1002';        


COMMIT TRANSACTION

ROLLBACK TRANSACTION

Select ProductDescription from Product where Code = '1001'

-------------------------------------------------
-- Controlling SQL Server Locking

BEGIN TRANSACTION

UPDATE Product
  SET DiscountinueDate = '7/4/2003'
  WHERE ProductCode = '1001'

Select @@SPID
exec sp_getlocks

COMMIT TRANSACTION

------------------------------------------------
-- Snapshot Isolation

USE Aesop;

ALTER DATABASE Aesop
SET ALLOW_SNAPSHOT_ISOLATION ON 

-- Transaction 1
SET TRANSACTION ISOLATION LEVEL Snapshot;

BEGIN TRAN
SELECT Title 
  FROM FABLE 
  WHERE FableID = 2
            --
SELECT Title 
  FROM FABLE 
  WHERE FableID = 2

-- Transaction 2

USE Aesop;
SET TRANSACTION ISOLATION LEVEL Snapshot;

BEGIN TRAN

UPDATE Fable
  SET Title = 'Rocking with Snapshots'
  WHERE FableID = 2;

SELECT * FROM FABLE WHERE FableID = 2

-- Using Read Committed Snapshot Isolation
ALTER DATABASE Aesop 
  SET READ_COMMITTED_SNAPSHOT ON


-- Using Locking Hints
USE OBXKites
UPDATE Product 
  FROM Product WITH (RowLock)
  SET ProductName = ProductName + ' Updated'

-- Index-Level Locking Restrictions
EXEC sp_indexoption
   'ProductCategory.PK__ProductCategory__79A81403',
   'AllowRowlocks', FALSE 
EXEC sp_indexoption
   'ProductCategory.PK__ProductCategory__79A81403',
   'AllowPagelocks', FALSE 


-- Controlling Lock Timeouts
SET Lock_Timeout 2000

-- Application Locks
DECLARE @ShareOK INT 
EXEC @ShareOK = sp_GetAppLock 
                  @Resource = 'CableWorm', 
                  @LockMode = 'Exclusive'
IF @ShareOK < 0 
   …Error handling code
  
 … code …

EXEC sp_ReleaseAppLock @Resource = 'CableWorm'
Go

Sp_Lock

--------------------------------------------------
-- DeadLocks! 

--Transaction 1
-- Step 1
Use OBXKites
Begin Tran
  Update Contact
    Set LastName = 'Jorgenson2'
    Where ContactCode = '101'

--Transaction 2
--Step 2
Use OBXKites
Begin Tran
  Update Product
    Set ProductName 
       = 'DeadLock Repair Kit'
    Where Code = '1001'
  Update Contact
    Set FirstName = 'Neals'
    Where ContactCode = '101'
Commit

--Transaction 1
-- Step 3 
Update Product
	Set ProductName = 'DeadLock Identification Tester'
	Where Code = '1001'

COMMIT


---------------------------------------------
-- Deadlock with error handling

Use OBXKites
TranStart:

Begin Tran

  Update Contact
    Set LastName = '2Jorgenson2'
    Where ContactCode = '101'

WaitFor Delay '00:00:05'

  Update Product
    Set ProductName = '2DeadLock Identification Tester'
    Where ProductCode = '1001'
    IF @@ERROR = 1205 
      BEGIN
         PRINT 'Deadlock'
         GOTO TranStart        
       END

COMMIT


------------------------------------------
-- Application Locking Design

-- Preventing Lost Updates
SELECT RowVersion, ProductName
  FROM Product
  WHERE ProductCode = '1001'

UPDATE Product 
  SET ProductName = 'Joe''s Update'
  WHERE ProductCode = '1001'
    AND RowVersion = 0x0000000000000077
  
UPDATE Product 
  SET ProductName = 'Sue''s Update'
  WHERE ProductCode = '1001'
    AND RowVersion = 0x00000000000000B9

SELECT @@ROWCOUNT














USE Tempdb

CREATE TABLE Locks (
  LockID INT IDENTITY NOT NULL PRIMARY KEY, 
  Col1 INT, 
  Col2 INT
  )
Truncate table locks

INSERT Locks( Col1, Col2) VALUES (3, 6)

DECLARE @Counter INT
SET @Counter = 0
WHILE @Counter < 15
  BEGIN
  SET @Counter = @Counter + 1
  INSERT Locks( Col1, Col2) SELECT col1 / 2, col2 * 2 FROM Locks
  END 

SELECT count(*) FROM Locks