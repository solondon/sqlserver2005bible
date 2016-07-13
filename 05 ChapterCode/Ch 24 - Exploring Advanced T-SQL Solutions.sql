-----------------------------------------------------------
-- SQL Server 2005 Bible 
-- Wiley & Sons 
-- Paul Nielsen

-- Chapter  24 - Adv Server Side Code

-----------------------------------------------------------
-----------------------------------------------------------

 
--------------------------------------------------------
-- Complex Business Rules Validation

-- ensure the guide's qual date is good and the revoke date is null
-- for the given guideID and TourID

USE CHA2
go
CREATE TRIGGER LeadQualied ON Event_mm_Guide
AFTER INSERT, UPDATE
AS 
SET NoCount ON
IF EXISTS(
  SELECT *  
    FROM Inserted
      JOIN dbo.Event 
        ON Inserted.EventID = Event.EventID
      LEFT JOIN dbo.Tour_mm_Guide
        ON Tour_mm_Guide.TourID = Event.TourID
        AND Inserted.GuideID = Tour_mm_Guide.GuideID
    WHERE
       Inserted.IsLead = 1  
       AND 
          (QualDate > Event.DateBegin 
        OR   
           RevokeDate IS NOT NULL
        OR 
           QualDate IS NULL )
        )
  BEGIN 
    RAISERROR('Lead Guide is not Qualified.',16,1)
    ROLLBACK TRANSACTION
  END
go

-- test 
INSERT Event_mm_Guide (EventID, GuideID, IsLead)
  VALUES (10, 1, 1)

INSERT Event_mm_Guide (EventID, GuideID, IsLead)
  VALUES (10, 2, 1)

---------------------------------------------------------
-- Custom Referential Integrity

CREATE TRIGGER RICheck ON Tour
AFTER INSERT, UPDATE
AS 
SET NoCount ON
IF Exists(SELECT * 
            FROM Inserted 
              LEFT OUTER JOIN BaseCamp
                ON Inserted.BaseCampID 
                   = BaseCamp.BaseCampID
            WHERE BaseCamp.BaseCampID IS NULL)
  BEGIN
    RAISERROR
      ('Inappropriate Foreign Key: Tour.BaseCampID', 16, 1)
    ROLLBACK TRANSACTION
    RETURN
  END

UPDATE Tour 
  SET BaseCampID = 99
  WHERE TourID = 1


-- note this trigger does not apply to any of the sample databases:
CREATE TRIGGER AllocationCheck ON Allocation
AFTER INSERT, UPDATE
AS
SET NoCount ON
-- Check For invalid Inventory Item
IF Exists(SELECT * 
            FROM Inserted I
              LEFT OUTER JOIN Inventory
                ON I.SourceID = Inventory.InventoryID
              LEFT OUTER JOIN PurchaseOrderDetail
                ON I.SourceID = PurchaseOrderDetail.PODID
            WHERE Inventory.InventoryID IS NULL 
              AND PurchaseOrderDetail.PODID IS NULL) 
  BEGIN
    RAISERROR
      ('Invalid product allocation source', 16, 1)
    ROLLBACK TRANSACTION
    RETURN
  END


ALTER TABLE Allocation
  ADD CONSTRAINT AllocationSourceExclusive CHECK 
    (PurchaseOrderID IS NULL AND InventoryID IS NOT NULL)
      OR 
    (PurchaseOrderID IS NOT NULL AND InventoryID IS NULL)

----------------------------------------------------------
-- Row-Level Custom Security 

USE OBXKites

-- the security table and the constraints

DROP TABLE dbo.Security

CREATE TABLE dbo.Security (
  SecurityID UniqueIdentifier NOT NULL
    Primary Key NonClustered DEFAULT NewID(),
  ContactID UniqueIdentifier NOT NULL 
    REFERENCES Contact ON DELETE CASCADE,  
  LocationID UniqueIdentifier NOT NULL 
    REFERENCES Location ON DELETE CASCADE,
  SecurityLevel INT NOT NULL DEFAULT 0 
  )
go
 
-- Constraints

