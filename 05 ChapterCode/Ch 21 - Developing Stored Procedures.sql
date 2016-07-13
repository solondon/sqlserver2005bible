/*
SQL Server 2005 Bible 
www.sqlserverbible.com
Paul Nielsen
John Wiley & Sons, Inc  

Chapter 21 - Developing Stored Procedures
*/

---------------------------------------------
-- Managing Stored Procedures

-- Create, Alter, Drop
USE OBXKites;
go

CREATE PROCEDURE CategoryList
AS 
SELECT ProductCategoryName, ProductCategoryDescription  
  FROM dbo.ProductCategory;
RETURN;
go

--Returning a Record Set
EXEC CategoryList;

-- Compiling Stored Procedures
SELECT CAST(C.sql as Char(35)) as StoredProcedure, cacheobjtype,  usecounts as Count, ObjType
  FROM Master.dbo.syscacheobjects C
  JOIN  Master.dbo.sysdatabases D
    ON C.dbid = C.dbid
  WHERE D.Name = DB_Name() 
    AND ObjType = 'Proc'
  ORDER BY StoredProcedure;

EXEC sp_recompile CategoryList

-- Stored Procedure Encryption

sp_helptext CategoryList;

ALTER PROCEDURE CategoryList
WITH ENCRYPTION
AS 
SELECT * 
  FROM dbo.ProductCategory;

sp_helptext CategoryList;

----------------------------------------------------
-- Passing Data to Stored Procedures

-- Input Parameters
USE OBXKites;

go
CREATE PROCEDURE CategoryGet
  (@CategoryName NVARCHAR(35))
AS
SELECT ProductCategoryName, ProductCategoryDescription 
  FROM dbo.ProductCategory
  WHERE ProductCategoryName = @CategoryName;
go

EXEC CategoryGet 'Kite';


-- Parameter Defaults
CREATE PROCEDURE pProductCategory_Fetch2(
  @Search NVARCHAR(50) = NULL
)
-- If @Search = null then return all ProductCategories
-- If @Search is value then try to find by Name
AS 
  SET NOCOUNT ON;
  SELECT ProductCategoryName, ProductCategoryDescription
    FROM dbo.ProductCategory
    WHERE ProductCategoryName = @Search
      OR @Search IS NULL;
  IF @@RowCount = 0  
    RAISERROR('Product Category ''%s'' Not Found.',14,1,@Search);
go

EXEC pProductCategory_Fetch2 'OBX';

EXEC pProductCategory_Fetch2;

--------------------------------------------
-- Returning Data from Stored Procedures

-- Output Parameters
USE OBXKites;
go
CREATE PROC GetProductName (
  @ProductCode CHAR(10),
  @ProductName VARCHAR(25) OUTPUT )
AS
SELECT @ProductName = ProductName
  FROM dbo.Product
  WHERE Code = @ProductCode;
go

--
USE OBXKITES;
DECLARE @ProdName VARCHAR(25);
EXEC GetProductName '1001', @ProdName OUTPUT;
PRINT @ProdName;

-- Using the Return Command
CREATE PROC IsItOK (
  @OK VARCHAR(10) )
AS
IF @OK = 'OK'
  RETURN 0
ELSE 
  RETURN -100;
go


DECLARE @ReturnCode INT;
EXEC @ReturnCode = IsITOK 'OK';
PRINT @ReturnCode;
EXEC @ReturnCode = IsItOK 'NotOK';
PRINT @ReturnCode;

-- Path and Scope of Returning Data
SELECT * FROM OpenQuery(
  NOLI, 
  'EXEC OBXKites.dbo.pProductCategory_Fetch') 
  WHERE ProductCategoryDescription Like '%stuff%'

---------------------------------------------------
-- Using Stored Procedures within Queries
SELECT * FROM OpenQuery(
  [XPS\Standard], 
  'EXEC OBXKites.dbo.pProductCategory_Fetch') 
  WHERE ProductCategoryDescription Like '%stuff%'

---------------------------------------------------
-- Remote Stored Procedures

EXEC [Noli\SQL2].OBXKites.dbo.pProductCategory_AddNew 'Food', 'Eatables'

SELECT CustomerTypeName, DiscountPercent, [Default]
  FROM OPENQUERY(
    [Noli\SQL2], 
    'OBXKites.dbo.pCustomerType_Fetch' )
 
