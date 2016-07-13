
-----------------------------------------------------------
-- SQL Server 2005 Bible 
-- Wiley Publishing 
-- Paul Nielsen

-- Chapter 10 - Including Data with Subqueries and CTE’s


-------------------------------------------------
-- Simple Subqueries
SELECT (SELECT 3) AS SubqueryValue

-- Subqueries as Expression in Where Clause
USE OBXKites

SELECT ProductName 
  FROM dbo.Product
  WHERE ProductCategoryID
    = (Select ProductCategoryID 
          FROM dbo.ProductCategory 
          Where ProductCategoryName = 'Kite');

------------------------------------------
-- Where = ALL (subquery)
-- Extra code - not in text

Select 'Yes'
where 
1 = ALL (select 1 where 1=0) -- empty set all is true

Select 'Yes'
where 
1 < ALL (select 1 where 1=0) -- empty set all is true

Select 'Yes'
where 
1 = ALL (select 1) -- works as expected

Select 'Yes'
where 
1 = ALL (select 2) -- works as expected

-- Common Table Expressions
WITH CTEQuery (ProductCategoryID)
AS (Select ProductCategoryID 
          FROM dbo.ProductCategory 
          Where ProductCategoryName = 'Kite')
SELECT ProductName 
  FROM dbo.Product
  WHERE ProductCategoryID
    = (SELECT ProductCategoryID FROM CTEQuery)

-- multiple CTEs
WITH 
A(PK, Col2) AS (Select 'A', 123),  -- error in text, use comma to separate multiple CTEs
B(PK, Col2) AS (Select 'A', 456)
SELECT *
  FROM A
    JOIN B
      ON A.PK = B.PK  

-- Using Scalar Subqueries
SELECT ProductCategoryName, 
     SUM(Quantity * UnitPrice) AS Sales, 
     Cast(SUM(Quantity * UnitPrice) /
         (SELECT SUM(Quantity * UnitPrice) 
            FROM dbo.OrderDetail) *100 AS INT) 
         AS PercentOfSales
  FROM dbo.OrderDetail
    JOIN dbo.Product
      ON OrderDetail.ProductID = Product.ProductID
    JOIN dbo.ProductCategory
      ON Product.ProductCategoryID = ProductCategory.ProductCategoryID
  GROUP BY ProductCategoryName
  ORDER BY Count(*) DESC

SELECT @CurrPrice = Price * (1-@DiscountPercent)
    FROM dbo.Price 
      JOIN dbo.Product 
        ON Price.ProductID = Product.ProductID
    WHERE ProductCode = '1001'
      AND EffectiveDate =
        (SELECT MAX(EffectiveDate) 
          FROM dbo.Price  
            JOIN dbo.Product 
              ON Price.ProductID = Product.ProductID
           WHERE ProductCode = '1001'
             AND EffectiveDate <= '6/1/2001')

-- Using Subqueries as Lists
SELECT * 
  FROM dbo.Contact 
  WHERE HomeRegion IN ('NC', 'SC', 'GA', 'AL', 'VA')

SELECT ProductName 
  FROM dbo.Product
  WHERE ProductID IN
    -- 4. Find all the products sold in orders with kites
    (SELECT ProductID 
      FROM dbo.OrderDetail
      WHERE OrderID IN 
      -- 3. Find the Kite Orders
      (SELECT OrderID  -- Find the Orders with Kites
        FROM dbo.OrderDetail 
        WHERE ProductID IN 
          -- 2. Find the Kite Products
          (SELECT ProductID  
            FROM dbo.Product       
            WHERE ProductCategoryID = 
               -- 1. Find the Kite category
               (Select ProductCategoryID 
                 FROM dbo.ProductCategory 
                 Where ProductCategoryName 
                    = 'Kite' ) ) ) )

SELECT ProductName 
  FROM dbo.Product
  WHERE ProductID IN
    -- 4. Find all the products sold in orders with kites
    (SELECT ProductID 
      FROM dbo.OrderDetail
      WHERE OrderID IN 
      -- 3. Find the Kite Orders
      (SELECT OrderID  -- Find the Orders with Kites
        FROM dbo.OrderDetail 
        WHERE ProductID IN 
          -- 2. Find the Kite Products
          (SELECT ProductID  
            FROM dbo.Product       
            WHERE ProductCategoryID = 
               -- 1. Find the Kite category
               (Select ProductCategoryID 
                 FROM dbo.ProductCategory 
                 Where ProductCategoryName 
                    = 'Kite')))) 
        -- outer query continued
        AND ProductID NOT IN 
          (SELECT ProductID  
            FROM dbo.Product       
            WHERE ProductCategoryID = 
               (Select ProductCategoryID 
                 FROM dbo.ProductCategory 
                 Where ProductCategoryName 
                    = 'Kite'))


