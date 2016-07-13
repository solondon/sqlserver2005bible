-----------------------------------------------------------
-- SQL Server 2005 Bible 
-- Wiley & Sons 
-- Paul Nielsen

-- Chapter  25 - Adv Server Side Code

-----------------------------------------------------------
-----------------------------------------------------------

-- Server-Side code
----------------------------------------------------
-- AddNew Stored Procedure (already in the database)

USE OBXKites

CREATE PROCEDURE pProduct_AddNew(
  @ProductCategoryName NVARCHAR(50), 
  @Code CHAR(10),   
  @Name NVARCHAR(50),
  @ProductDescription NVARCHAR(100) = NULL
  )
AS
  SET NOCOUNT ON
  DECLARE 
    @ProductCategoryID UNIQUEIDENTIFIER

  SELECT @ProductCategoryID = ProductCategoryID 
    FROM dbo.ProductCategory
      WHERE ProductCategoryName = @ProductCategoryName
  IF @@Error <> 0 RETURN -100

  IF @ProductCategoryID IS NULL
    BEGIN
      RAISERROR ('Product Category: ''%s'' not found',
        15,1,@ProductCategoryName)
      RETURN -100
    END

BEGIN TRY   
  INSERT dbo.Product (ProductCategoryID, Code, ProductName, ProductDescription)
    VALUES (@ProductCategoryID, @Code, @Name, @ProductDescription )
END TRY 
BEGIN CATCH
      RAISERROR ('Unable to insert new product', 15,1)
      RETURN -100
END CATCH 

go

-- Test

EXEC pProduct_AddNew
  @ProductCategoryName = 'OBX',
  @Code = '999',   
  @Name = 'Test Kit',
  @ProductDescription = 'official kite testing kit for contests.'

EXEC pProduct_Fetch 999

SELECT ProductName, ProductCategoryName
  FROM dbo.Product
    JOIN dbo.ProductCategory
      ON Product.ProductCategoryID 
         = ProductCategory. ProductCategoryID
  WHERE Code = '999'

----------------------------------------------------
-- Fetch Stored Procedure (already in the database)


CREATE PROCEDURE pProduct_Fetch(
  @ProductCode CHAR(15) = NULL,
  @ProductCategory CHAR(15) = NULL ) 
AS
SET NoCount ON

SELECT Code, ProductName, ProductDescription, ActiveDate,
    DiscontinueDate, ProductCategoryName, [RowVersion] --,
--    Product.Created, Product.Modified  
  FROM dbo.Product
    JOIN dbo.ProductCategory
      ON Product.ProductCategoryID 
             = ProductCategory.ProductCategoryID
  WHERE ( Product.Code = @ProductCode 
                OR @ProductCode IS NULL ) 
    AND ( ProductCategory.ProductCategoryName = @ProductCategory
              OR @ProductCategory IS NULL ) 
  IF @@Error <> 0 RETURN -100

RETURN

-- Test

EXEC pProduct_Fetch 

EXEC pProduct_Fetch 
  @ProductCode = '1005'

EXEC pProduct_Fetch 
  @ProductCategory = 'Book'


----------------------------------------------------
-- Update Stored Procedure (already in the database)

CREATE PROCEDURE pProduct_Update_RowVersion (
  @Code CHAR(15), 
  @RowVersion Rowversion,
  @Name VARCHAR(50), 
  @ProductDescription VARCHAR(50), 
  @ActiveDate DateTime,
  @DiscontinueDate DateTime )
AS 
SET NoCount ON

UPDATE dbo.Product
  SET 
    ProductName = @Name,
    ProductDescription = @ProductDescription,
    ActiveDate = @ActiveDate,
    DiscontinueDate = @DiscontinueDate
  WHERE Code = @Code 
    AND [RowVersion] = @RowVersion 
  
  IF @@ROWCOUNT = 0 
    BEGIN
    IF EXISTS ( SELECT * FROM Product WHERE Code = @Code)
      BEGIN
        RAISERROR ('Product failed to update because 
           another transaction updated the row since your
           last read.', 16,1)
        RETURN -100
      END 
    ELSE 
      BEGIN
        RAISERROR ('Product failed to update because 
           the row has been deleted', 16,1)
        RETURN -100
      END
    END 
RETURN




EXEC pProduct_Fetch 1001


-- 
EXEC pProduct_Update_Rowversion 
  1001, 
  0x0000000000000077, -- replace with your rowversion value from the previous fetch procedure
  'updatetest', 
  'new description', 
  '1/1/2002', 
  NULL


-- Minimal Update 


CREATE PROCEDURE pProduct_Update_Minimal (
  @Code CHAR(15), 
  @Name VARCHAR(50) = NULL, 
  @ProductDescription VARCHAR(50) = NULL, 
  @ActiveDate DateTime = NULL,
  @DiscontinueDate DateTime = NULL )

AS 
SET NoCount ON

IF EXISTS (SELECT * FROM dbo.Product WHERE Code = @Code)
  BEGIN 
    BEGIN TRANSACTION
    IF @Name IS NOT NULL
      BEGIN
        UPDATE dbo.Product
          SET 
            ProductName = @Name
          WHERE Code = @Code
        IF @@Error <> 0 
          BEGIN
            ROLLBACK
            RETURN -100
          END
      END 

    IF @ProductDescription IS NOT NULL
      BEGIN
        UPDATE dbo.Product
          SET 
            ProductDescription = @ProductDescription
          WHERE Code = @Code 
        IF @@Error <> 0 
          BEGIN
            ROLLBACK
            RETURN -100
          END
      END 
 
    IF @ActiveDate IS NOT NULL
      BEGIN
        UPDATE dbo.Product
          SET 
            ActiveDate = @ActiveDate
          WHERE Code = @Code 
        IF @@Error <> 0 
          BEGIN
            ROLLBACK
            RETURN -100
          END
      END 

    IF @DiscontinueDate IS NOT NULL
      BEGIN
        UPDATE dbo.Product
          SET 
            DiscontinueDate = @DiscontinueDate
          WHERE Code = @Code
        IF @@Error <> 0 
          BEGIN
            ROLLBACK
            RETURN -100
          END
      END
    COMMIT TRANSACTION
  END
ELSE 
  BEGIN
    RAISERROR 
      ('Product failed to update because the row has 
          been deleted', 16,1)
    RETURN -100
  END
RETURN 

-- Test

EXEC pProduct_Update_Minimal 
  @Code = '1001', 
  @ProductDescription = 'a minimal update'

EXEC pProduct_Fetch 1001


----------------------------------------------------
-- Delete Stored Procedure (already in the database)

CREATE PROCEDURE pProduct_Delete(
  @ProductCode INT
)
AS
  SET NOCOUNT ON
  DECLARE @ProductID UniqueIdentifier

  SELECT @ProductID = ProductID 
    FROM Product
    WHERE Code = @ProductCode
  If @@RowCount = 0 
    BEGIN
      RAISERROR  
        ('Unable to delete Product Code %i - does not exist.', 16,1, @ProductCode)
      RETURN
    END
  ELSE
    DELETE dbo.Product
      WHERE ProductID = @ProductID
RETURN

-- Test
EXEC pProduct_Delete 99








