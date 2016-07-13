/*
SQL Server 2005 Bible 
Paul Nielsen
Ch 53 Scalability
Table Partitoning

This requires 2 directories:
C:\SQLData
D:\SQLData
*/



------------------------------------------------------------------
-- Create Database with Primary and five additional FileGroups
-- Note: you may need to adjsut the file locations for your configuration

USE master;
GO
IF EXISTS (SELECT * FROM Sys.Databases WHERE NAME='PartitionDemo')
  DROP DATABASE PartitionDemo;

GO
/****** Object:  Database PartitionDemo    Script Date: 11/22/2005 12:23:57 ******/
CREATE DATABASE PartitionDemo ON  
  PRIMARY 
    (NAME = N'PartitionDemo', FILENAME = N'C:\SQLData\PartitionDemo.mdf' , SIZE = 10Mb , MAXSIZE = UNLIMITED, FILEGROWTH = 5Mb), 
  FILEGROUP [Part01] 
    (NAME = N'Part01', FILENAME = N'C:\SQLData\Part01.ndf' , SIZE = 10MB , MAXSIZE = UNLIMITED, FILEGROWTH = 5Mb ), 
  FILEGROUP [Part02] 
    (NAME = N'Part02', FILENAME = N'D:\SQLData\Part02.ndf' , SIZE = 10MB , MAXSIZE = UNLIMITED, FILEGROWTH = 5Mb ), 
  FILEGROUP [Part03] 
    (NAME = N'Part03', FILENAME = N'C:\SQLData\Part03.ndf' , SIZE = 10MB , MAXSIZE = UNLIMITED, FILEGROWTH = 5Mb ), 
  FILEGROUP [Part04] 
    (NAME = N'Part04', FILENAME = N'D:\SQLData\Part04.ndf' , SIZE = 10MB , MAXSIZE = UNLIMITED, FILEGROWTH = 5Mb ), 
  FILEGROUP [Part05] 
    (NAME = N'Part05', FILENAME = N'C:\SQLData\Part05.ndf' , SIZE = 10MB , MAXSIZE = UNLIMITED, FILEGROWTH = 5Mb )
  LOG ON 
    (NAME = N'PartitionDemo_log', FILENAME = N'D:\SQLData\PartitionDemo_log.ldf' , SIZE = 6Mb , MAXSIZE = 10GB , FILEGROWTH = 10%)
 COLLATE SQL_Latin1_General_CP1_CI_AS;
GO

--------------------------------------------------------------------
--- Create Partition Function


Use PartitionDemo;
GO
-- Create the Partition Function that 
-- segments the data by years
 
CREATE PARTITION FUNCTION pfYears(DateTime)
AS RANGE LEFT FOR VALUES 
('12/31/2001','12/31/2002','12/31/2003','12/31/2004');


-- alternate 
CREATE PARTITION FUNCTION pfYearsRT(DateTime)
AS RANGE RIGHT FOR VALUES 
('1/1/2002', '1/1/2003', '1/1/2004', '1/1/2005');
GO

--------------------------------------------------------------------
--- Create Partition Function

-- this scheme places all partition tables in the Primary filegroup
/*CREATE PARTITION SCHEME psYearsAll
AS PARTITION pfYearsRT
  ALL TO ([Primary]);
*/

-- This scheme separates every partition table
CREATE PARTITION SCHEME psYearsFiles
AS PARTITION pfYearsRT
  TO (Part01, Part02, Part03, Part04, Part05);


--------------------------------------------------------------------
--- Create Partition Table

CREATE 
--  drop
TABLE dbo.WorkOrder (
  WorkOrderID INT IDENTITY NOT NULL,
  ProductID INT NOT NULL,
  OrderQty INT NOT NULL,
  StockedQty INT NOT NULL,
  ScrappedQty INT NOT NULL,
  StartDate DATETIME NOT NULL,
  EndDate DATETIME NOT NULL,
  DueDate DATETIME NOT NULL,
  ScrapReasonID INT NULL,
  ModifiedDate DATETIME NOT NULL,
  CONSTRAINT WorkOrderPK PRIMARY KEY NONCLUSTERED(WorkOrderID,DueDate)
  )

CREATE CLUSTERED INDEX ix_WorkOrder_DueDate
  ON dbo.WorkOrder (DueDate)
    ON psYearsFiles(DueDate);
  
-- Import Data from Adventureworks
DECLARE @Counter INT
SET @Counter = 0 

WHILE @Counter < 1--00
BEGIN 
  SET @Counter = @Counter + 1
  INSERT dbo.WorkOrder (ProductID, OrderQty, StockedQty, ScrappedQty, StartDate, EndDate, 
     DueDate, ScrapReasonID, ModifiedDate)
    SELECT ProductID, OrderQty, StockedQty, ScrappedQty, StartDate, EndDate, 
     DueDate, ScrapReasonID, ModifiedDate
    FROM AdventureWorks.Production.WorkOrder;
END

Select Count(*) from WorkOrder

------------------------------------------------
-- Querying Partition Tables

SELECT $PARTITION.pfYearsRT(DueDate) AS Partition, 
    COUNT(*) AS [COUNT] FROM WorkOrder 
  GROUP BY $PARTITION.pfYearsRT(DueDate)
  ORDER BY Partition
GO


SELECT WorkOrderID,ProductID, OrderQty, StockedQty, ScrappedQty 
  FROM dbo.WorkOrder
  WHERE year(DueDate) = '2002'