CREATE TRIGGER ContactID_RI ON dbo.Security
AFTER INSERT, UPDATE
AS 
SET NoCount ON
IF EXISTS(SELECT * 
            FROM Inserted 
              LEFT OUTER JOIN dbo.Contact
                ON Inserted.ContactID = Contact.ContactID
            WHERE Contact.ContactID IS NULL
              OR Contact.IsEmployee = 0 )
  BEGIN
    RAISERROR
      ('Foreign Key Constraint: Security.ContactID', 16, 1)
    ROLLBACK TRANSACTION
    RETURN
  END
go
ALTER TABLE dbo.Security
  ADD CONSTRAINT ValidSecurityCode CHECK 
    (SecurityLevel IN (0,1,2,3))
go
ALTER TABLE dbo.Security 
  ADD CONSTRAINT ContactLocation UNIQUE
    (ContactID, LocationID) 
go
-- Security table sprocs

-- Security Fetch 

USE OBXKites

CREATE PROCEDURE pSecurity_Fetch(
  @LocationCode CHAR(15) = NULL,
  @ContactCode CHAR(15) = NULL ) 
AS 
SET NoCount ON
  SELECT Contact.ContactCode, Location.LocationCode, SecurityLevel
    FROM dbo.Security
      JOIN dbo.Contact
        ON Security.ContactID = Contact.ContactID
      JOIN dbo.Location
        ON Security.LocationID = Location.LocationID
          WHERE (Location.LocationCode = @LocationCode
                        OR @LocationCode IS NULL)
            AND (Contact.ContactCode = @ContactCode
                        OR @ContactCode IS NULL)
  IF @@ERROR <> 0 RETURN -100
  RETURN
go

---------
CREATE PROCEDURE pSecurity_Assign(
  @ContactCode VARCHAR(15),
  @LocationCode VARCHAR(15), 
  @SecurityLevel INT
  )
AS
  SET NOCOUNT ON
  DECLARE 
    @ContactID UNIQUEIDENTIFIER,
    @LocationID UNIQUEIDENTIFIER

  -- Get ContactID
  SELECT @ContactID = ContactID 
    FROM dbo.Contact
    WHERE ContactCode = @ContactCode
  IF @@ERROR <> 0 RETURN -100
  IF @ContactID IS NULL
    BEGIN
      RAISERROR ('Contact: ''%s'' not found', 15,1,@ContactCode)
      RETURN -100
    END

  -- Get LocationID
  SELECT @LocationID = LocationID 
    FROM dbo.Location
    WHERE LocationCode = @LocationCode
  IF @@ERROR <> 0 RETURN -100
  IF @LocationID IS NULL
    BEGIN
      RAISERROR ('Location: ''%s'' not found', 15,1,@LocationCode)
      RETURN -100
    END
  
  -- Insert
  INSERT dbo.Security (ContactID,LocationID, SecurityLevel)
    VALUES (@ContactID, @LocationID, @SecurityLevel) 
  IF @@ERROR <> 0 RETURN -100
  RETURN

go

-------------
-- Test Security insert

SELECT ContactCode 
  FROM dbo.Contact 
  WHERE IsEmployee = 1

SELECT LocationCode 
  FROM dbo.Location

EXEC pSecurity_Assign 
  @ContactCode = 118, 
  @LocationCode = CH,
  @SecurityLevel = 3

EXEC pSecurity_Assign 
  @ContactCode = 118, 
  @LocationCode = Clt,
  @SecurityLevel = 2

EXEC pSecurity_Assign 
  @ContactCode = 118, 
  @LocationCode = Elc,
  @SecurityLevel = 1

EXEC pSecurity_Assign 
  @ContactCode = 120, 
  @LocationCode = W,
  @SecurityLevel = 2  

SELECT * FROM Contact WHERE ContactCode = 118

EXEC pSecurity_Fetch @LocationCode = 'W'

EXEC pSecurity_Fetch @ContactCode = '118'

SELECT * 
  FROM Sdbo.ecurity

-- Test Constrants
-- unique
EXEC pSecurity_Assign 
  @ContactCode = 120, 
  @LocationCode = W,
  @SecurityLevel = 2 

-- invalid security code
EXEC pSecurity_Assign 
  @ContactCode = 118, 
  @LocationCode = W,
  @SecurityLevel = 5 

