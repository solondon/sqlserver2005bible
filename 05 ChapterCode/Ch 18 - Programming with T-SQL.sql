-----------------------------------------------------------
-- Total Training for SQL Server 2005
-- 
-- Part 2 - Selecting Data
-- Lesson 8 - Modifying Data
-- 
-- Paul Nielsen 
-----------------------------------------------------------

-----------------------------------------------------------
-- Transact-SQL Fundamentals

-- Switching Databases
USE Family;

-- Executing a Stored Procedure
sp_help;
EXEC sp_help;


-- ANSI Style Comments
Select FirstName, LastName      -- selects the columns
  FROM Person                       -- the source table
  Where LastName Like 'Hal%';  -- the row restriction

-- C style comments
/* 
Order table Insert Trigger
Paul Nielsen
ver 1.0 July 21, 2006
Logic: etc. 
ver 1.1: July 31, 2006, added xyz
*/

-- Debug Commands
Select 3;
Print 6;

Print 'Begining'; 
waitfor delay '00:00:02';
Print 'Done'; 

-------------------------------------------------
-- Variables

-- Variable Default and Scope
DECLARE  @Test INT,
         @TestTwo NVARCHAR(25);
SELECT @Test, @TestTwo ;

SET @Test = 1;
SET @TestTwo = 'a value';
SELECT @Test, @TestTwo; 
go --terminates the variables

SELECT @Test as BatchTwo, @TestTwo;  

-- Using the Set and Select Commands
USE Family

-- multiple rows & multiple columns
Declare @TempID INT,
           @TempLastName VARCHAR(25);
SET @TempID = 99
SELECT @TempID = PersonID,
    @TempLastName = LastName
  FROM Person 
  ORDER BY PersonID
SELECT @TempID, @TempLastName;
  
-- No rows returned
Declare @TempID INT,
           @TempLastName VARCHAR(25);
SET @TempID = 99;
SELECT @TempID = PersonID,
    @TempLastName = LastName
  FROM Person 
  WHERE PersonID = 100
  ORDER BY PersonID;
SELECT @TempID, @TempLastName;


-- Using Variables Within SQL Queries

USE OBXKites;

DECLARE @ProductCode CHAR(10);
SET @ProductCode = '1001';

SELECT ProductName 
  FROM Product
  WHERE Code = @ProductCode;

-- Multiple Assignment Variables

USE CHA2
DECLARE 
  @EventDates VARCHAR(1024)
SET @EventDates = ''

SELECT @EventDates = @EventDates 
  + CONVERT(VARCHAR(15), a.d,107 ) + ';  ' 
      FROM (select DateBegin as [d] 
              from Event 
                join Tour
                  on Event.TourID = Tour.TourID
        WHERE Tour.[Name] = 'Outer Banks Lighthouses') as a; 

SELECT Left(@EventDates, Len(@EventDates)-1) 
  AS 'Outer Banks Lighthouses Events'; 

 
---------------------------------------------------------
-- Procedural Flow

-- If 
IF 1 = 0
  PRINT 'Line One';
PRINT 'Line Two';

-- If w/ begin/end block
IF 1 = 0
  BEGIN
    PRINT 'Line One';
    PRINT 'Line Two';
  END 


-- IF Exists()
USE OBXKITES;
IF EXISTS(SELECT * FROM [ORDER] WHERE Closed = 0)
  BEGIN;
    PRINT 'Process Orders';
  END;

-- While
DECLARE @Temp int;
SET @Temp = 0;

WHILE @Temp <3
  BEGIN;
    PRINT 'tested condition' + Str(@Temp);
    SET @Temp = @Temp + 1;
  END;

-- goto
GOTO ErrorHandler;
PRINT 'more code';
ErrorHandler:; 
PRINT 'Logging the error'; 

-----------------------------------------------------
-- Examining SQL Server with Code

-- sp_help
USE OBXKites;
sp_help price;

