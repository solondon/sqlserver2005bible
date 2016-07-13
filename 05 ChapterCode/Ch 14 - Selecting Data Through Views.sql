-----------------------------------------------------------
-- SQL Server 2005 Bible 
-- Wiley Publishing
-- Paul Nielsen

-- Chapter 14 - Views

-----------------------------------------------------------
-----------------------------------------------------------

-----------------------------------------------------------
-- Working with Views

--  Creating Views with DDL Code
USE CHA2 -- run CHA2_Create to generate the database

IF EXISTS(SELECT * FROM SysObjects WHERE Name = 'vEventList')
  DROP VIEW dbo.vEventList

go
CREATE VIEW dbo.vEventList
AS
SELECT dbo.CustomerType.Name AS Customer,
   dbo.Customer.LastName, dbo.Customer.FirstName,
   dbo.Customer.Nickname, 
   dbo.Event_mm_Customer.ConfirmDate, dbo.Event.Code,
   dbo.Event.DateBegin, dbo.Tour.Name AS Tour,
   dbo.BaseCamp.Name, dbo.Event.Comment
   FROM dbo.Tour 
      INNER JOIN dbo.Event 
         ON dbo.Tour.TourID = dbo.Event.TourID 
      INNER JOIN dbo.Event_mm_Customer 
         ON dbo.Event.EventID = dbo.Event_mm_Customer.EventID
      INNER JOIN dbo.Customer 
         ON dbo.Event_mm_Customer.CustomerID
               = dbo.Customer.CustomerID 
      LEFT OUTER JOIN dbo.CustomerType 
         ON dbo.Customer.CustomerTypeID 
               = dbo.CustomerType.CustomerTypeID 
      INNER JOIN dbo.BaseCamp 
         ON dbo.Tour.BaseCampID = dbo.BaseCamp.BaseCampID
go

SELECT * FROM dbo.vEventList

SELECT * FROM dbo.vEventList WHERE (Code = '101') 

-- Order By and Views
go
CREATE VIEW vCapeHatterasTour
   AS
   SELECT TOP 2 [Name], BaseCampID
      FROM Tour 
      ORDER BY [Name]


SELECT *
   FROM vCapeHatterasTour
   ORDER BY [Name]
go


-- Executing Views
SELECT *
  FROM vEventList 

SELECT * FROM dbo.vEventList WHERE (EventCode = '101')

-----------------------------------------------------------
-- without Check

SELECT * FROM BaseCamp

go
IF EXISTS(SELECT * FROM SysObjects WHERE Name = 'vCapeHatterasTour')
  DROP VIEW dbo.vCapeHatterasTour

go
CREATE VIEW vCapeHatterasTour
AS
SELECT [Name], BaseCampID
	FROM Tour 
	WHERE BaseCampID = 2
go
SELECT * FROM vCapeHatterasTour

INSERT vCapeHatterasTour ([Name], BaseCampID)
   VALUES ('Blue Ridge Parkway Hike', 1)

SELECT * FROM vCapeHatterasTour

-- with check option

DELETE vCapeHatterasTour 
   WHERE [Name] = 'Blue Ridge Parkway Hike'
	
go
ALTER VIEW vCapeHatterasTour
   AS
   SELECT [Name], BaseCampID
      FROM Tour 
      WHERE BaseCampID = 2
   WITH CHECK OPTION
go

INSERT vCapeHatterasTour ([Name], BaseCampID)
   VALUES ('Blue Ridge Parkway Hike', 1)
	


-----------------------------------------------------------
-- Locking Down the View

-- Protecting the Data
ALTER VIEW dbo.vCapeHatterasTour
AS
SELECT TourName, BaseCampID
   FROM dbo.Tour 
   WHERE BaseCampID = 2
SELECT * FROM dbo.vCapeHatterasTour 



Use Tempdb
go
IF EXISTS(SELECT * FROM SysObjects WHERE Name = 'vTest')
  DROP View dbo.vTest
go
IF EXISTS(SELECT * FROM SysObjects WHERE Name = 'Test')
  DROP TABLE dbo.Test

go
CREATE TABLE Test (
   [Name] NVARCHAR(50)
   )
go

CREATE VIEW vTest
WITH SCHEMABINDING
AS
SELECT [Name] FROM dbo.Test

go
ALTER TABLE Test
   ALTER COLUMN [Name] NVARCHAR(100)


-- With Encryption 

SELECT Text 
   FROM SysComments
   JOIN SysObjects
      ON SysObjects.ID = SysComments.ID
   WHERE Name = 'vTest'
go

ALTER VIEW vTest
WITH ENCRYPTION
AS
SELECT [Name] FROM dbo.Test
go   

-----------------------------------------------------------
-- Nested Views
USE CHA2
go 

IF EXISTS(SELECT * FROM SysObjects WHERE Name = 'vEventList30days')
  DROP VIEW dbo.vEventList30days
go

CREATE VIEW dbo.vEventList30days
   AS
   SELECT dbo.vEventList.Code, LastName, FirstName 
      FROM dbo.vEventList
      JOIN dbo.Event 
         ON vEventList.Code = Event.Code
      WHERE Event.DateBegin BETWEEN GETDATE() and GETDATE() + 30

