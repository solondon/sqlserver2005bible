-----------------------------------------------------------
-- SQL Server 2005 Bible 
-- Wiley Publishing  
-- Paul Nielsen

-- Chapter 50 - Tuning Queries with Indexes

-----------------------------------------------------------
-----------------------------------------------------------

------------------------------------------------
-- Creating Indexes

USE OBXKites

CREATE NONCLUSTERED INDEX IxOrderNumber
  ON dbo.[Order] (OrderNumber)

CREATE CLUSTERED INDEX IxOrderID
  ON dbo.OrderDetail (OrderID)

DROP INDEX OrderDetail.IxOrderID 

-- Composite Indexes
USE CHA2
CREATE CLUSTERED INDEX IxGuideName 
  ON dbo.Guide (LastName, FirstName)

-- Covering Indexes
CREATE NONCLUSTERED INDEX IxOrderNumber
  ON dbo.[Order] (OrderNumber)
  INCLUDE (OrderDate);

-- Unique Index
USE OBXKites
CREATE UNIQUE INDEX OrderNumber 
  ON [Order] (OrderNumber)

-- Index Fill Factor and Index Pad
CREATE NONCLUSTERED INDEX IxOrderNumber
  ON dbo.[Order] (OrderNumber)
  WITH FILLFACTOR = 85, PAD_INDEX

-- Ignore Duplicate Key
DROP INDEX [Order].OrderNumber
CREATE UNIQUE INDEX OrderNumber 
  ON [Order] (OrderNumber)
  WITH IGNORE_DUP_KEY

-- Index Selectivity
Use CHA2
exec sp_help Customer

DBCC Show_Statistics (Customer, IxCustomerName)

-- Disabling an Index 
ALTER INDEX [IxContact] ON [dbo].[Contact] DISABLE

ALTER INDEX [PK__Contact__0BC6C43E] 
  ON [dbo].[Contact] 
  REBUILD WITH 
  ( PAD_INDEX  = OFF, 
    STATISTICS_NORECOMPUTE  = OFF, 
    ALLOW_ROW_LOCKS  = ON, 
    ALLOW_PAGE_LOCKS  = ON, 
    SORT_IN_TEMPDB = OFF, 
    ONLINE = OFF )

--------------------------------------------------
-- Index Tuning 

SET STATISTICS TIME ON;
USE Adventureworks;
SELECT WorkOrderID
  FROM Production.WorkOrder
  ORDER BY StartDate;

CREATE INDEX WOStartDate ON Production.WorkOrder (StartDate);

USE OBXKites;
SELECT LastName, FirstName, ProductName
  FROM dbo.Contact
    JOIN dbo.[Order] 
      ON Contact.ContactID = [Order].ContactID
    JOIN dbo.OrderDetail
      ON [Order].OrderID = OrderDetail.OrderID
    JOIN dbo.Product
      ON OrderDetail.ProductID = Product.ProductID
    JOIN dbo.ProductCategory
      ON Product.ProductCategoryID = ProductCategory.ProductCategoryID
  WHERE ProductCategoryName = 'Kite'
  ORDER BY LastName, FirstName;

-- Index Selectivity
Use CHA2
DBCC Show_Statistics (Customer, IxCustomerName)

-------------------------------
-- Reusing Query Execution Plans

DBCC FREEPROCCACHE

SELECT LastName
  FROM dbo.Contact

SELECT cast(C.sql as Char(35)) as StoredProcedure,
    cacheobjtype,  usecounts as Count
  FROM Master.dbo.syscacheobjects C
  JOIN  Master.dbo.sysdatabases D
    ON C.dbid = C.dbid
  WHERE D.Name = DB_Name() 
    AND ObjType = 'Adhoc'
  ORDER BY StoredProcedure















