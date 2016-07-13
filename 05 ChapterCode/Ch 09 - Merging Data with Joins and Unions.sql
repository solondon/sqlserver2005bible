
-----------------------------------------------------------
-- SQL Server 2005 Bible 
-- Wiley Publishing 
-- Paul Nielsen

-- Chapter 09  - Merging Data with Joins and Unions

-------------------------------------------------
-- Using Joins

-- Creating Inner Joins within SQL Code
USE CHA2

SELECT Tour.Name, Tour.BaseCampID,
    BaseCamp.BaseCampID, BaseCamp.Name
  FROM dbo.Tour
    JOIN dbo.BaseCamp
      ON Tour.BaseCampID = BaseCamp.BaseCampID

-- Number of Rows Returned
-- the side by side queries:
USE OBXKites

SELECT ContactCode, LastName
  FROM dbo.Contact
  ORDER BY ContactCode

SELECT Contact.ContactCode, Contact.ContactID, 
    [Order].ContactID, [Order].OrderNumber
  FROM dbo.Contact
    JOIN dbo.[Order] 
      ON [Order].ContactID = Contact.ContactID
  ORDER BY ContactCode

-- ANSI SQL 89 Joins
SELECT Contact.ContactCode, Contact.ContactID, 
    [Order].ContactID, [Order].OrderNumber
  FROM dbo.Contact, dbo.[Order]
  WHERE [Order].ContactID = Contact.ContactID
  ORDER BY ContactCode

-- Multiple Table Joins
USE OBXKites
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
  ORDER BY LastName, FirstName

-------------------------------------------------
-- Outer Joins

-- Left Outer Join
SELECT ContactCode, OrderNumber
  FROM dbo.Contact
    LEFT OUTER JOIN dbo.[Order] 
      ON [Order].ContactID = Contact.ContactID
  ORDER BY ContactCode

--Outer Joins and Optional Foreign Keys
SELECT OrderNumber, OrderPriorityName
  FROM dbo.[Order]
    Left Outer Join dbo.OrderPriority
    ON [Order].OrderPriorityID = OrderPriority.OrderPriorityID

-- Full Outer Joins
go
USE Tempdb

IF EXISTS(SELECT * FROM SysObjects Where [Name] = 'One')
  DROP TABLE dbo.One
IF EXISTS(SELECT * FROM SysObjects Where [Name] = 'Two')
  DROP TABLE dbo.Two

CREATE TABLE dbo.One (
  OnePK INT,
  Thing1 VARCHAR(15)
  )

CREATE TABLE dbo.Two (
  TwoPK INT,
  OnePK INT,
  Thing2 VARCHAR(15)
  )
go
INSERT dbo.One(OnePK, Thing1)
  VALUES (1, 'Old Thing')
INSERT dbo.One(OnePK, Thing1)
  VALUES (2, 'New Thing')
INSERT dbo.One(OnePK, Thing1)
  VALUES (3, 'Red Thing')
INSERT dbo.One(OnePK, Thing1)
  VALUES (4, 'Blue Thing')

INSERT dbo.Two(TwoPK, OnePK, Thing2)
  VALUES(1,0, 'Plane')
INSERT dbo.Two(TwoPK, OnePK, Thing2)
  VALUES(2,2, 'Train')
INSERT dbo.Two(TwoPK, OnePK, Thing2)
  VALUES(3,3, 'Car')
INSERT dbo.Two(TwoPK, OnePK, Thing2)
  VALUES(4,NULL, 'Cycle')

-- Inner Join
SELECT Thing1, Thing2 
  FROM dbo.One
    INNER JOIN dbo.Two 
      ON One.OnePK = Two.OnePK

-- Left Outer Join
SELECT Thing1, Thing2 
  FROM dbo.One
    LEFT OUTER JOIN dbo.Two 
      ON One.OnePK = Two.OnePK

-- Full Outer Join
SELECT Thing1, Thing2 
  FROM dbo.One
    FULL OUTER JOIN dbo.Two 
      ON One.OnePK = Two.OnePK

-- Placing the Conditions within Outer Joins
SELECT Thing1, Thing2 
  FROM dbo.One
    LEFT OUTER JOIN dbo.Two 
      ON One.OnePK = Two.OnePK
        AND One.Thing1 = 'New Thing'
  
SELECT Thing1, Thing2 
  FROM dbo.One
    LEFT OUTER JOIN dbo.Two 
      ON One.OnePK = Two.OnePK
  WHERE One.Thing1 = 'New Thing'

-------------------------------------------------
-- Self-Joins

USE Family
SELECT Person.PersonID, Person.FirstName, 
    Person.MotherID, Mother.PersonID
  FROM dbo.Person 
    JOIN dbo.Person Mother
      ON Person.MotherID = Mother.PersonID
  WHERE Mother.LastName = 'Halloway'
    AND Mother.FirstName = 'Audry'

SELECT CONVERT(NVARCHAR(15),Person.DateofBirth,1) AS Date,
    Person.FirstName AS Name, Person.Gender AS G,
    ISNULL(F.FirstName + ' ' + F.LastName, ' * unknown *') 
      as Father, 
    M.FirstName + ' ' + M.LastName as Mother
  FROM dbo.Person
    Left Outer JOIN dbo.Person F
      ON Person.FatherID = F.PersonID
    INNER JOIN dbo.Person M
      ON Person.MotherID = M.PersonID
  ORDER BY Person.DateOfBirth 