go
SELECT E.Code, LastName, FirstName 
  FROM 
   (SELECT dbo.CustomerType.Name AS Customer,
      dbo.Customer.LastName, dbo.Customer.FirstName,
      dbo.Customer.Nickname, 
      dbo.Event_mm_Customer.ConfirmDate, dbo.Event.Code,
      dbo.Event.DateBegin, dbo.Tour.Name AS Tour,
      dbo.BaseCamp.Name AS BaseCamp, dbo.Event.Comment
    FROM dbo.Tour 
      INNER JOIN dbo.Event 
        ON dbo.Tour.TourID = dbo.Event.TourID 
      INNER JOIN dbo.Event_mm_Customer 
        ON dbo.Event.EventID = dbo.Event_mm_Customer.EventID
      INNER JOIN dbo.Customer 
        ON dbo.Event_mm_Customer.CustomerID
            = dbo.Customer.CustomerID 
      LEFT OUTER JOIN dbo.CustomerType 
        ON dbo.Customer.CustomerTypeID 
            = dbo.CustomerType.CustomerTypeID 
      INNER JOIN dbo.BaseCamp 
        ON dbo.Tour.BaseCampID = dbo.BaseCamp.BaseCampID
      ) E

      JOIN dbo.Event 
         ON E.Code = Event.Code
      WHERE Event.DateBegin BETWEEN GETDATE() and GETDATE() + 30


-----------------------------------------------------------
-- Performance


DECLARE @pCounter INT

SET @pCounter = 0

WHILE @pCounter < 10
BEGIN  
  SET @pCounter = @pCounter + 1
  DBCC FREEPROCCACHE
  DBCC DROPCLEANBUFFERS
  SELECT * FROM vEventlist
END 

-- Using Profiler the average execution time was 63.2 ms 


go
IF EXISTS(SELECT * FROM SysObjects WHERE Name = 'pGetEventList')
  DROP PROC dbo.pGetEventList
go


CREATE PROC pGetEventList
AS
SET NOCOUNT ON
SELECT dbo.CustomerType.Name,
   dbo.Customer.LastName, dbo.Customer.FirstName,
   dbo.Customer.Nickname, 
   dbo.Event_mm_Customer.ConfirmDate, dbo.Event.Code,
   dbo.Event.DateBegin, dbo.Tour.Name,
   dbo.BaseCamp.Name, dbo.Event.Comment
   FROM dbo.Tour 
      INNER JOIN dbo.Event 
         ON dbo.Tour.TourID = dbo.Event.TourID 
      INNER JOIN dbo.Event_mm_Customer 
         ON dbo.Event.EventID = dbo.Event_mm_Customer.EventID
      INNER JOIN dbo.Customer 
         ON dbo.Event_mm_Customer.CustomerID
               = dbo.Customer.CustomerID 
      LEFT OUTER JOIN dbo.CustomerType 
         ON dbo.Customer.CustomerTypeID 
               = dbo.CustomerType.CustomerTypeID 
      INNER JOIN dbo.BaseCamp 
         ON dbo.Tour.BaseCampID = dbo.BaseCamp.BaseCampID
go

SP_SQLEXEC pGetEventList


DECLARE @pCounter INT

SET @pCounter = 0

WHILE @pCounter < 100
BEGIN  
  SET @pCounter = @pCounter + 1
  DBCC FREEPROCCACHE
  DBCC DROPCLEANBUFFERS
  EXEC SP_SQLEXEC pGetEventList
END

-- Using Profiler the average execution time was 50.65 ms 


DECLARE @pCounter INT

SET @pCounter = 0

WHILE @pCounter < 90
BEGIN  
  SET @pCounter = @pCounter + 1
SELECT dbo.CustomerType.Name,
   dbo.Customer.LastName, dbo.Customer.FirstName,
   dbo.Customer.Nickname, 
   dbo.Event_mm_Customer.ConfirmDate, dbo.Event.Code,
   dbo.Event.DateBegin, dbo.Tour.Name,
   dbo.BaseCamp.Name, dbo.Event.Comment
   FROM dbo.Tour 
      INNER JOIN dbo.Event 
         ON dbo.Tour.TourID = dbo.Event.TourID 
      INNER JOIN dbo.Event_mm_Customer 
         ON dbo.Event.EventID = dbo.Event_mm_Customer.EventID
      INNER JOIN dbo.Customer 
         ON dbo.Event_mm_Customer.CustomerID
               = dbo.Customer.CustomerID 
      LEFT OUTER JOIN dbo.CustomerType 
         ON dbo.Customer.CustomerTypeID 
               = dbo.CustomerType.CustomerTypeID 
      INNER JOIN dbo.BaseCamp 
         ON dbo.Tour.BaseCampID = dbo.BaseCamp.BaseCampID
  DBCC FREEPROCCACHE
  DBCC DROPCLEANBUFFERS
END

-- Using Profiler the average execution time was 115.35 ms 


DBCC FREEPROCCACHE
DBCC DROPCLEANBUFFERS

Update Trace set statement = textdata


Select statement, min(duration), Avg(duration), max(duration) from trace group by statement having count(*) = 100



SELECT * FROM vEventlist  	      72,734
EXEC SP_SQLEXEC pGetEventList  	98,568

 SELECT dbo.CustomerType.Name,     dbo.Customer.LastName, dbo.Customer.FirstName,     dbo.Customer.Nickname,      dbo.Event_mm_Customer.ConfirmDate, dbo.Event.Code,     dbo.Event.DateBegin, dbo.Tour.Name,     dbo.BaseCamp.Name, dbo.Event.Comment     FROM dbo.Tour         INNER JOIN dbo.Event            ON dbo.Tour.TourID = dbo.Event.TourID         INNER JOIN dbo.Event_mm_Customer            ON dbo.Event.EventID = dbo.Event_mm_Customer.EventID        INNER JOIN dbo.Customer            ON dbo.Event_mm_Customer.CustomerID                 = dbo.Customer.CustomerID         LEFT OUTER JOIN dbo.CustomerType            ON dbo.Customer.CustomerTypeID                  = dbo.CustomerType.CustomerTypeID         INNER JOIN dbo.BaseCamp            ON dbo.Tour.BaseCampID = dbo.BaseCamp.BaseCampID    	
                                   463,574