-- Global Variables 
Select @@Connections;	
Select @@CPU_Busy;	
Select @@Cursor_Rows;	
Select @@DateFirst;	
Select @@DBTS;	
Select @@Error;	
Select @@Fetch_Status;	
Select @@Identity;	
Select @@Idle;	
Select @@IO_Busy;	
Select @@LangID;	
Select @@Language;	
Select @@Lock_TimeOut;	
Select @@Max_Connections;	
Select @@Max_Precision;	
Select @@Nestlevel;	
Select @@Options;	
Select @@Pack_Received;	
Select @@Pack_Sent;	
Select @@Packet_Errors;	
Select @@ProcID;	
Select @@RemServer;	
Select @@RowCount;	
Select @@ServerName;	
Select @@ServiceName;	
Select @@SPID;	
Select @@TextSize;	
Select @@TimeTicks;	
Select @@Total_Errors;	
Select @@Total_Read;	
Select @@Total_Write;	
Select @@TranCount;	
Select @@Version;	

---------------------------------------------------
-- Temporary Tables and Table Variables

-- Local Temporary Tables
CREATE TABLE #ProductTemp (
  ProductID INT PRIMARY KEY
  );

SELECT Name 
  FROM TempDB.dbo.SysObjects
  WHERE Name Like '#Pro%'

-- Global Temporary Tables
IF NOT EXISTS(
  SELECT * FROM Tempdb.dbo.Sysobjects 
    WHERE Name = '##TempWork')
CREATE TABLE ##TempWork(
  PK INT,
  Col1 INT
);

-- Table Variables
DECLARE @WorkTable TABLE (
  PK INT PRIMARY KEY,
  Col1 INT NOT NULL);

INSERT INTO @WorkTable (PK, Col1)
  VALUES ( 1, 101);

SELECT PK, Col1 
  FROM @WorkTable;


----------------------------------------------------------------
-- Using Dynamic SQL 

-- Executing Dynamic SQL
USE Family;
EXEC ('Select LastName from Person Where PersonID = 12');

-- sp_executeSQL
EXEC sp_executeSQL 
  N'Select LastName from Person Where PersonID = @PersonSelect',
  N'@PersonSelect INT', 
  @PersonSelect = 12;

-- Developing Dynamic SQL Code 
USE OBXKites;

DECLARE 
  @SQL NVARCHAR(1024),
  @SQLWhere NVARCHAR(1024),
  @NeedsAnd BIT, 

-- User Parameters
  @ProductName VARCHAR(50),
  @ProductCode VARCHAR(10),
  @ProductCategory VARCHAR(50);

-- Initilize Variables
SET @NeedsAnd = 0; 
SET @SQLWhere = '';

-- Simulate User's Requirements
SET @ProductName = NULL;
SET @ProductCode = 1001;
SET @ProductCategory = NULL;

-- Assembly Dynamic SQL 

-- Set up initial SQL Select
IF @ProductCategory IS NULL 
  SET @SQL = 'Select ProductName from Product';
ELSE
  SET @SQL = 'Select ProductName from Product 
                        Join ProductCategory 
                        on Product.ProductCategoryID 
                        = ProductCategory.ProductCategoryID';

-- Build the Dynamic Where Clause
IF @ProductName IS NOT NULL 
  BEGIN;
    SET @SQLWhere = 'ProductName = ' + @ProductName;
    SET @NeedsAnd = 1;
  END;

 IF @ProductCode IS NOT NULL 
  BEGIN;
    IF @NeedsAnd = 1 
      SET @SQLWhere = @SQLWhere + ' and '; 
    SET @SQLWhere = 'Code = ' + @ProductCode;
    SET @NeedsAnd = 1;
  END;

 IF @ProductCategory IS NOT NULL
  BEGIN;
    IF @NeedsAnd = 1 
      SET @SQLWhere = @SQLWhere + ' and '; 
    SET @SQLWhere = 'ProductCategory = ' + @ProductCategory ;
    SET @NeedsAnd = 1;
  END;

