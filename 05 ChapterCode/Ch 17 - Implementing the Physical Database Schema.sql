-----------------------------------------------------------
-- SQL Server 2005 Bible 
-- Wiley Publishing 
-- Paul Nielsen

-- Chapter 17 Implementing the Physical Design

-----------------------------------------------------------
-----------------------------------------------------------


--------------------------------------------
-- Creating the Database

-- The Create DDL Command
CREATE DATABASE NewDB;

DROP DATABASE NewDB;

-- Configuring File Growth
CREATE DATABASE NewDB
ON 
PRIMARY
  (NAME = NewDB,
    FILENAME = 'c:\SQLData\NewDB.mdf',
      SIZE = 10MB,
      MAXSIZE = 2Gb,
      FILEGROWTH = 20)
LOG ON 
  (NAME = NewDBLog,
    FILENAME = 'c:\SQLData\NewDBLog.ldf',
      SIZE = 5MB,
      MAXSIZE = 1Gb,
      FILEGROWTH = 10%);

-- Manually Grow a File
ALTER DATABASE NewDB
  MODIFY FILE 
    (Name = NewDB,
    SIZE = 25MB,
    MAXSIZE = 2Gb,
    FILEGROWTH = 0);
  
-- Creating a Database with Multiple Files
DROP DATABASE NewDB;

CREATE DATABASE NewDB
ON 
PRIMARY
  (NAME = NewDB,
    FILENAME = 'c:\SQLData\NewDB.mdf'),
  (NAME = NewDB2,
    FILENAME = 'c:\SQLData\NewDB2.ndf')
LOG ON 
  (NAME = NewDBLog,
    FILENAME = 'c:\SQLData\NewDBLog.ldf'),
  (NAME = NewDBLog2,
    FILENAME = 'c:\SQLData\NewDBLog2.ldf');

-- Modifying the Files of an Existing Database 
ALTER DATABASE NewDB
  ADD FILE 
    (NAME = NewDB3,
      FILENAME = 'c:\SQLData\NewDB3.ndf',
      SIZE = 10MB,
      MAXSIZE = 2Gb,
      FILEGROWTH = 20);

DBCC SHRINKFILE (NewDB3, EMPTYFILE)
ALTER DATABASE NewDB
  REMOVE FILE NewDB3;

--- Creating a Database with Filegroups
CREATE DATABASE NewDB
ON 
PRIMARY
  (NAME = NewDB,
    FILENAME = 'd:\SQLData\NewDB.mdf',
      SIZE = 50MB,
      MAXSIZE = 5Gb,
      FILEGROWTH = 25MB),
FILEGROUP GroupTwo
  (NAME = NewDBGroup2,
    FILENAME = 'e:\SQLData\NewDBTwo.ndf',
      SIZE = 50MB,
      MAXSIZE = 5Gb,
      FILEGROWTH = 25MB)
LOG ON 
  (NAME = NewDBLog,
    FILENAME = 'f:\SQLServerBible\NewDBLog.ndf',
      SIZE = 100MB,
      MAXSIZE = 25Gb,
      FILEGROWTH = 25MB);

-- Dropping a Database
-- DROP DATABASE NewDB;

---------------------------------------
-- Creating Tables

USE NewDB;

CREATE TABLE Test (col1 INT IDENTITY);

-- insert some test data into NewDB
DECLARE @X INT
SET @X = 0
WHILE @X < 1000
  BEGIN
    INSERT Test DEFAULT VALUES
    SET @X = @X + 1
  END

SELECT COUNT(*) FROM Test

DBCC SHRINKFILE (NewDB3, EMPTYFILE)
ALTER DATABASE NewDB
  REMOVE FILE NewDB3

-- FileGroups
USE Master
DROP DATABASE NewDB
go
CREATE DATABASE NewDB
ON 
PRIMARY
  (NAME = NewDB,
    FILENAME = 'c:\SQLServerBible\NewDB.mdf',
      SIZE = 10MB,
      MAXSIZE = 2Gb,
      FILEGROWTH = 20),
FILEGROUP GroupTwo
  (NAME = NewDBGroup2,
    FILENAME = 'c:\SQLServerBible\NewDBTwo.ndf',
      SIZE = 10MB,
      MAXSIZE = 2Gb,
      FILEGROWTH = 20)
LOG ON 
  (NAME = NewDBLog,
    FILENAME = 'c:\SQLServerBible\NewDBLog.ndf',
      SIZE = 5MB,
      MAXSIZE = 1Gb,
      FILEGROWTH = 10%)

---------------------------------------------------
-- Creating Tables
-- sample code pulled from OBXKites database

CREATE TABLE dbo.ProductCategory (
  ProductCategoryID UNIQUEIDENTIFIER NOT NULL 
    ROWGUIDCOL DEFAULT (NEWID()) PRIMARY KEY NONCLUSTERED,
  ProductCategoryName NVARCHAR(50) NOT NULL,
  ProductCategoryDescription NVARCHAR(100) NULL
  )
  ON [Primary]