-- non employee
Select ContactCode 
  FROM dbo.Contact 
  WHERE IsEmployee = 0 

EXEC pSecurity_Assign 
  @ContactCode = 102, 
  @LocationCode = W,
  @SecurityLevel = 3 

-- invalid contact
EXEC pSecurity_Assign 
  @ContactCode = 999, 
  @LocationCode = W,
  @SecurityLevel = 3 

-- invalid location
EXEC pSecurity_Assign 
  @ContactCode = 118, 
  @LocationCode = RDBMS,
  @SecurityLevel = 3 

--------------------------------------------------------
-- ALter SPROC so it updates currect security assignment
ALTER PROCEDURE pSecurity_Assign(
  @ContactCode CHAR(15),
  @LocationCode CHAR(15), 
  @SecurityLevel INT
  )
AS
  SET NOCOUNT ON
  DECLARE 
    @ContactID UNIQUEIDENTIFIER,
    @LocationID UNIQUEIDENTIFIER
  -- Get ContactID
  SELECT @ContactID = ContactID 
    FROM dbo.Contact
    WHERE ContactCode = @ContactCode
  IF @ContactID IS NULL
    BEGIN
      RAISERROR 
        ('Contact: ''%s'' not found', 15,1,@ContactCode)
      RETURN -100
    END
  -- Get LocationID
  SELECT @LocationID = LocationID 
    FROM dbo.Location
    WHERE LocationCode = @LocationCode
  IF @LocationID IS NULL
    BEGIN
      RAISERROR 
       ('Location: ''%s'' not found', 15,1,@LocationCode)
      RETURN -100
    END
  -- IS Update or Insert? 
  IF EXISTS(SELECT * 
             FROM dbo.Security 
             WHERE ContactID = @ContactID 
               AND LocationID = @LocationID)
  -- Update
    BEGIN
      UPDATE dbo.Security
        SET SecurityLevel = @SecurityLevel 
        WHERE ContactID = @ContactID 
          AND LocationID = @LocationID 
      IF @@ERROR <> 0 RETURN -100
    END

  -- Insert
  ELSE  
    BEGIN
      INSERT dbo.Security 
          (ContactID,LocationID, SecurityLevel)
        VALUES (@ContactID, @LocationID, @SecurityLevel) 
      IF @@ERROR <> 0 RETURN -100
    END
  RETURN 0 


-------------
-- Test adjusting security level


EXEC pSecurity_Assign 
  @ContactCode = 120, 
  @LocationCode = W,
  @SecurityLevel = 2 

EXEC pSecurity_Fetch 
  @ContactCode = 120

EXEC pSecurity_Assign 
  @ContactCode = 120, 
  @LocationCode = CH,
  @SecurityLevel = 1 

EXEC pSecurity_Assign 
  @ContactCode = 120, 
  @LocationCode = W,
  @SecurityLevel = 3 

EXEC pSecurity_Fetch 
  @ContactCode = 120

----------------------------------------
-- Security Check Procedure 

CREATE PROCEDURE p_SecurityCheck (
  @ContactCode CHAR(15),
  @LocationCode CHAR(15),
  @SecurityLevel INT,
  @Approved BIT OUTPUT )
AS 
SET NoCount ON

DECLARE @ActualLevel INT

SELECT @ActualLevel = SecurityLevel
  FROM dbo.Security
    JOIN dbo.Contact
      ON Security.ContactID = Contact.ContactID
    JOIN dbo.Location
      ON Security.LocationID = Location.LocationID
  WHERE ContactCode = @ContactCode 
    AND LocationCode = @LocationCode

IF @ActualLevel IS NULL 
  OR @ActualLevel < @SecurityLevel
  OR @ActualLevel = 0
  SET @Approved = 0
ELSE 
  SET @Approved = 1

RETURN 0 

-- TEST

EXEC pSecurity_Fetch

DECLARE @OK BIT
EXEC p_SecurityCheck 
  @ContactCode = 118,
  @LocationCode = Clt,
  @SecurityLevel = 3,
  @Approved  = @OK OUTPUT
SELECT @OK

