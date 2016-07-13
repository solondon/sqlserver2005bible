
-----------------------------------------------------------
-- SQL Server 2005 Bible 
-- Wiley Publishing 
-- Paul Nielsen

-- Chapter 16 - Modifying Data


-----------------------------------------------------------
-----------------------------------------------------------
-- Inserting Data

USE CHA2 
-- run CHA2_Create to generate the database
-- and CHA2_Convert to populate the database

-- Inserting One Row of Values
INSERT INTO dbo.Guide (LastName, FirstName, Qualifications)
  VALUES ('Smith', 'Dan', 'Diver, Whitewater Rafting')

INSERT INTO dbo.Guide (FirstName, LastName, Qualifications)
  VALUES ('Jeff', 'Davis', 'Marine Biologist, Diver')

INSERT INTO dbo.Guide (FirstName, LastName)
  VALUES ('Tammie', 'Commer')

SELECT * from dbo.Guide

-- INSERT/VALUES without a insert column listing
INSERT dbo.Guide 
  VALUES ('Jones', 'Lauren', 'First Aid, Rescue/Extraction','6/25/59','4/15/01')

SELECT GuideID, LastName, FirstName, Qualifications 
  FROM dbo.Guide


-- INSERT/VALUES an expression
INSERT dbo.Guide (FirstName, LastName, Qualifications)
  VALUES ('Greg', 'Wilson' , 'Rock Climbing' + ', ' + 'First Aid')

SELECT * from dbo.Guide

-----------------------------------------------------------
-- Inserting a Result Set from Select

USE OBXKites
-- Using a fresh copy of OBXKites without population

--(Corrected from the text - added ContactCode)
INSERT dbo.Contact (FirstName, ContactCode, LastName, CompanyName)
  SELECT FirstName, LastName, GuideID, 'Cape Hatteras Adv.' 
    FROM CHA2.dbo.Guide

SELECT ContactID, FirstName AS FIRST, LastName AS LAST , CompanyName 
  FROM dbo.Contact


-----------------------------------------------------------
-- Inserting the Result Set from a Stored Procedure

Use CHA2
Go
-- create the sample stored procedure
CREATE PROC ListGuides
AS
	SET NOCOUNT ON
	-- result set 1
	SELECT  FirstName, LastName
	  FROM dbo.Guide
	-- result set 2
	SELECT  FirstName, LastName 
	  FROM northwind.dbo.employees
	RETURN

go

-- test the sample stored procedure
Exec ListGuides

go
-- create a table for the insert
CREATE TABLE  dbo.GuideSample
  (FirstName VARCHAR(20),
    LastName VARCHAR(20) )

-- the insert / exec statement
INSERT GuideSample ( FirstName, LastName)
  EXEC ListGuides

-- check to see that the insert worked
SELECT * FROM GuideSample 

-----------------------------------------------------------
-- Creating a Table While Inserting Data
USE CHA2

-- sample code for setting the bulk-logged behavior
Alter DATABASE CHA2 SET RECOVERY FULL
EXEC SP_DBOPTION 'CHA2', 'select into/bulkcopy', 'TRUE'
go

-- the select/into statement
SELECT * INTO dbo.GuideList
  FROM dbo.Guide
  ORDER BY Lastname, FirstName
Go
-- viewing the data structure of the new table
sp_help GuideList

--testing the identity column of the new table
INSERT dbo.Guidelist (LastName, FirstName, Qualifications)
  VALUES('Nielsen', 'Paul','trainer')

SELECT GuideID, LastName, FirstName 
  FROM dbo.GuideList

-----------------------------------------------------------
-- Updating Data

-- Updating a single column of a single row
USE CHA2
UPDATE dbo.Guide 
  SET Qualifications = 'Spelunking, Cave Diving, Rock Climbing, First Aid, Navigation'
  Where GuideID = 6 

SELECT GuideID, LastName, Qualifications 
  FROM dbo.Guide
  WHERE GuideID = 6

-- Global Search and Replace
Use Family

Update Person
  Set LastName = Replace(Lastname, 'll', 'qua')

Select lastname from Person

--ANSI Standard alternative to Delete From
DELETE FROM Table1 a
  WHERE EXISTS (SELECT * 
                  FROM Table2 b 
                  WHERE 
                      EMPL_STATUS = 'A' 
                    AND 
                      a.EMPLID = b.EMPLID
                ) 