-------------------------------------------------
-- Cross (Unrestricted) Joins

USE Tempdb

SELECT Thing1, Thing2 
  FROM dbo.One
    CROSS JOIN dbo.Two 

-------------------------------------------------
-- Exotic Joins 

-- Theta Join

-- Non-Key Joins
USE Family
SELECT Person.FirstName + ' ' + Person.LastName, 
    Twin.FirstName + ' ' + Twin.LastName as Twin,
    Person.DateOfBirth
  FROM dbo.Person
    JOIN dbo.Person Twin
      ON Person.PersonID != Twin.PersonID
        AND Person.MotherID = Twin.MotherID
        AND Person.DateOfBirth = Twin.DateOfBirth
  WHERE Person.DateOfBirth IS NOT NULL

SELECT Person.FirstName + ' ' + Person.LastName AS Person, 
    Twin.FirstName + ' ' + Twin.LastName as Twin,
    Person.DateOfBirth
  FROM dbo.Person
    JOIN dbo.Person Twin
      ON Person.MotherID = Twin.MotherID
        AND Person.DateOfBirth = Twin.DateOfBirth
  WHERE Person.DateOfBirth IS NOT NULL
     AND Person.PersonID != Twin.PersonID

------------------------------------------------
-- Set Difference 
USE Tempdb

SELECT Thing1, Thing2 
  FROM dbo.One
    LEFT OUTER JOIN dbo.Two 
      ON One.OnePK = Two.OnePK
  WHERE Two.TwoPK IS NULL

USE OBXKites
SELECT LastName, FirstName
  FROM dbo.Contact
    LEFT OUTER JOIN dbo.[Order] 
      ON Contact.ContactID = [Order].ContactID
  WHERE OrderID IS NULL
  ORDER BY LastName, FirstName

SELECT LastName, FirstName 
  FROM dbo.Contact 
  WHERE ContactID NOT IN 
    (SELECT ContactID FROM dbo. [Order])
  ORDER BY LastName, FirstName

--
USE Tempdb

IF EXISTS(SELECT * FROM SysObjects Where [Name] = 'One')
  DROP TABLE dbo.One
IF EXISTS(SELECT * FROM SysObjects Where [Name] = 'Two')
  DROP TABLE dbo.Two

CREATE TABLE dbo.One (
  OnePK INT,
  Thing1 VARCHAR(15)
  )

CREATE TABLE dbo.Two (
  TwoPK INT,
  OnePK INT,
  Thing2 VARCHAR(15)
  )
go
INSERT dbo.One(OnePK, Thing1)
  VALUES (1, 'Old Thing')
INSERT dbo.One(OnePK, Thing1)
  VALUES (2, 'New Thing')
INSERT dbo.One(OnePK, Thing1)
  VALUES (3, 'Red Thing')
INSERT dbo.One(OnePK, Thing1)
  VALUES (4, 'Blue Thing')

INSERT dbo.Two(TwoPK, OnePK, Thing2)
  VALUES(1,0, 'Plane')
INSERT dbo.Two(TwoPK, OnePK, Thing2)
  VALUES(2,2, 'Train')
INSERT dbo.Two(TwoPK, OnePK, Thing2)
  VALUES(3,3, 'Car')
INSERT dbo.Two(TwoPK, OnePK, Thing2)
  VALUES(4,NULL, 'Cycle')

SELECT Thing1, Thing2 
  FROM dbo.One
    FULL OUTER JOIN dbo.Two 
      ON One.OnePK = Two.OnePK
  WHERE Two.TwoPK IS NULL 
    OR One.OnePK IS NULL

-------------------------------------------------
-- Using Unions

USE TempDB

SELECT OnePK, Thing1, 'from One' as Source
  FROM dbo.One
UNION ALL
SELECT TwoPK, Thing2, 'from Two'
  FROM dbo.Two
ORDER BY Thing1

-- Intersect Union
-- rows common to both tables

-- first create red thing and blue thing to two so there will be an intersection
INSERT dbo.Two(TwoPK, OnePK, Thing2)
  VALUES(5,0, 'Red Thing')
INSERT dbo.Two(TwoPK, OnePK, Thing2)
  VALUES(6,0, 'Blue Thing')

-- SQL 2005 method
SELECT Thing1
  FROM dbo.One
INTERSECT
SELECT Thing2
  FROM dbo.Two
ORDER BY Thing1

-- SQL 2K method
SELECT DISTINCT  U.Thing1
FROM 
(SELECT DISTINCT Thing1
  FROM dbo.One
UNION ALL
SELECT DISTINCT Thing2
  FROM dbo.Two) U
GROUP BY Thing1
HAVING Count(*) >1

-- Difference Union/Except
-- SQL 2005 method
SELECT Thing1
  FROM dbo.One
EXCEPT
SELECT Thing2
  FROM dbo.Two
ORDER BY Thing1

-- all unique values
SELECT Thing1
FROM 
(SELECT DISTINCT Thing1
  FROM dbo.One
UNION ALL
SELECT DISTINCT Thing2
  FROM dbo.Two) U
GROUP BY Thing1
HAVING Count(*) = 1

-- SQL 2K method 
SELECT Thing1
FROM 
(SELECT DISTINCT Thing1
  FROM dbo.One
UNION ALL
 SELECT DISTINCT Thing1
  FROM dbo.One
UNION ALL
SELECT DISTINCT Thing2
  FROM dbo.Two) U
GROUP BY Thing1
HAVING Count(*) = 2