---- As a Function
CREATE FUNCTION dbo.fSecurityCheck (
  @ContactCode CHAR(15),
  @LocationCode CHAR(15),
  @SecurityLevel INT)
RETURNS BIT 
BEGIN
DECLARE @ActualLevel INT,
  @Approved BIT

SELECT @ActualLevel = SecurityLevel
  FROM dbo.Security
    JOIN dbo.Contact
      ON Security.ContactID = Contact.ContactID
    JOIN dbo.Location
      ON Security.LocationID = Location.LocationID
  WHERE ContactCode = @ContactCode 
    AND LocationCode = @LocationCode

IF @ActualLevel IS NULL 
  OR @ActualLevel < @SecurityLevel
  OR @ActualLevel = 0
  SET @Approved = 0
ELSE 
  SET @Approved = 1

RETURN @Approved 
END

-- Check within a Procedure
IF dbo.fSecurityCheck( 118, 'Clt', 3) = 0 
  BEGIN 
    RAISERROR('Security Violation', 16,1)
    --ROLLBACK TRANSACTION
    --RETURN -100
  END 

------------
-- NT Authentication

SELECT suser_sname()

CREATE TABLE dbo.ContactLogin(
  ContactLogin UNIQUEIDENTIFIER PRIMARY KEY NONCLUSTERED DEFAULT NewId(),
  ContactID UniqueIdentifier NOT NULL 
    REFERENCES Contact ON DELETE CASCADE,  
  NTLogin VARCHAR(100) )

INSERT dbo.ContactLogin (ContactID, NTLogin)
  SELECT ContactID, 'NOLI\Paul' -- change to your login
    FROM Contact
    WHERE ContactCode = 118

SELECT ContactCode, NTLogin 
  FROM dbo.Contact
    JOIN ContactLogin
      ON Contact.ContactID = ContactLogin.ContactID
 
-- Security function usign NT Login

CREATE FUNCTION dbo.fSecurityCheckNT (
  @LocationCode CHAR(15),
  @SecurityLevel INT)
RETURNS BIT 
BEGIN
DECLARE @ActualLevel INT,
  @Approved BIT

SELECT @ActualLevel = SecurityLevel
  FROM dbo.Security
    JOIN dbo.Location
      ON Security.LocationID = Location.LocationID
    JOIN dbo.ContactLogin 
      ON Security.ContactID = ContactLogin.ContactID
  WHERE NTLogin = suser_sname()
    AND LocationCode = @LocationCode

IF @ActualLevel IS NULL 
  OR @ActualLevel < @SecurityLevel
  OR @ActualLevel = 0
  SET @Approved = 0
ELSE 
  SET @Approved = 1

RETURN @Approved 
END

-- check
IF dbo.fSecurityCheckNT( 'Clt', 3) = 0 
  BEGIN 
    RAISERROR('Security Violation', 16,1)
    --ROLLBACK TRANSACTION
    --RETURN -100
  END

-----------------------
-- Trigger Security

USE OBXKites

CREATE TRIGGER OrderSecurity ON [Order]
AFTER INSERT, UPDATE
AS 
IF EXISTS (
SELECT *
  FROM dbo.Security
     JOIN dbo.ContactLogin 
      ON Security.ContactID = ContactLogin.ContactID
    JOIN Inserted
      ON Inserted.LocationID = Security.LocationID
  WHERE NTLogin = suser_sname()
    AND SecurityLevel < 2 )
  BEGIN 
    RAISERROR('Security Violation', 16,1)
    ROLLBACK TRANSACTION
  END
go

-------------------------------------------------------
-- Audit Trail table
USE OBXKites

CREATE TABLE dbo.Audit (
  AuditID UNIQUEIDENTIFIER RowGUIDCol  NOT NULL 
    CONSTRAINT DF_Audit_AuditID DEFAULT (NEWID())
    CONSTRAINT PK_Audit PRIMARY KEY NONCLUSTERED (AuditID),
  AuditDate DATETIME NOT NULL,
  SysUser VARCHAR(50) NOT NULL,
  Application VARCHAR(50) NOT NULL,
  TableName VARCHAR(50)NOT NULL,
  Operation CHAR(1) NOT NULL, 	
  PrimaryKey VARCHAR(50) NOT NULL,
  RowDescription VARCHAR(50) NULL,
  SecondaryRow VARCHAR(50) NULL,
  [Column] VARCHAR(50) NOT NULL,
  OldValue VARCHAR(50) NULL,
  NewValue VARCHAR(50) NULL
	)