-- Assemble the select and the where portions of the dynamic SQL 
IF @NeedsAnd = 1
  SET @SQL = @SQL + ' where ' + @SQLWhere;

Print @SQL;

EXEC sp_executeSQL @SQL 
  WITH RECOMPILE;

 


----------------------------------------------------------
-- Error Handling

-- Try...Catch

BEGIN TRY;
  SET NOCOUNT ON; 
  SELECT 'Try One';
  RAISERROR('Simulated Error', 16, 1); 
  Select 'Try Two';
END TRY 

select 'test'

BEGIN CATCH;
  SELECT 'Catch Block';
END CATCH ;
SELECT 'Try Three';






BEGIN TRY
  SET NOCOUNT ON 
  SELECT 'Try One'
  RAISERROR('Simulated Error', 16, 1) 
  Select 'Try Two'
END TRY 

BEGIN CATCH 
  SELECT 
    ERROR_MESSAGE() AS [Message],
    ERROR_PROCEDURE() AS [Procedure],
    ERROR_LINE() AS Line,
    ERROR_NUMBER() AS Number,
    ERROR_SEVERITY() AS Severity,
    ERROR_STATE() AS State

END CATCH 
SELECT 'Try Three'



-- without a catch block the functions return a null
  SELECT 
    ERROR_MESSAGE() AS [Message],
    ERROR_PROCEDURE() AS [Procedure],
    ERROR_LINE() AS Line,
    ERROR_NUMBER() AS Number,
    ERROR_SEVERITY() AS Severity,
    ERROR_STATE() AS State

 
-- Legacy @@Error Global Variable

USE Family
UPDATE Person 
  SET PersonID = 1 
  Where PersonID = 2
Print @@Error
Print @@Error

-- saving @@error to alocal variable
USE Family
DECLARE @err INT

UPDATE Person 
  SET PersonID = 1 
  Where PersonID = 2
SET @err = @@Error

IF @err <> 0 
  Begin
    -- error handling code
    Print @err
  End

-- Legacy @@RowCount Global Variable
USE FAMILY
UPDATE Person
  SET LastName = 'Johnson'
  WHERE PersonID = 100

IF @@RowCount = 0 
  Begin
    -- error handling code
    Print 'no rows affected'
  End

-- Raiserror

-- The Simple Raiserror Form  
RAISERROR 5551212  'Unable to update Customer' 

-- The Complete Raiserror Form 
RAISERROR('Unable to update Customer', 14, 1)

-- Error Severity
RAISERROR('Print', 10,1)
RAISERROR('Info', 14,1)
RAISERROR('Warning', 15,1)
RAISERROR('Critical', 16,1)

--  Adding Variable Parameters to Messag
RAISERROR ('Unable to update %s.', 14, 1, 'Customer')

-- Stored Messages
EXEC sp_addmessage 50001, 16, 'Unable to update %s'

EXEC sp_addmessage 50001, 16, 'Still unable to update %s', @Replace = 'Replace'

SELECT * 
  FROM sys.messages
  WHERE message_id > 50000

SELECT 'EXEC sp_addmessage ' 
    + Cast(message_id as VARCHAR(7)) 
    + ', ' + Cast(Severity as VARCHAR(2)) 
    + ', ''' + [text] +  ''';' 
  FROM sys.messages
  WHERE message_id > 50000

-- code test 
EXEC sp_addmessage 50001, 16, 'Still unable to update %s';

EXEC sp_dropmessage 50001

-- With Log
RAISERROR ('Unable to update %s.', 14, 1, 'Customer') 
  WITH LOG

-- T-SQL Fatal Errors
SELECT Error, Severity, Description
  FROM Master.dbo.SysMessages
  WHERE Severity > 16