-- Filegroups
CREATE TABLE dbo.OrderPriority (
  OrderPriorityID UNIQUEIDENTIFIER NOT NULL 
    ROWGUIDCOL DEFAULT (NEWID()) PRIMARY KEY NONCLUSTERED,
  OrderPriorityName NVARCHAR (15) NOT NULL,
  OrderPriorityCode NVARCHAR (15) NOT NULL,
  Priority INT NOT NULL
  )
  ON [Static]


----------------------------------------------------------
-- Creating Primary Keys

-- Creating Primary Keys
CREATE TABLE dbo.Guide (
  GuideID INT IDENTITY NOT NULL PRIMARY KEY NONCLUSTERED,
  LastName  VARCHAR(50) NOT NULL,
  FirstName  VARCHAR(50) NOT NULL,
  Qualifications  VARCHAR(2048) NULL,
  DateOfBirth  DATETIME NULL,
  DateHire  DATETIME NULL
  ) 
  ON [Primary]

ALTER TABLE dbo.Guide ADD CONSTRAINT
  PK_Guide PRIMARY KEY NONCLUSTERED(GuideID)
  ON [PRIMARY]

-- Identity Column Surrogate Primary Keys
CREATE TABLE dbo.Event (
	EventID INT IDENTITY NOT NULL PRIMARY KEY NONCLUSTERED,
	TourID INT NOT NULL FOREIGN KEY REFERENCES dbo.Tour,
	EventCode VARCHAR(10) NOT NULL,
	DateBegin DATETIME NULL,
	Comment NVARCHAR(255)
 	) 
	ON [Primary]

-- Using Uniqueidentifier Surrogate Primary Keys
-- sample code taken from OBXKites database
CREATE TABLE Product (
  ProductID UNIQUEIDENTIFIER NOT NULL 
    ROWGUIDCOL DEFAULT (NEWID()) 
    PRIMARY KEY NONCLUSTERED,
  ProductCategoryID UNIQUEIDENTIFIER NOT NULL 
    FOREIGN KEY REFERENCES dbo.ProductCategory, 
  ProductCode CHAR(15) NOT NULL,   
  ProductName NVARCHAR(50) NOT NULL,
  ProductDescription NVARCHAR(100) NULL,
  ActiveDate DATETIME NOT NULL DEFAULT GETDATE(),
  DiscountinueDate DATETIME NULL
  )
  ON [Static]

-- Creating Foreign Keys
-- sample code pulled from CHA2 database
CREATE TABLE dbo.Tour_mm_Guide (
	TourGuideID INT 
    IDENTITY 
    NOT NULL 
    PRIMARY KEY NONCLUSTERED,
	TourID INT 
    NOT NULL 
    FOREIGN KEY REFERENCES dbo.Tour(TourID) 
    ON DELETE CASCADE,
	GuideID INT 
    NOT NULL 
    FOREIGN KEY REFERENCES dbo.Guide 
    ON DELETE CASCADE,
	QualDate DATETIME NOT NULL,
	RevokeDate DATETIME NULL	
	)
	ON [Primary]

-- sample code pulled from Family database
CREATE TABLE dbo.Person (
  PersonID  INT NOT NULL PRIMARY KEY NONCLUSTERED,
  LastName  VARCHAR(15) NOT NULL,
  FirstName  VARCHAR(15) NOT NULL,
  SrJr  VARCHAR(3) NULL,
  MaidenName VARCHAR(15) NULL,
  Gender CHAR(1) NOT NULL, 
  FatherID INT NULL,
  MotherID INT NULL,
  DateOfBirth  DATETIME  NULL,
  DateOfDeath  DATETIME  NULL
  )
go
ALTER TABLE dbo.Person 
  ADD CONSTRAINT FK_Person_Father 
    FOREIGN KEY(FatherID) REFERENCES dbo.Person (PersonID)
ALTER TABLE dbo.Person 
  ADD CONSTRAINT FK_Person_Mother 
    FOREIGN KEY(MotherID) REFERENCES dbo.Person (PersonID)