--------------------------------------------------------------
-- Fixed Audit Trail Trigger

Use OBXKites

Go
If EXISTS (Select * from sysobjects where name = 'Product_Audit')
  DROP TRIGGER Product_Audit
Go

CREATE TRIGGER Product_Audit
ON dbo.Product
AFTER Insert, Update
NOT FOR REPLICATION
AS

DECLARE @Operation CHAR(1)

IF EXISTS(SELECT * FROM Deleted)
 SET @Operation = 'U'
ELSE 
 SET @Operation = 'I'

IF UPDATE(ProductCategoryID) 
    INSERT dbo.Audit 
      (AuditDate, SysUser, Application, TableName, Operation, 
       PrimaryKey, RowDescription, SecondaryRow, [Column], 
       OldValue, NewValue) 
      SELECT GetDate(), suser_sname(), APP_NAME(), 'Product', @Operation,
          Inserted.ProductID, Inserted.Code, NULL, 'ProductCategoryID',
          OPC.ProductCategoryName, NPC.ProductCategoryName
        FROM Inserted
          LEFT OUTER JOIN Deleted
            ON Inserted.ProductID = Deleted.ProductID
            AND Inserted.ProductCategoryID
                <> Deleted.ProductCategoryID 
          -- fetch ProductCategory Names
          LEFT OUTER JOIN dbo.ProductCategory OPC
            ON Deleted.ProductCategoryID = OPC.ProductCategoryID
          JOIN dbo.ProductCategory NPC
            ON Inserted.ProductCategoryID = NPC.ProductCategoryID
   
IF UPDATE(Code) 
    INSERT dbo.Audit 
      (AuditDate, SysUser, Application, TableName, Operation, 
       PrimaryKey, RowDescription, SecondaryRow, [Column], 
       OldValue, NewValue) 
      SELECT GetDate(), suser_sname(), APP_NAME(), 'Product', @Operation,
          Inserted.ProductID, Inserted.Code, NULL, 'Code',
          Deleted.Code, Inserted.Code
        FROM Inserted
          LEFT OUTER JOIN Deleted
            ON Inserted.ProductID = Deleted.ProductID
              AND Inserted.Code <> Deleted.Code

IF UPDATE(ProductName) 
    INSERT dbo.Audit 
      (AuditDate, SysUser, Application, TableName, Operation, 
       PrimaryKey, RowDescription, SecondaryRow, [Column], 
       OldValue, NewValue) 
      SELECT GetDate(), suser_sname(), APP_NAME(), 'Product', @Operation,
          Inserted.ProductID, Inserted.Code, NULL, 'Name',
          Deleted.ProductName, Inserted.ProductName
        FROM Inserted
          LEFT OUTER JOIN Deleted
            ON Inserted.ProductID = Deleted.ProductID
              AND Inserted.ProductName <> Deleted.ProductName

IF UPDATE(ProductDescription) 
    INSERT dbo.Audit 
      (AuditDate, SysUser, Application, TableName, Operation, 
       PrimaryKey, RowDescription, SecondaryRow, [Column], 
       OldValue, NewValue) 
      SELECT GetDate(), suser_sname(), APP_NAME(), 'Product', @Operation,
          Inserted.ProductID, Inserted.Code, NULL, 'ProductDescription',
          Deleted.ProductDescription, Inserted.ProductDescription
        FROM Inserted
          LEFT OUTER JOIN Deleted
            ON Inserted.ProductID = Deleted.ProductID
              AND Inserted.ProductDescription <> Deleted.ProductDescription