SELECT Distinct Product.ProductName
  FROM dbo.Product
    JOIN dbo.OrderDetail OrderRow
      ON Product.ProductID = OrderRow.ProductID
    JOIN dbo.OrderDetail KiteRow
      ON OrderRow.OrderID = KiteRow.OrderID
    JOIN dbo.Product Kite
      ON KiteRow.ProductID = Kite.ProductID
    JOIN dbo.ProductCategory
      ON Kite.ProductCategoryID 
           = ProductCategory.ProductCategoryID
  Where ProductCategoryName  = 'Kite'

SELECT Distinct Product.ProductName
  FROM dbo.Product
    JOIN dbo.OrderDetail OrderRow
      ON Product.ProductID = OrderRow.ProductID
    JOIN dbo.OrderDetail KiteRow
      ON OrderRow.OrderID = KiteRow.OrderID
    JOIN dbo.Product Kite
      ON KiteRow.ProductID = Kite.ProductID
    JOIN dbo.ProductCategory
      ON Kite.ProductCategoryID
           = ProductCategory.ProductCategoryID
      AND Product.ProductCategoryID 
           != Kite.ProductCategoryID
  Where ProductCategoryName  = 'Kite'


USE OBXKites
SELECT TOP 5 ProductName, ProductID
  FROM dbo.Product
  WHERE ProductID NOT IN
    (SELECT TOP 25 ProductID
       FROM dbo.Product
       ORDER BY ProductID)
  ORDER BY ProductID

-- Using Subqueries as Tables
SELECT ProductCode, SUM(Quantity) AS QuantitySold
  FROM dbo.OrderDetail
    JOIN dbo.Product
      ON OrderDetail.ProductID = Product.ProductID
  GROUP BY ProductCode

SELECT Product.ProductCode, Product.ProductName, 
    Sales.QuantitySold 
  FROM dbo.Product
  JOIN (SELECT ProductID, SUM(Quantity) AS QuantitySold
             FROM dbo.OrderDetail
             GROUP BY ProductID) Sales
    ON Product.ProductID = Sales.ProductID
  ORDER BY ProductCode

USE Family
SELECT PersonID, FirstName, LastName, Children
  FROM dbo.Person
    JOIN (SELECT MotherID, COUNT(*) AS Children 
               FROM dbo.Person 
               WHERE MotherID IS NOT NULL 
               GROUP BY MotherID) ChildCount
      ON Person.PersonID = ChildCount.MotherID
  ORDER BY Children DESC

-------------------------------------------------
-- Correlated Subqueries

USE CHA2

-- Who has gone on an event outside thier state? 
SELECT * FROM dbo.BaseCamp

-- this code assumes the data has been converted only once and the base campes are ID 1-4 

UPDATE dbo.BaseCamp SET Region = 'NC' Where BaseCampID = 1
UPDATE dbo.BaseCamp SET Region = 'NC' Where BaseCampID = 2
UPDATE dbo.BaseCamp SET Region = 'BA' Where BaseCampID = 3
UPDATE dbo.BaseCamp SET Region = 'FL' Where BaseCampID = 4
UPDATE dbo.BaseCamp SET Region = 'WV' Where BaseCampID = 5

UPDATE dbo.Customer SET Region = 'ND' WHERE CustomerID = 1
UPDATE dbo.Customer SET Region = 'NC' WHERE CustomerID = 2
UPDATE dbo.Customer SET Region = 'NJ' WHERE CustomerID = 3
UPDATE dbo.Customer SET Region = 'NE' WHERE CustomerID = 4
UPDATE dbo.Customer SET Region = 'ND' WHERE CustomerID = 5
UPDATE dbo.Customer SET Region = 'NC' WHERE CustomerID = 6
UPDATE dbo.Customer SET Region = 'NC' WHERE CustomerID = 7
UPDATE dbo.Customer SET Region = 'BA' WHERE CustomerID = 8
UPDATE dbo.Customer SET Region = 'NC' WHERE CustomerID = 9
UPDATE dbo. Customer SET Region = 'FL' WHERE CustomerID = 10