-----------------------------------------------------------
-- A complex update with expression

CREATE TABLE dbo.Dept (
  DeptID INT IDENTITY NOT NULL PRIMARY KEY NONCLUSTERED,
  DeptName VARCHAR(50) NOT NULL,
  RaiseFactor NUMERIC(4,2)
   ) 
  ON [Primary]
go

Create  TABLE dbo.Employee (
  EmployeeID INT IDENTITY NOT NULL PRIMARY KEY NONCLUSTERED,
  DeptID INT FOREIGN KEY REFERENCES Dept, 
  LastName VARCHAR(50) NOT NULL,
  FirstName VARCHAR(50) NOT NULL,
  Salary INT,
  PerformanceRating NUMERIC(4,2),
  DateHire DATETIME,
  DatePosition DATETIME
   ) 
  ON [Primary]
go
 -- build the sample data
INSERT dbo.Dept VALUES ('Engineering', 1.2)
INSERT dbo.Dept VALUES ('Sales',.8)
INSERT dbo.Dept VALUES ('IT',2.5)
INSERT dbo.Dept VALUES ('Manufacturing',1.0)
go
INSERT dbo.Employee VALUES( 1, 'Smith', 'Sam', 54000, 2.0, '1/1/97', '4/1/2001' )
INSERT dbo.Employee VALUES( 1, 'Nelson', 'Slim', 78000, 1.5, '9/1/88', '1/1/2000' )
INSERT dbo.Employee VALUES( 2, 'Ball', 'Sally', 45000, 3.5, '2/1/99', '1/1/2001' )
INSERT dbo.Employee VALUES( 2, 'Kelly', 'Jeff', 85000, 2.4, '10/1/83','9/1/1998' )
INSERT dbo.Employee VALUES( 3, 'Guelzow', 'Dave', 120000, 4.0, '7/1/95', '6/1/2001' )
INSERT dbo.Employee VALUES( 3, 'Cliff', 'Melissa', 95000, 1.8, '2/1/99', '9/1/1997' )
INSERT dbo.Employee VALUES( 4, 'Reagan', 'Frankie', 75000, 2.9, '4/1/00', '4/1/2000' )
INSERT dbo.Employee VALUES( 4, 'Adams', 'Hank', 34000, 3.2, '9/1/98', '9/1/1998' )
go 

-- assume raise date is 5/1/2002
SELECT * from dbo.Dept
SELECT * from dbo.Employee

-- test required data
SELECT   LastName, Salary,
  DateDiff(yy, DateHire, '5/1/2002') as YearsCompany,
  DateDiff(mm, DatePosition, '5/1/2002') as MonthPosition,
  CASE   
    WHEN Employee.PerformanceRating >= 2 THEN Employee.PerformanceRating
    ELSE 0
  END as Performance, 
  Dept.RaiseFactor
  FROM dbo.Employee
  JOIN dbo.Dept 
    ON Employee.DeptID = Dept.DeptID

-- Test the raise amount 
SELECT   LastName, 
  (2 + (((DateDiff(yy, DateHire, '5/1/2002') * .1)
  + (DateDiff(mm, DatePosition, '5/1/2002') * .02)
  + (CASE   
      WHEN Employee.PerformanceRating >= 2 THEN Employee.PerformanceRating
      ELSE 0
     END * .5 ))
   * Dept.RaiseFactor))/100 as EmpRaise
  FROM dbo.Employee
  JOIN dbo.Dept 
    ON Employee.DeptID = Dept.DeptID

-- Perform the Update 
Update Employee Set Salary = Salary * (1 + 
  (2 + (((DateDiff(yy, DateHire, '5/1/2002') * .1)
  + (DateDiff(mm, DatePosition, '5/1/2002') * .02)
  + (CASE   
      WHEN Employee.PerformanceRating >= 2 THEN Employee.PerformanceRating
      ELSE 0
     END * .5 ))
   * Dept.RaiseFactor))/100 )
  FROM dbo.Employee
  JOIN dbo.Dept 
    ON Employee.DeptID = Dept.DeptID


SELECT FirstName, LastName, Salary
  FROM dbo.Employee
Go


Drop Table dbo.Employee
Go
Drop table dbo.Dept 

-----------------------------------------------------------
-- Deleting Data

DELETE FROM OBXKites.dbo.Product

USE OBXKites