IF UPDATE(ActiveDate) 
    INSERT dbo.Audit 
      (AuditDate, SysUser, Application, TableName, Operation, 
       PrimaryKey, RowDescription, SecondaryRow, [Column], 
       OldValue, NewValue) 
      SELECT GetDate(), suser_sname(), APP_NAME(), 'Product', @Operation,
          Inserted.ProductID, Inserted.Code, NULL, 'ActiveDate',
          Deleted.ActiveDate, Inserted.ActiveDate
        FROM Inserted
          LEFT OUTER JOIN Deleted
            ON Inserted.ProductID = Deleted.ProductID
              AND Inserted.ActiveDate != Deleted.ActiveDate

IF UPDATE(DiscontinueDate) 
    INSERT dbo.Audit 
      (AuditDate, SysUser, Application, TableName, Operation, 
       PrimaryKey, RowDescription, SecondaryRow, [Column], 
       OldValue, NewValue) 
      SELECT GetDate(), suser_sname(), APP_NAME(), 'Product', @Operation,
          Inserted.ProductID, Inserted.Code, NULL, 'DiscontinueDate',
          Deleted.DiscontinueDate, Inserted.DiscontinueDate
        FROM Inserted
          LEFT OUTER JOIN Deleted
            ON Inserted.ProductID = Deleted.ProductID
              AND Inserted.DiscontinueDate != Deleted.DiscontinueDate

go     

-------------------------------
-- Test the Fixed Audit Trail

EXEC pProduct_AddNew 'Kite', 200, 'The MonstaKite', 'Man what a big Kite!'

SELECT TableName, RowDescription, [Column], NewValue FROM Audit

SELECT * FROM Audit

UPDATE dbo.Product 
  SET ProductDescription = 'Biggie Sized'
  WHERE Code = 200

SELECT AuditDate, OldValue, NewValue   
  FROM dbo.Audit
  WHERE TableName = 'Product'
    AND RowDescription = '200'
    AND [Column] = 'ProductDescription'

---------------------------------
--Rolling back a change


CREATE PROCEDURE pAudit_RollBack (
  @AuditID UNIQUEIDENTIFIER)
AS
SET NoCount ON

DECLARE
  @SQLString NVARCHAR(4000),
  @TableName NVARCHAR(50),
  @PrimaryKey NVARCHAR(50),
  @Column NVARCHAR(50),
  @NewValue NVARCHAR(50)

SELECT 
  @TableName = TableName,
  @PrimaryKey = PrimaryKey,
  @Column = [Column],
  @NewValue = OldValue
  FROM dbo.Audit
  WHERE AuditID = @AuditID

