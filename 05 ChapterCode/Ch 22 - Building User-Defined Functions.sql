/*
SQL Server 2005 Bible 
www.sqlserverbible.com
Paul Nielsen
John Wiley & Sons, Inc  

Chapter  22 - Building User-Defined Functions
*/

-----------------------------------------------------------
-- Scalar Functions

CREATE FUNCTION dbo.Multiply (@A INT, @B INT = 3)
RETURNS INT
AS
BEGIN
   RETURN @A * @B
End
go 

SELECT dbo.Multiply (3,4)
SELECT dbo.Multiply (7, DEFAULT)


CREATE FUNCTION fGetPrice (   
  @Code CHAR(10),
  @PriceDate DATETIME,
  @ContactCode CHAR(15) = NULL)
RETURNS MONEY
As
BEGIN
  DECLARE @CurrPrice MONEY 
   DECLARE @DiscountPercent NUMERIC (4,2)
     -- set the discount percent
     -- if no customer lookup then it's zilch discount
  SELECT @DiscountPercent = CustomerType.DiscountPercent 
    FROM dbo.Contact
      JOIN dbo.CustomerType
        ON contact.CustomerTypeID = 
            CustomerType.CustomerTypeID 
    WHERE ContactCode = @ContactCode
  IF @DiscountPercent IS NULL
    SET @DiscountPercent = 0
  SELECT @CurrPrice = Price * (1-@DiscountPercent)
    FROM dbo.Price 
       JOIN dbo.Product 
         ON Price.ProductID = Product.ProductID
    WHERE Code = @Code
      AND EffectiveDate = 
        (SELECT MAX(EffectiveDate) 
           FROM dbo.Price  
             JOIN dbo.Product 
               ON Price.ProductID = Product.ProductID
           WHERE Code = @Code 
             AND EffectiveDate <= @PriceDate)
    RETURN @CurrPrice
END


-- Calling a Scalar Function
USE ObxKites 
SELECT dbo.fGetPrice('1006',GetDate(),DEFAULT)
SELECT dbo.fGetPrice('1001','5/1/2001',NULL)

---------------------------------------------------------
-- Inline Table-Valued Functions

USE CHA2
go
CREATE FUNCTION fEventList ()
RETURNS Table
AS
RETURN(
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
         ON dbo.Tour.BaseCampID = dbo.BaseCamp.BaseCampID)

SELECT LastName, Code, DateBegin 
  FROM dbo.fEventList()

-- Performance test

DECLARE @pCounter INT

SET @pCounter = 0

WHILE @pCounter < 1000
BEGIN  
  SET @pCounter = @pCounter + 1
  SELECT * FROM dbo.fEventList()
END

--144 seconds
--128 seconds


-- Using Parameters

USE OBXKites
go

CREATE VIEW vPricelist 
AS
SELECT Code, Price.Price 
  FROM dbo.Price
    JOIN dbo.Product P
      ON Price.ProductID = P.ProductID
  WHERE EffectiveDate = 
      (SELECT MAX(EffectiveDate) 
        FROM dbo.Price 
        WHERE ProductID = P.ProductID 
          AND EffectiveDate <= GetDate())

SELECT * 
  FROM vPriceList 
  WHERE Code = '1001'

CREATE FUNCTION dbo.fPriceList (
  @Code CHAR(10) = Null, @PriceDate DateTime)
RETURNS Table
AS 
RETURN(
SELECT Code, Price.Price 
  FROM dbo.Price
    JOIN dbo.Product P
      ON Price.ProductID = P.ProductID
  WHERE EffectiveDate = 
      (SELECT MAX(EffectiveDate) 
        FROM dbo.Price 
        WHERE ProductID = P.ProductID 
          AND EffectiveDate <= @PriceDate)
    AND (Code = @Code
      OR @Code IS NULL) )

SELECT * FROM dbo.fPriceList(DEFAULT, '2/20/2002')

SELECT * FROM dbo.fPriceList('1001', '2/20/2002')

------------------------------------------------------
-- Multistatement table-valued user-defined functions

CREATE FUNCTION fPriceAvg()
RETURNS @Price TABLE
  (Code CHAR(10),
    EffectiveDate DATETIME,
    Price MONEY)
AS 
  BEGIN
    INSERT @Price (Code, EffectiveDate, Price)
      SELECT Code, EffectiveDate, Price
        FROM Product
          JOIN Price 
            ON Price.ProductID = Product.ProductID

    INSERT @Price (Code, EffectiveDate, Price)
      SELECT Code, Null, Avg(Price)
        FROM Product
          JOIN Price 
            ON Price.ProductID = Product.ProductID
        GROUP BY Code
    RETURN
  END


SELECT * 
  FROM dbo.fPriceAvg()



-----------------------------------------------------------------------
-- Correlated User Defined Functions

USE CHA2
go
CREATE FUNCTION fEventList2 (@CustomerID INT)
RETURNS Table
AS
RETURN(
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
  WHERE Customer.CustomerID = @CustomerID   
 )

SELECT C.LastName, Code, DateBegin, Tour
  FROM Customer C
    CROSS APPLY fEventList2(C.CustomerID)
  ORDER BY C.LastName



---------------------------------------
-- Multi-Statement Table-Valued Functions

-- Creating a Multi-Statement Table-Valued Function

USE OBXKite
go

CREATE FUNCTION fPriceAvg()
RETURNS @Price TABLE
  (Code CHAR(10),
    EffectiveDate DATETIME,
    Price MONEY)
AS 
  BEGIN
    INSERT @Price (Code, EffectiveDate, Price)
      SELECT Code, EffectiveDate, Price
        FROM Product
          JOIN Price 
            ON Price.ProductID = Product.ProductID

    INSERT @Price (Code, EffectiveDate, Price)
      SELECT Code, Null, Avg(Price)
        FROM Product
          JOIN Price 
            ON Price.ProductID = Product.ProductID
        GROUP BY Code
    RETURN
  END

-- Calling the Function
SELECT * 
  FROM dbo.fPriceAvg()