-- location matrix
SELECT DISTINCT Customer.Region, BaseCamp.Region 
  FROM dbo.Customer  
    JOIN dbo.Event_mm_Customer
      ON Customer.CustomerID = Event_mm_Customer.CustomerID
    JOIN dbo.Event 
      ON Event_mm_Customer.EventID = Event.EventID
    JOIN dbo.Tour
      ON Event.TourID = Tour.TourID
    JOIN dbo.BaseCamp
      ON Tour.BaseCampID = BaseCamp.BaseCampID
  WHERE Customer.Region IS NOT NULL
  GROUP BY Customer.Region, BaseCamp.Region
  ORDER BY Customer.Region, BaseCamp.Region

-- who lives near a base camp?
USE CHA2
SELECT C.FirstName, C.LastName, C.Region
  FROM dbo.Customer C
  WHERE  EXISTS
    (SELECT * 
      FROM dbo.BaseCamp B 
      WHERE B.Region = C.Region)
  ORDER BY LastName, FirstName

SELECT DISTINCT C.FirstName, C.LastName, C.Region, B.Region
  FROM dbo.Customer C
    JOIN dbo.BaseCamp B
      ON C.Region = B.Region
  ORDER BY LastName, FirstName

-- Who attended an event in their home region?
USE CHA2
SELECT DISTINCT C.FirstName, C.LastName, C.Region AS Home
  FROM dbo.Customer C
    JOIN dbo.Event_mm_Customer E
      ON C.CustomerID = E.CustomerID
  WHERE C.Region IS NOT NULL 
    AND EXISTS   
         (SELECT *  
           FROM dbo.Event 
             JOIN dbo.Tour
               ON Event.TourID = Tour.TourID
             JOIN dbo.BaseCamp
               ON Tour.BaseCampID = BaseCamp.BaseCampID
           WHERE BaseCamp.Region = C.Region
             AND Event.EventID = E.EventID)

-- Same query as a join  
SELECT Distinct C.FirstName, C.LastName, C.Region AS Home, 
    Tour.Name, BaseCamp.Region
  FROM dbo.Customer C
    JOIN dbo.Event_mm_Customer
      ON C.CustomerID = Event_mm_Customer.CustomerID
    JOIN dbo.Event 
      ON Event_mm_Customer.EventID = Event.EventID
    JOIN dbo.Tour
      ON Event.TourID = Tour.TourID
    JOIN dbo.BaseCamp
      ON Tour.BaseCampID = BaseCamp.BaseCampID
      AND C.Region = BaseCamp.Region
      AND C.Region IS NOT NULL
  ORDER BY C.LastName

-------------------------------------------------
-- Relational Division

-- Exact Relational Division
go
USE OBXKites
go
DECLARE @OrderNumber INT

-- First Person orders exactly all toys 
EXEC  pOrder_AddNew 
   @ContactCode = '110', 
   @EmployeeCode = '120', 
   @LocationCode = 'CH', 
   @OrderDate='6/1/2002', 
   @OrderNumber = @OrderNumber output

EXEC pOrder_AddItem 
   @OrderNumber = @OrderNumber, -- must be a valid, open order. Get OrderNumber from pOrder_AddNew
   @Code = '1049', -- if NULL then non-stock Product text description
   @NonStockProduct = NULL,
   @Quantity = 1, -- required
   @UnitPrice = NULL, -- if Null then the sproc will lookup the correct current price for the customer
   @ShipRequestDate = NULL, -- if NULL then today
   @ShipComment = NULL

EXEC pOrder_AddItem @OrderNumber, '1050', NULL, 1, NULL, NULL, NULL

-- Second Person - has ordered exactly all toys - 1050 twice
EXEC pOrder_AddNew '111', '119', 'JR', '6/1/2002', @OrderNumber output
EXEC pOrder_AddItem @OrderNumber, '1049', NULL, 1, NULL, NULL, NULL
EXEC pOrder_AddItem @OrderNumber, '1050', NULL, 1, NULL, NULL, NULL