SET @SQLString = 
  'UPDATE ' + @TableName
    + ' SET ' + @Column + ' = ''' + @NewValue +''''
    + ' WHERE ' + @TableName + 'ID = ''' + @PrimaryKey + ''''

EXEC sp_executeSQL @SQLString
go

----------------------------------
--Test RollBack

DECLARE @AuditRollBack UNIQUEIDENTIFIER

SELECT @AuditRollBack = AuditID 
  FROM dbo.Audit
  WHERE TableName = 'Product'
    AND RowDescription = '200'
    AND OldValue = 'Man what a big Kite!'

EXEC pAudit_RollBack @AuditRollBack

SELECT ProductDescription 
  FROM dbo.Product
  WHERE Code = 200


-----------------------------------------------
-- Transaction-Aggregation Handling

USE OBXKites
---------------------
-- Create a test Inventory Row

DELETE dbo.InventoryTransaction
DELETE dbo.Inventory

DECLARE 
  @ProdID UniqueIdentifier,
  @LocationID UniqueIdentifier 

SELECT @ProdID = ProductID 
  FROM dbo.Product
  WHERE Code = 1001
Select @LocationID= LocationID 
  FROM dbo.Location 
  WHERE LocationCode = 'CH'

INSERT dbo.Inventory (ProductID, InventoryCode, LocationID)
  VALUES (@ProdID,'A1', @LocationID)

SELECT Product.Code, InventoryCode, QuantityOnHand
  FROM dbo.Inventory 
    JOIN Product
      ON Inventory.ProductID = Product.ProductID


-- Inventory Transaction Trigger
CREATE TRIGGER InvTrans_Aggregate
ON dbo.InventoryTransaction
AFTER Insert
AS
 
UPDATE dbo.Inventory
  SET QuantityOnHand = Inventory.QuantityOnHand + Inserted.Value
  FROM dbo.Inventory
    JOIN Inserted 
      ON Inventory.InventoryID = Inserted.InventoryID
Return

--Test

INSERT dbo.InventoryTransaction (InventoryID, Value)
  SELECT InventoryID, 5
    FROM Inventory
    WHERE InventoryCode = 'A1' 

INSERT dbo.InventoryTransaction (InventoryID, Value)
  SELECT InventoryID, -3
    FROM Inventory
    WHERE InventoryCode = 'A1' 

INSERT dbo.InventoryTransaction (InventoryID, Value)
  SELECT InventoryID, 7
    FROM Inventory
    WHERE InventoryCode = 'A1' 

SELECT InventoryCode, Value
  FROM dbo.InventoryTransaction
    JOIN Inventory
      ON Inventory.InventoryID 
         = Inventorytransaction.InventoryID

SELECT Product.Code, InventoryCode, QuantityOnHand
  FROM dbo.Inventory 
    JOIN Product
      ON Inventory.ProductID = Product.ProductID


-- Inventory trigger
CREATE TRIGGER Inventory_Aggregate
ON dbo.Inventory
AFTER UPDATE
AS
-- Redirect direct updates
If Trigger_NestLevel() = 1 AND Update(QuantityOnHand)
  BEGIN
    UPDATE dbo.Inventory 
      SET QuantityOnHand = Deleted.QuantityOnHand
      FROM Deleted 
        JOIN dbo.Inventory 
          ON Inventory.InventoryID = Deleted.InventoryID 
     
     INSERT dbo.InventoryTransaction
       (Value, InventoryID)
       SELECT 
        Inserted.QuantityOnHand - Inventory.QuantityOnHand,
        Inventory.InventoryID  
          FROM dbo.Inventory
            JOIN Inserted
              ON Inventory.InventoryID = Inserted.InventoryID
  END

-- Trigger Test
UPDATE dbo.Inventory
  SET QuantityOnHand = 10
  Where InventoryCode = 'A1'

SELECT InventoryCode, Value
  FROM dbo.InventoryTransaction
    JOIN Inventory
      ON Inventory.InventoryID 
         = Inventorytransaction.InventoryID

SELECT Product.Code, InventoryCode, QuantityOnHand
  FROM dbo.Inventory 
    JOIN Product
      ON Inventory.ProductID = Product.ProductID


---------------------------------------------
-- Logically Deleting Data

ALTER TABLE dbo.Product
  ADD IsDeleted BIT NOT NULL DEFAULT 0


CREATE Trigger Product_LogicalDelete
On dbo.Product
INSTEAD OF Delete
AS

IF (suser_sname() = 'sa') 
  BEGIN
    Print 'physical delete'
    DELETE FROM dbo.Product
      FROM dbo.Product
        JOIN Deleted
          ON Product.ProductID = Deleted.ProductID
  END
ELSE 
  BEGIN
    PRINT 'logical delete'
    UPDATE dbo.Product
      SET IsDeleted = 1
      FROM Product
        JOIN Deleted
          ON Product.ProductID = Deleted.ProductID
  END

-- Test
DELETE dbo.Product
  WHERE Code = '1053'

SELECT Code, IsDeleted 
  FROM dbo.Product
    WHERE Code = 1053

-- must re-connect as sa to physically delete
DELETE dbo.Product
  WHERE Code = '1053'

-- undelete code
UPDATE dbo.Product
  SET IsDeleted = 0
  WHERE Code = 1001

-------------------------------------------
-- Archiving Data

CREATE PROCEDURE pProduct_Archive (
  @Code CHAR(15) )
AS
SET NoCount ON

BEGIN TRANSACTION

INSERT dbo.Product_Archive 
  SELECT * 
    FROM dbo.Product
    WHERE Code = @Code
IF @@ERROR <> 0
  BEGIN
    ROLLBACK TRANSACTION
    RETURN
  END

DELETE dbo.Product
  WHERE Code = @Code
IF @@ERROR <> 0
  BEGIN
    ROLLBACK TRANSACTION
  END

COMMIT TRANSACTION

RETURN