-- Cascading Deletes and Updates
-- sample code pulled from OBXKites database
CREATE TABLE dbo.OrderDetail (
  OrderDetailID UNIQUEIDENTIFIER 
    NOT NULL 
    ROWGUIDCOL 
    DEFAULT (NEWID()) 
    PRIMARY KEY NONCLUSTERED,
  OrderID UNIQUEIDENTIFIER   
    NOT NULL 
    FOREIGN KEY REFERENCES dbo.[Order] 
      ON DELETE CASCADE, 
  ProductID UNIQUEIDENTIFIER   
    NULL 
    FOREIGN KEY REFERENCES dbo.Product,


-------------------------------------------------------
-- Creating User-Data Columns

ALTER TABLE TableName
  ADD ColumnName DATATYPE Attributes


-- Calculated Columns
CREATE TABLE dbo.OrderDetail (
  Quantity NUMERIC(7,2) NOT NULL,
  UnitPrice MONEY NOT NULL,
  ExtendedPrice AS Quantity * UnitPrice Persisted, 
  ) 
  ON [Primary];


-- Column Nullability

-- ANSI Nullability
USE TempDB
--ANSI Default Column Nullability Column DEFAULT
SELECT DATABASEPROPERTYEX('TempDB','IsAnsiNullDefault')
EXEC sp_dboption 'TempDB', ANSI_NULL_DEFAULT, 'false'
SET ANSI_NULL_DFLT_OFF ON 

DROP TABLE NullTest

CREATE TABLE NullTest(
  PK INT IDENTITY,
  One VARCHAR(50)
  )

INSERT NullTest(One)
  VALUES (NULL)  -- should receive null error

EXEC sp_dboption 'TempDB', ANSI_NULL_DEFAULT, 'true'
SET ANSI_NULL_DFLT_ON ON 

DROP TABLE NullTest

CREATE TABLE NullTest(
  PK INT IDENTITY,
  One VARCHAR(50)
  )

INSERT NullTest(One)
  VALUES (NULL) -- allows nulls

--------------------------------------------------------
-- Unique Constraints

USE TempDB

CREATE TABLE Employee (
  EmployeeID INT PRIMARY KEY NONCLUSTERED,
  EmployeeNumber CHAR(8) UNIQUE (EmployeeNumber),
  LastName NVARCHAR(35),
  FirstName NVARCHAR(35)
  )

ALTER TABLE Employee
  ADD CONSTRAINT EmpNumUnique
    UNIQUE (EmployeeNumber)

Insert Employee (EmployeeID, EmployeeNumber, LastName, FirstName)
  Values( 1, '1', 'Wilson', 'Bob')

Insert Employee (EmployeeID, EmployeeNumber, LastName, FirstName)
  Values( 2, '1', 'Smith', 'Joe') -- unique constraint error

--------------------------------------------------------
-- Check Constraints
Drop Table Employee

CREATE TABLE Employee (
  EmployeeID INT PRIMARY KEY NONCLUSTERED,
  EmployeeNumber CHAR(8) CHECK (EmployeeNumber <> '1'),
  LastName NVARCHAR(35),
  FirstName NVARCHAR(35)
  )

Insert Employee (EmployeeID, EmployeeNumber, LastName, FirstName)
  Values( 2, '1', 'Smith', 'Joe') -- violates check constraint

ALTER TABLE Employee
  ADD CONSTRAINT NoHireSmith
    CHECK (Lastname <> 'SMITH')

Insert Employee (EmployeeID, EmployeeNumber, LastName, FirstName)
  Values( 4, '4', 'Smith', 'Joe') -- violates check constraint

---------------------------------------------------------
-- Default Option

USE OBXKites

ALTER TABLE Product
  DROP CONSTRAINT DF__Product__ActiveD__7F60ED59

ALTER TABLE Product
  ADD CONSTRAINT  ActiveDefault 
  DEFAULT GetDate() FOR ActiveDate 

---------------------------------------------------------
-- Data Catalog

sp_help person

-- User Defined Rules (example only - not to be applied to any sample database)
CREATE RULE BirthdateRule AS @Birthdate <= Getdate()
go
EXEC sp_bindrule 
  @rulename = 'BirthdateRule', 
  @objname =  'Person.DateOfBirth'
 
go

-- User Defined Default (example only - not to be applied to any sample database)
CREATE DEFAULT HireDefault AS Getdate()
go
sp_bindefault 'HireDefault', 'Contact.Hiredate'
go

-- User Defined Data Type (example only - not to be applied to any sample database)
EXEC sp_addtype 
  @typename = Birthdate,
  @phystype = SmallDateTime,
  @nulltype = 'NOT NULL'
go
sp_bindefault 
  @defname = 'BirthdateDefault', 
  @objname =  'Birthdate', 
  @futureonly =  'futureonly'

sp
EXEC sp_bindrule 
  @rulename = 'BirthdateRule', 
  @objname =  'Birthdate' 

----------------------------------------------
-- DDL Triggers

USE CHA2;

CREATE TABLE SchemaAudit (
  AuditDate DATETIME NOT NULL,
  UserName VARCHAR(50) NOT NULL,
  Object VARCHAR(50) NOT NULL,
  DDLStatement VARCHAR(max) NOT NULL
  )
go

CREATE TRIGGER SchemaAudit
ON DATABASE
FOR CREATE_TABLE, ALTER_TABLE, DROP_TABLE
AS 

DECLARE @EventData XML
SET @EventData = EventData()
 
INSERT SchemaAudit (AuditDate, UserName, Object, DDLStatement)
SELECT 
  GetDate(),
  @EventData.value('data(/EVENT_INSTANCE/UserName)[1]', 'SYSNAME'),
  @EventData.value('data(/EVENT_INSTANCE/ObjectName)[1]', 'VARCHAR(50)'),
  @EventData.value('data(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]', 'VARCHAR(max)')

GO

CREATE TABLE Test (
  PK INT NOT NULL
  )
GO
DROP TABLE Test

SELECT * FROM SchemaAudit

-- Enabling and Disabling DDL Triggers
DISABLE TRIGGER SchemaAudit
ON CHA2;

ENABLE TRIGGER SchemaAudit
ON CHA2;

  



















  