SELECT WorkOrderID,ProductID, OrderQty, StockedQty, ScrappedQty 
  FROM dbo.WorkOrder
  WHERE DueDate BETWEEN '20020101' AND '20021231'


SELECT WorkOrderID 
  FROM dbo.WorkOrder
  WHERE $PARTITION.pfYearsRT(DueDate) = 2


------------------------------------------------
-- Modifying Partition Tables

-- Merging Partitions
ALTER PARTITION FUNCTION pfYearsRT()
  MERGE RANGE ('1/1/2004')


-- Spliting Partitions
SELECT Count(*), Year(DueDate), Month(DueDate)
  FROM dbo.WorkOrder
  GROUP BY Year(DueDate), Month(DueDate) 
  ORDER BY Year(DueDate), Month(DueDate) 

ALTER PARTITION SCHEME psYearsFiles
  NEXT USED [Primary]

ALTER PARTITION FUNCTION pfYearsRT()
  SPLIT RANGE ('7/1/2004')


------------------------------------------------
-- Switching Tables


-- create the new table
CREATE TABLE dbo.WorkOrderNEW (
  WorkOrderID INT IDENTITY NOT NULL,
  ProductID INT NOT NULL,
  OrderQty INT NOT NULL,
  StockedQty INT NOT NULL,
  ScrappedQty INT NOT NULL,
  StartDate DATETIME NOT NULL,
  EndDate DATETIME NOT NULL,
  DueDate DATETIME NOT NULL,
  ScrapReasonID INT NULL,
  ModifiedDate DATETIME NOT NULL
  )
  ON Part05

ALTER TABLE dbo.WorkOrderNEW
  ADD CONSTRAINT WorkOrderNEWPK 
  PRIMARY KEY NONCLUSTERED (WorkOrderID, DueDate)

go
CREATE CLUSTERED INDEX ix_WorkOrder_DueDate
  ON dbo.WorkOrderNEW (DueDate)

go 
-- add the constraint
ALTER TABLE dbo.WorkOrderNEW
  ADD CONSTRAINT ckWONewPT
    CHECK (DueDate BETWEEN '8/1/2004' AND '8/31/2004')
go
-- Insert the data from Jan 2004 convereted to Aug 2004
INSERT dbo.WorkOrderNEW (ProductID, OrderQty, StockedQty, ScrappedQty, 
    StartDate, EndDate, DueDate, ScrapReasonID, ModifiedDate)
  SELECT 
      ProductID, OrderQty, StockedQty, ScrappedQty, 
      DATEADD(mm,7,StartDate), DATEADD(mm,7,EndDate), 
      DATEADD(mm,7,DueDate), ScrapReasonID, DATEADD(mm,7,ModifiedDate)
    FROM AdventureWorks.Production.WorkOrder
    WHERE DueDate BETWEEN '1/1/2004' and '1/31/2004';

SELECT * FROM WorkOrderNEW

SELECT boundary_id , name, value
  FROM sys.partition_functions pf
    JOIN sys.partition_range_values prf
       ON pf.function_id = prf.function_id

-- modify the workorderPK so it too is partitioned. 
ALTER TABLE dbo.WorkOrder
  DROP CONSTRAINT WorkOrderPK

ALTER TABLE dbo.WorkOrder
  ADD CONSTRAINT WorkOrderPK 
  PRIMARY KEY NONCLUSTERED (WorkOrderID,DueDate)
    ON psYearsFiles(DueDate);

-- Create a new empty partiton in WorkOrder

ALTER PARTITION SCHEME psYearsFiles
  NEXT USED [Part05]

ALTER PARTITION FUNCTION pfYearsRT()
  SPLIT RANGE ('8/1/2004')
 
-- Perform the Switch 
ALTER TABLE WorkOrderNEW
  SWITCH TO WorkOrder PARTITION 5

 
------------------------------------------------
-- Indexing Partition Tables
CREATE INDEX WorkOrder_ProductID
  ON dbo.WorkOrder (ProductID, DueDate)
    ON psYearsFiles(DueDate);

SELECT * 
  FROM WorkOrder
  WHERE ProductID = 519

------------------------------------------------
-- Maintaining Partitioned Indexes

ALTER INDEX WorkOrder_ProductID
  ON dbo.WorkOrder
  REBUILD
  PARTITION = 5 
   

--------------------------------------------------
-- Removing Partitioning

/*
-- drop the clustered index
DROP INDEX ix_WorkOrder_DueDate 
  ON dbo.Workorder
  WITH (MOVE TO [Primary])
*/


-------------------------------------------------
-------------------------------------------------
-- Indexed Views 

USE OBXKites;

SET ANSI_Nulls ON;
SET ANSI_Padding ON;
SET ANSI_Warnings ON;
SET ArithAbort ON;
SET Concat_Null_Yields_Null ON;
SET Quoted_Identifier ON;
SET Numeric_RoundAbort OFF;

GO

CREATE VIEW vContactOrder
WITH SCHEMABINDING
AS
SELECT c.ContactID, o.OrderID
  FROM dbo.Contact as c
    JOIN dbo.[Order] as o
      ON c.ContactID = o.ContactID;
 GO

SELECT Contact.ContactID, OrderID 
  FROM dbo.Contact
    JOIN dbo.[Order]
      ON Contact.ContactID = [Order].ContactID
   
CREATE UNIQUE CLUSTERED INDEX ivContactOrder ON vContactOrder
  (ContactID, OrderID);

SELECT Contact.ContactID, OrderID 
  FROM dbo.Contact
    JOIN dbo.[Order]
      ON Contact.ContactID = [Order].ContactID