EXEC pOrder_AddNew '111', '119', 'JR', '6/1/2002', @OrderNumber output
EXEC pOrder_AddItem @OrderNumber, '1050', NULL, 1, NULL, NULL, NULL

-- Third Person - has order all toys plus some others
EXEC pOrder_AddNew '112', '119', 'JR', '6/1/2002', @OrderNumber output
EXEC pOrder_AddItem @OrderNumber, '1049', NULL, 1, NULL, NULL, NULL
EXEC pOrder_AddItem @OrderNumber, '1050', NULL, 1, NULL, NULL, NULL
EXEC pOrder_AddItem @OrderNumber, '1001', NULL, 1, NULL, NULL, NULL
EXEC pOrder_AddItem @OrderNumber, '1002', NULL, 1, NULL, NULL, NULL

-- Fourth Person - has order one toy
EXEC pOrder_AddNew '113', '119', 'JR', '6/1/2002', @OrderNumber output
EXEC pOrder_AddItem @OrderNumber, '1049', NULL, 1, NULL, NULL, NULL

SELECT * 
   FROM dbo.[order] 
   WHERE OrderDate = '6/1/2002'

--Relational Division with remainder
-- Is number of toys ordered...
SELECT Contact.ContactCode 
  FROM dbo.Contact
    JOIN dbo.[Order]
      ON Contact.ContactID = [Order].ContactID
    JOIN dbo.OrderDetail
      ON [Order].OrderID = OrderDetail.OrderID
    JOIN dbo.Product
      ON OrderDetail.ProductID = Product.ProductID
   JOIN dbo.ProductCategory 
      ON Product.ProductCategoryID = ProductCategory.ProductCategoryID
  WHERE ProductCategory.ProductCategoryName = 'Toy'
  GROUP BY Contact.ContactCode
  HAVING  COUNT(DISTINCT Product.Code) = 
-- equal to number of toys available?
           (SELECT Count(Code) 
             FROM dbo.Product 
               JOIN dbo.ProductCategory 
                 ON Product.ProductCategoryID 
                   = ProductCategory.ProductCategoryID 
            WHERE ProductCategory.ProductCategoryName = 'Toy')

-- Exact Relational Division
-- Is number of all products ordered...
SELECT Contact.ContactCode  
  FROM dbo.Contact
    JOIN dbo.[Order]
      ON Contact.ContactID = [Order].ContactID
    JOIN dbo.OrderDetail
      ON [Order].OrderID = OrderDetail.OrderID
    JOIN dbo.Product
      ON OrderDetail.ProductID = Product.ProductID
   JOIN dbo.ProductCategory P1
      ON Product.ProductCategoryID = P1.ProductCategoryID
   JOIN 
       -- and number of toys ordered
       (SELECT Contact.ContactCode, Product.Code  
          FROM dbo.Contact
            JOIN dbo.[Order]
              ON Contact.ContactID = [Order].ContactID
            JOIN dbo.OrderDetail
              ON [Order].OrderID = OrderDetail.OrderID
            JOIN dbo.Product
              ON OrderDetail.ProductID = Product.ProductID
           JOIN dbo.ProductCategory
              ON Product.ProductCategoryID = ProductCategory.ProductCategoryID
           WHERE ProductCategory.ProductCategoryName = 'Toy') ToysOrdered
     ON Contact.ContactCode = ToysOrdered.ContactCode
  GROUP BY Contact.ContactCode
  HAVING  COUNT(DISTINCT Product.Code) = 
    -- equal to number of toys available?
           (SELECT Count(Code) 
             FROM dbo.Product 
               JOIN dbo.ProductCategory 
                 ON Product.ProductCategoryID 
                   = ProductCategory.ProductCategoryID 
            WHERE ProductCategory.ProductCategoryName = 'Toy')
    -- AND equal to the total number of any product ordered?
    AND COUNT(DISTINCT ToysOrdered.Code) =
           (SELECT Count(Code) 
             FROM dbo.Product 
               JOIN dbo.ProductCategory 
                 ON Product.ProductCategoryID 
                   = ProductCategory.ProductCategoryID 
            WHERE ProductCategory.ProductCategoryName = 'Toy')








----------------------------------------------
-- Derived Tables
-- Subquery solution to aggregate problem
-- How many of each product (include product code) have been sold?

-- Solving the Aggregate Problem