DELETE FROM dbo.Product 
  WHERE ProductID = 'DB8D8D60-76F4-46C3-90E6-A8648F63C0F0'

-- delete all the product in the books category
DELETE Product
  FROM dbo.Product
  JOIN ProductCategory
    ON Product.ProductCategoryID 
      = ProductCategory.ProductCategoryID
  WHERE ProductcategoryName = 'Video'

-- Building a foreign key with referential integrity that cascades deletes
USE CHA2

CREATE TABLE dbo.Event_mm_Guide (
  EventGuideID INT IDENTITY NOT NULL PRIMARY KEY NONCLUSTERED,
  EventID INT NOT NULL 
    FOREIGN KEY REFERENCES dbo.Event ON DELETE CASCADE,
  GuideID INT NOT NULL 
    FOREIGN KEY REFERENCES dbo.Guide ON DELETE CASCADE,
  LastName VARCHAR(50) NOT NULL,
  ) 
  ON [Primary]
go

-----------------------------------------------------------
-- Returning Modified Data

-- Returning Data from an Insert 
INSERT dbo.Guidelist (LastName, FirstName, Qualifications)
  OUTPUT Inserted.* 
  VALUES('Nielsen', 'Paul','trainer')


-- Returning Data from an Update 
USE CHA2
UPDATE dbo.Guide 
  SET Qualifications = 'Scuba'
  OUTPUT Deleted.Qualifications as OldQuals ,Inserted.Qualifications as NewQuals
  Where GuideID = 3


-- Returning Data from a Delete
DELETE dbo.Guide
  OUTPUT Deleted.GuideID, Deleted.LastName, Deleted.FirstName
  WHERE GuideID = 3

-- Returning Data into a @Table Variable 
DECLARE @DeletedGuides TABLE (
  GuideID INT,
  LastName VARCHAR(50),
  FirstName VARCHAR(50)
  )

DELETE dbo.Guide
  OUTPUT Deleted.GuideID, Deleted.LastName, Deleted.FirstName
  INTO @DeletedGuides
  WHERE GuideID = 2 

SELECT * FROM @DeletedGuides

-----------------------------------------------------------
-- Potential Data Modification Obstacles

-- Data Type Obstacle
-- (will fail because your GUID will be different)
USE OBXKites
INSERT dbo.Price (ProductID, Price, EffectiveDate)
  VALUES ('DB8D8D60-76F4-46C3-90E6-A8648F63C0F0', 15.00, 6/25/2002 )

-----------------------------------------------------------
-- INSERTing Identity Column Primary Keys
USE CHA2

INSERT dbo.Guide (GuideID, FirstName, LastName)
  VALUES (10, 'Bill', 'Fletcher')

SET IDENTITY_INSERT Guide On 

INSERT dbo.Guide (GuideID, FirstName, LastName)
  VALUES (10, 'Bill', 'Fletcher')

INSERT dbo.Guide (GuideID, FirstName, LastName)
  VALUES (7, 'Sue', 'Atlas')

SET IDENTITY_INSERT Guide Off 

INSERT dbo.Guide ( FirstName, LastName)
  VALUES ( 'Arnold', 'Bistier')

SELECT GuideID, FirstName, LastName from dbo.Guide


-- INSERTing GUID Primary Keys

USE OBXKites

SELECT NewID()

SELECT * FROM dbo.ProductCategory

--  GUID from Default
INSERT dbo.ProductCategory (ProductCategoryID, ProductCategoryName)
  VALUES (DEFAULT, 'test')

-- GUID from function
INSERT dbo.ProductCategory (ProductCategoryID, ProductCategoryName)
  VALUES (NewID(), 'FROM Function')

-- GUID from variable
Declare @NewGUID UniqueIdentifier
Set @NewGUID = NewID()

INSERT dbo.ProductCategory (ProductCategoryID, ProductCategoryName)
  VALUES (@NewGUID, 'FROM Variable')

SELECT ProductCategoryID, ProductCategoryName
  FROM dbo.ProductCategory
  Where ProductCategoryName like 'FROM %'

-- inserting multiple rows with function and select

INSERT dbo.ProductCategory (ProductCategoryID, ProductCategoryName)
  SELECT NewID(), FirstName + LastName 
  FROM CHA2.dbo.Guide

