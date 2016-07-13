-----------------------------------------------------------
-- SQL Server 2005 Bible 
-- Wiley Publishing 
-- Paul Nielsen

-- Chapter  23 - Triggers

-----------------------------------------------------------
-----------------------------------------------------------

-----------------------------------------------------------
-- Trigger Timing

-- The following is a collection of queries that can be executed in different order 
-- to determine which error is received first. 

USE CHA2

CREATE Trigger Tour_Insert ON Tour
INSTEAD OF INSERT
AS 
Print 'Tour Insert Trigger'

-- Null before data type
INSERT Tour (BaseCampID, Name, Days, Description)
  VALUES (null, 1, 2, 'this is a test, this is only a test.' ) 

-- Data Type
INSERT Tour (BaseCampID, Name, Days, Description)
  VALUES (1, 1, 2, 'this is a test, this is only a test.' ) 

-- Insert trigger before Foreign Key constraint
INSERT Tour (TourID, BaseCampID, Name, Days, Description)
  VALUES (99,null, 123, 2, 'this is a test, this is only a test.' ) 

DROP TRIGGER Tour_Insert

ALTER TABLE Tour DROP CONSTRAINT TourName_check

ALTER TABLE Tour WITH NoCheck
 ADD CONSTRAINT TourName_check CHECK ([Name] LIKE 'Test%')

Select * from Tour

USE Family

CREATE Trigger KeyTest ON Person
INSTEAD OF INSERT
AS 
Print 'Person Insert Trigger'

EXEC ('
USE Family
Select * from Person 
INSERT Person(PersonID, LastName, FirstName, Gender, MotherID)
  VALUES (99, ''Bill'', ''eBob'',''M'', 999) ')


DROP Trigger KeyTest

ALTER TABLE Person DROP CONSTRAINT PerKey_check

ALTER TABLE Person WITH NoCheck
 ADD CONSTRAINT PerKey_check CHECK ([LastName] LIKE 'Test%')


----------------------------------------------------------------------
-- After Trigger 

USE FAMILY 
go
CREATE TRIGGER TriggerOne ON Person
AFTER Insert
AS 
PRINT 'In the After Trigger' 
go

INSERT Person(PersonID, LastName, FirstName, Gender)
  VALUES (50, 'Ebob', 'Bill','M')

-----------------------------------------------------------------------
-- Instead of Trigger

USE FAMILY 

CREATE TRIGGER TriggerTwo ON Person
INSTEAD OF Insert
AS 
PRINT 'In the Insead of Trigger' 
go

INSERT Person(PersonID, LastName, FirstName, Gender)
  VALUES (51, 'Ebob', '','M')

SELECT LastName
  FROM Person
  WHERE PersonID = 51


--------------------------------------------------------
-- Disabling Triggers

ALTER TABLE Person 
  DISABLE TRIGGER TriggerOne

SELECT OBJECTPROPERTY(OBJECT_ID('TriggerOne'),'ExecIsTriggerDisabled')


ALTER TABLE Person 
  ENABLE TRIGGER TriggerOne

SELECT OBJECTPROPERTY(OBJECT_ID('TriggerOne'),'ExecIsTriggerDisabled')



--------------------------------------------------------
-- Listing Triggers
SELECT SubString(S2.Name,1,30) as [Table],
  SubString(S.Name, 1,30) as [Trigger],
  CASE (SELECT -- Correlated subquery
         OBJECTPROPERTY(OBJECT_ID(S.Name),
           'ExecIsTriggerDisabled'))
    WHEN 0 THEN 'Enabled'
    WHEN 1 THEN 'Disabled'
  END AS Status
  FROM Sysobjects S
    JOIN Sysobjects S2
      ON S.parent_obj = S2.ID
  WHERE S.Type = 'TR'
  ORDER BY [Table], [Trigger]


-------------------------------------------------------
-- Working with the Transaction

-- Determining the Updated Columns

ALTER TRIGGER TriggerOne ON Person
AFTER Insert, Update
AS 
IF Update(LastName)
  PRINT 'You modified the LastName column'
ELSE 
  PRINT 'The LastName column is untouched.'


UPDATE Person
  SET LastName = 'Johnson'
  WHERE PersonID = 25

UPDATE Person
  SET FirstName = 'Joe'
  WHERE PersonID = 25


-- Columns Updated

CREATE FUNCTION dbo.GenColUpdated 
  (@Col INT, @ColTotal INT)
RETURNS INT
AS
BEGIN
-- Copyright 2001 Paul Nielsen
-- This function simulates the Columns_Updated() behavior
DECLARE
  @ColByte INT,
  @ColTotalByte INT,
  @ColBit INT

  -- Calculate Byte Positions
  SET @ColTotalByte = 	1 + ((@ColTotal-1) /8)
  SET @ColByte = 1 + ((@Col-1)/8)
  SET @ColBit = @col - ((@colByte-1) * 8)

  RETURN Power(2, @colbit + ((@ColTotalByte-@ColByte) * 8)-1)
END

-- Inserted and Deleted Tables

USE Family
ALTER TRIGGER TriggerOne ON Person
AFTER Insert, Update
AS 
SET NoCount ON
IF Update(LastName)
  SELECT 'You modified the LastName column to ' + Inserted.LastName
    FROM Inserted

UPDATE Person
  SET LastName = 'Johnson'
  WHERE PersonID = 32

-- Developing Multi-Row Enabled–Triggers
ALTER TRIGGER TriggerOne ON Person
AFTER Insert, Update
AS
SELECT D.LastName + ' changed to ' + I.LastName
  FROM Inserted I
    JOIN Deleted D
      ON I.PersonID = D.PersonID

UPDATE Person
  SET LastName = 'Carter'
  WHERE LastName = 'Johnson'

-------------------------------------------------
-- Multiple-Trigger Interaction

-- Nested Triggers

EXEC sp_configure 'Nested Triggers', 1
Reconfigure


--------------------------------------------------
-- Recursive Triggers
USE OBXKites

ALTER DATABASE OBXKites SET RECURSIVE_TRIGGERS ON 
-- assumes created and modified date columns have been added to the Product table. 
CREATE TRIGGER Products_ModifiedDate ON dbo.Product 
FOR UPDATE
AS
  SET NoCount ON
  PRINT Trigger_NestLevel()
  If Trigger_NestLevel() > 1
    RETURN	
  IF (UPDATE(Created) or UPDATE(Modified)) 
       AND Trigger_NestLevel() = 1
    BEGIN
      RAISERROR('Update failed.', 16, 1)
      ROLLBACK
      RETURN
    END
  /* Update the Modified date */
  UPDATE Product 
    SET modified = getdate() 
    FROM Product  
      JOIN Inserted
        ON Product.ProductID = Inserted.ProductID
-- end of trigger 
goGo

UPDATE PRODUCT 
  SET [Name] = 'Modifed Trigger'
  WHERE Code = '1002'

SELECT Code, Created, Modified
  FROM Product
  WHERE Code = '1002'

-- Multiple after Triggers
sp_settriggerorder 
  @triggername = 'TriggerName', 
  @order = 'first' or 'last' or 'none', 
  @stmttype = 'INSERT' or 'UPDATE' or 'DELETE' 






























