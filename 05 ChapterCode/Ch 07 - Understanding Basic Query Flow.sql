-----------------------------------------------------------
-- SQL Server 2005 Bible 
-- Wiley Publishing 
-- Paul Nielsen

-- Chapter 07 - Understanding Basic Query Flow


-----------------------------------------------------------
-- Understanding Query Flow

-- A Graphical View of the Query Statement
-- (turn on: Menu - Query/ Show Execution Plan (Ctlr-M))
SELECT LastName, FirstName, Qualifications
  FROM Guide
  WHERE Qualifications LIKE '%first aid%'
  ORDER BY LastName, FirstName

-----------------------------------------------------------
-- From Clause Data Sources

-- Named Ranges

-- From Table [AS] Range Variable
USE CHA2
SELECT G.lastName, G.FirstName
  FROM Guide AS G;

-- [Table Name]
USE OBXKites
SELECT OrderID, OrderDate
  FROM [Order];

USE Northwind
SELECT OrderID, ProductID, Quantity
  FROM [Order Details];

-----------------------------------------------------------
-- Where Conditions

-- Using the Between Search Condition
USE CHA2

SELECT EventCode, DateBegin
  FROM dbo.Event
  WHERE DateBegin BETWEEN '07/01/01' AND '07/31/01';

CREATE TABLE dbo.DateTest(
  PK INT IDENTITY,
  OrderDate DATETIME
  )
go
INSERT dbo.DateTest(OrderDate)
  VALUES('1/1/01 00:00')
INSERT dbo.DateTest(OrderDate)
  VALUES('1/1/01 23:59')
INSERT dbo.DateTest(OrderDate)
  VALUES('1/1/01 11:59:59.995 pm')
INSERT dbo.DateTest(OrderDate)
  VALUES('1/2/01');

SELECT * 
  FROM dbo.DateTest
  WHERE OrderDate BETWEEN '1/1/1' AND '1/1/1 11:59:59.999 PM';

DROP TABLE DateTest;

---
USE Family
SELECT Person.FirstName + ' ' +  Person.LastName AS Mother, 
   Convert(Char(12), Marriage.DateOfWedding, 107) as Wedding,
   Child.FirstName + ' ' + Child.LastName as Child, 
   Convert(Char(12), Child.DateOfBirth, 107) as Birth
  FROM Person
    JOIN Marriage
      ON Person.PersonID = Marriage.WifeID
    JOIN Person Child
      ON Person.PersonID = Child.MotherID
   WHERE Child.DateOfBirth 
      BETWEEN Marriage.DateOfWedding 
        AND DATEADD(mm, 9, Marriage.DateOfWedding);

-- Using the In Search Condition
USE CHA2
SELECT BaseCampname 
  FROM dbo.BaseCamp
  WHERE Region IN ('NC', 'WV');

USE CHA2
SELECT BaseCampname 
  FROM dbo.BaseCamp
  WHERE Region = 'NC'
    OR Region = 'WV';

USE CHA2
SELECT BaseCampname 
  FROM dbo.BaseCamp
  WHERE Region NOT IN ('NC', 'SC');

SELECT 'IN' WHERE 'A' NOT IN ('B',NULL)

-- Using the Like Search Condition
USE OBXKites

SELECT ProductName 
  FROM dbo.Product 
  WHERE ProductName LIKE 'Air%';

SELECT ProductName 
  FROM Product 
  WHERE ProductName LIKE  '[a-d]%'; 

SELECT ProductCode, ProductName 
  FROM Product 
  WHERE ProductName LIKE '%F[-]15%';

SELECT ProductCode, ProductName 
  FROM Product 
  WHERE ProductName LIKE '%F&-15%' ESCAPE '&';

-- Multiple Where Conditions 
SELECT ProductCode, ProductName 
  FROM dbo.Product 
  WHERE 
      ProductName LIKE  'Air%' 
    OR 
      ProductCode BETWEEN '1018' AND '1020'
    AND 
      ProductName LIKE '%G%';

SELECT ProductCode, ProductName 
  FROM Product 
  WHERE 
     (ProductName LIKE  'Air%' 
    OR 
      ProductCode between '1018' AND '1020') 
    AND 
      ProductName LIKE '%G%';

-- Select...Where
SELECT 'abc' ;

SELECT 'abc' WHERE 1>0;

DECLARE @test NVARCHAR(15) ;
SET @test = 'z';
SELECT @test = 'abc' WHERE 1<0;
SELECT @test;

DECLARE @test NVARCHAR(15);
SET @test = 'z';
IF 1<0
  SELECT @test = 'abc';
SELECT @test; 

-----------------------------------------------------------
-- Ordering the Result Set

-- Specifying the Order by Using Column Names
USE CHA2

SELECT FirstName, LastName
  FROM dbo.Customer
  ORDER BY LastName, FirstName;

-- Specifying the Order by Using Expressions
SELECT LastName + ', ' + FirstName
  FROM dbo.Customer
  ORDER BY LastName + ', ' + FirstName;

USE Aesop;
SELECT Title, Len(FableText) AS TextLength
  FROM Fable 
  ORDER BY 
    CASE 
      WHEN SubString(Title, 1,3) = 'The'  
        THEN SubString(Title, 5, Len(Title)-4)
      ELSE Title
    END;

-- Specifying the Order by Using Column Aliases
SELECT LastName + ', ' + FirstName as FullName
  FROM dbo.Customer
  ORDER BY FullName DESC

-- Specifying the Order by Using Column Ordinal Position

SELECT LastName + ', ' + FirstName AS FullName
  FROM dbo.Customer
  ORDER BY 1

-- Order by and Collation
SELECT * FROM ::fn_helpcollations() 

SELECT SERVERPROPERTY('Collation') AS ServerCollation

ALTER DATABASE Family
  COLLATE SQL_Latin1_General_CP1_CS_AS
SELECT DATABASEPROPERTYEX(Family,'Collation')
  AS DatabaseCollation

SELECT * 
  FROM dbo.Product 
  ORDER BY ProductName 
    COLLATE Danish_Norwegian_CI_AI

-----------------------------------------------------------
-- Select Distinct
SELECT ALL TourName
  FROM Event
    JOIN Tour 
      ON Event.TourID = Tour.TourID

SELECT DISTINCT TourName
  FROM Event
    JOIN Tour 
      ON Event.TourID = Tour.TourID

-----------------------------------------------------------
-- Ranking

-- Top
SELECT TOP 3 PERCENT Code, ProductName, Price, 
    CONVERT(VARCHAR(10),EffectiveDate,1) AS PriceDate
  FROM Product
    JOIN Price ON Product.ProductID = Price.ProductID
  ORDER BY Price DESC

SELECT TOP 3 Code, ProductName, Price, 
    CONVERT(VARCHAR(10),EffectiveDate,1) AS PriceDate
  FROM Product
    JOIN Price ON Product.ProductID = Price.ProductID
  ORDER BY Price

-- The With Ties Option
SELECT TOP 3 WITH TIES ProductCode, 
    ProductName, Price,
    CONVERT(varchar(10),EffectiveDate,1) AS PriceDate
  FROM Product
    JOIN Price ON Product.ProductID = Price.ProductID
  ORDER BY Price