-- Foreign Key INSERT Obstacle
INSERT dbo.Product (ProductID, Code, ProductCategoryID, ProductName)
  VALUES ('9562C1A5-4499-4626-BB33-E5E140ACD2AC',
  '999',
  'DB8D8D60-76F4-46C3-90E6-A8648F63C0F0', 
  'Basic Box Kite 21"')

-- Foreign Key Update secondary row Obstacle
UPDATE dbo.Product 
  SET ProductCategoryID = 'DB8D8D60-76F4-46C3-90E6-A8648F63C0F0'
  WHERE ProductID = '67804443-7E7C-4769-A41C-3DD3CD3621D9'

-- Foreign Key Update primary row Obstacle
UPDATE dbo.ProductCategory 
  SET ProductCategoryID = 'DB8D8D60-76F4-46C3-90E6-A8648F63C0F0'
  WHERE ProductCategoryID = '1B2BBE15-B415-43ED-BCA2-293050B7EFE4'

SELECT ProductName, ProductCategoryName
  FROM PRoduct
  Join ProductCategory
    ON Product.ProductCategoryID = ProductCategory.ProductCategoryID

-- Check Constraint Obstacle
USE CHA2
Go
ALTER TABLE dbo.Guide ADD CONSTRAINT
  CK_Guide_Age21 CHECK (DateDiff(yy,DateOfBirth, DateHire) >= 21)
GO

-- Dr. Johnson's age at time of hire
SELECT DateDiff(yy,'1/14/71', '6/1/97')

INSERT dbo.Guide(lastName, FirstName, Qualifications, DateOfBirth, DateHire)
  VALUES ('Johnson', 'Mary', 'E.R. Physician', '1/14/71', '6/1/97')

--Greg's age at time of hire
SELECT DateDiff(yy,'12/12/83', '1/1/2002')

INSERT dbo.Guide(lastName, FirstName, Qualifications, DateOfBirth, DateHire)
  VALUES ('Franklin', 'Greg', 'Guide', '12/12/83', '1/1/2002')

-- Instead Of Trigger Obstacles
USE CHA2
go

CREATE TRIGGER InsteadOfDemo
ON dbo.Guide 
INSTEAD OF INSERT
AS
  Print 'Instead of trigger demo'
Return
go

INSERT dbo.Guide(lastName, FirstName, Qualifications, DateOfBirth, DateHire)
  VALUES ('Jamison', 'Tom', 'Biologist, Adventurer', '1/14/56', '9/1/99')

SELECT GuideID 
  FROM dbo.Guide
  WHERE LastName = 'Jamison'

DROP TRIGGER InsteadOfDemo

-- After Trigger Obstacles
USE CHA2
go

CREATE TRIGGER AfterDemo
ON dbo.Guide 
AFTER INSERT, UPDATE
AS
  Print 'After Trigger Demo'
  RAISERROR ('Sample Error', 16, 1 )
  ROLLBACK TRAN
Return
go

INSERT dbo.Guide(lastName, FirstName, Qualifications, DateOfBirth, DateHire)
  VALUES ('Harrison', 'Nancy', 'Pilot, Sky Diver, Hang Glider, Emergency Paramedic', '6/25/69', '7/14/2000')

DROP TRIGGER AfterDemo

-- Non-Updateable View Obstacles
Drop View dbo.vMedGuides

CREATE VIEW dbo.vMedGuide
AS
SELECT DISTINCT GuideID, LastName, Qualifications 
  FROM dbo.Guide
  WHERE Qualifications LIKE '%Aid%' 
  OR Qualifications LIKE '%medic%'
  OR Qualifications LIKE '%Physician%'

SELECT DISTINCT * 
  FROM dbo.vMedGuide

UPDATE dbo.vMedGuide
  SET Qualifications = 'E.R. Physician, Diver' 
  WHERE GuideID = 1

-- Views with-check-option Obstacles
ALTER VIEW dbo.vMedGuide
AS
SELECT GuideID, LastName, Qualifications 
  FROM Guide
  WHERE Qualifications LIKE '%Aid%' 
  OR Qualifications LIKE '%medic%'
  OR Qualifications LIKE '%Physician%'
WITH CHECK OPTION

UPDATE dbo.vMedGuide
  SET Qualifications = 'E.R. Physician, Diver' 
  WHERE GuideID = 1

UPDATE dbo.vMedGuide
  SET Qualifications = 'Diver' 
  WHERE GuideID = 1












