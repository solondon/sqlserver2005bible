
-----------------------------------------------------------
-- SQL Server 2005 Bible 
-- Hungry Minds 
-- Paul Nielsen

-- Cape Hatteras Adventures v.2 sample database - CREATE
-- July 28, 2001

-- this script will drop an existing CHA2 database 
-- and create a fresh new installation

-- T-SQL KEYWORDS go
-- DatabaseNames	

-----------------------------------------------------------
-----------------------------------------------------------
-- Drop and Create Database


USE master
gO
IF EXISTS (SELECT * FROM SysDatabases WHERE NAME='CHA2')
		DROP DATABASE CHA2
go

-- This creates the database data file and log file on the default directories
CREATE DATABASE CHA2
go

use CHA2
go


-----------------------------------------------------------
-----------------------------------------------------------
-- Create Tables, in order from primary to secondary

CREATE TABLE dbo.Guide (
  GuideID INT IDENTITY NOT NULL PRIMARY KEY NONCLUSTERED,
  LastName  VARCHAR(50) NOT NULL,
  FirstName  VARCHAR(50) NOT NULL,
  Qualifications  VARCHAR(2048) NULL,
  DateOfBirth  DATETIME NULL,
  DateHire  DATETIME NULL
   ) 
  ON [Primary]
go
CREATE CLUSTERED INDEX IxGuideName 
  ON dbo.Guide (LastName, FirstName)
CREATE NONCLUSTERED INDEX IxGuideHire 
  ON dbo.Guide (DateHire)
ALTER TABLE dbo.Guide ADD CONSTRAINT
  CK_Guide_Age21 CHECK (DateDiff(yy,DateOfBirth, DateHire) >= 21)
go

---------------------
CREATE TABLE dbo.BaseCamp (
  BaseCampID  INT IDENTITY NOT NULL PRIMARY KEY NONCLUSTERED,
  Name  VARCHAR(50) NOT NULL,
  GuideID  INT NULL FOREIGN KEY REFERENCES dbo.Guide,
  Address  VARCHAR(255) NULL,
  City  VARCHAR(50) NULL,
  Region  VARCHAR(50) NULL,
  Country  VARCHAR(50) NULL,
  PostalCode  VARCHAR(50) NULL,
  Phone  VARCHAR(50) NULL,
  EmergencyContact  VARCHAR(50) NULL,
  ) 
  ON [Primary]
go
CREATE CLUSTERED INDEX IxBaseName 
  ON dbo.BaseCamp (Name)
CREATE NONCLUSTERED INDEX IxBaseGuide 
  ON dbo.BaseCamp (GuideID)
Go

---------------------
CREATE TABLE dbo.Tour (
  TourID  INT IDENTITY NOT NULL PRIMARY KEY NONCLUSTERED,
  BaseCampID  INT NOT NULL, -- FOREIGN KEY REFERENCES dbo.BaseCamp,
  Name  VARCHAR(50) NOT NULL,
  Days  INT NULL,
  Description  NVARCHAR(1024) NULL
   ) 
  ON [Primary]
go
CREATE CLUSTERED INDEX IxTourName 
  ON dbo.Tour (Name)
CREATE NONCLUSTERED INDEX IxTourBase 
  ON dbo.Tour (BaseCampID)
Go

---------------------
CREATE TABLE dbo.Event (
  EventID  INT IDENTITY NOT NULL PRIMARY KEY NONCLUSTERED,
  TourID  INT NOT NULL FOREIGN KEY REFERENCES dbo.Tour,
  Code  VARCHAR(10) NOT NULL,
  DateBegin  DATETIME NULL,
  Comment  NVARCHAR(255)
   ) 
  ON [Primary]
go
CREATE CLUSTERED INDEX IxEventTour 
  ON dbo.Event (TourID)
CREATE NONCLUSTERED INDEX IxEventDate 
  ON dbo.Event (DateBegin)
Go

---------------------
CREATE TABLE dbo.Tour_mm_Guide (
  TourGuideID INT IDENTITY NOT NULL PRIMARY KEY NONCLUSTERED,
  TourID INT NOT NULL FOREIGN KEY REFERENCES dbo.Tour(TourID) ON DELETE CASCADE,
  GuideID INT NOT NULL FOREIGN KEY REFERENCES dbo.Guide ON DELETE CASCADE,
  QualDate DATETIME NOT NULL,
  RevokeDate DATETIME NULL	
  ) 
  ON [Primary]
go
CREATE CLUSTERED INDEX IxTourGuideTour 
  ON dbo.Tour_mm_Guide (GuideID, TourID)
CREATE NONCLUSTERED INDEX IxTourGuideGuide 
  ON dbo.Tour_mm_Guide (TourID, GuideID)
Go

---------------------
CREATE TABLE dbo.Event_mm_Guide (
  EventGuideID INT IDENTITY NOT NULL PRIMARY KEY NONCLUSTERED,
  EventID INT NOT NULL FOREIGN KEY REFERENCES dbo.Event ON DELETE CASCADE,
  GuideID INT NOT NULL FOREIGN KEY REFERENCES dbo.Guide ON DELETE CASCADE,
  IsLead BIT NOT NULL DEFAULT 0
  ) 
  ON [Primary]
go
CREATE CLUSTERED INDEX IxEventGuideEvent 
	ON dbo.Event_mm_Guide (EventID, GuideID)
CREATE NONCLUSTERED INDEX IxEventGuideGuide 
	ON dbo.Event_mm_Guide (GuideID, EventID)
go

---------------------
CREATE TABLE dbo.CustomerType (
   CustomerTypeID INT IDENTITY NOT NULL PRIMARY KEY NONCLUSTERED,
   Name NVARCHAR(25) NOT NULL,
   DiscountPercentage NUMERIC(4,2) NOT NULL DEFAULT 0,
   IsMailList BIT NOT NULL DEFAULT 1
   ) 
   ON [Primary]
go
CREATE CLUSTERED INDEX IxCustomerTypeName 
	ON dbo.CustomerType (Name)
go

---------------------
CREATE TABLE dbo.Customer (
   CustomerID INT IDENTITY NOT NULL PRIMARY KEY NONCLUSTERED,
   CustomerTypeID INT NULL FOREIGN KEY REFERENCES dbo.CustomerType,
   LastName VARCHAR(50) NOT NULL,
   FirstName VARCHAR(50) NOT NULL,
   Nickname VARCHAR(50) NULL,
   Address VARCHAR(255) NULL,
   City VARCHAR(50) NULL,
   Region VARCHAR(50) NULL,
   Country VARCHAR(50) NULL,
   PostalCode VARCHAR(50) NULL,
   Phone VARCHAR(50) NULL,
   email VARCHAR(50) NULL,
   EmergencyContact VARCHAR(50) NULL,
   EmergencyPhone VARCHAR(50) NULL,
   Medical VARCHAR(256) NULL,
   MedicalReleaseDate DATETIME NULL,
   Comments VARCHAR(512) NULL,
   FirstTour DATETIME NULL
   ) 
   ON [Primary]
go
CREATE CLUSTERED INDEX IxCustomerName 
  ON dbo.Customer (LastName, FirstName)
CREATE NONCLUSTERED INDEX IxCustomerPostalCode 
  ON dbo.Customer (PostalCode)
CREATE NONCLUSTERED INDEX IxCustomerLocation 
  ON dbo.Customer (Country, Region, City)
CREATE NONCLUSTERED INDEX IxCustomerFirstTour
  ON dbo.Customer (FirstTour)
CREATE NONCLUSTERED INDEX IxCustomerNickName 
  ON dbo.Customer (NickName)
CREATE NONCLUSTERED INDEX IxCustomerType 
  ON dbo.Customer (CustomerTypeID)
go

---------------------
CREATE TABLE dbo.Event_mm_Customer (
  EventCustomerID INT IDENTITY NOT NULL PRIMARY KEY NONCLUSTERED,
  EventID INT NOT NULL FOREIGN KEY REFERENCES dbo.Event ON DELETE CASCADE,
  CustomerID INT NOT NULL FOREIGN KEY REFERENCES dbo.Customer ON DELETE CASCADE,
  ConfirmDate DATETIME NULL,
  IsParticipate BIT NOT NULL DEFAULT 0,
  Comments	VarChar(255)
    ) 
	ON [Primary]
go
CREATE CLUSTERED INDEX IxEventCustomerEvent ON dbo.Event_mm_Customer (
  EventID, CustomerID)
CREATE NONCLUSTERED INDEX IxEventCustomerCustomer ON dbo.Event_mm_Customer (
  CustomerID, EventID)
go







-----------------------------------------------------------
-----------------------------------------------------------
-- Create Views

CREATE VIEW dbo.vTableRowCount
as
SELECT TOP 100 PERCENT dbo.sysobjects.[name], dbo.sysindexes.[rows]
  FROM dbo.sysindexes 
  JOIN dbo.sysobjects 
    ON dbo.sysindexes.[id] = dbo.sysobjects.[id]
  WHERE (dbo.sysobjects.xtype = 'U') 
    AND (dbo.sysindexes.indid = 0 
    OR dbo.sysindexes.indid = 1)
  ORDER BY dbo.sysindexes.[name]
go

create VIEW dbo.EventList
AS
SELECT   Event.Code, 
    convert(nvarchar(20),Event.DateBegin,107) as Date, Tour.Name AS Tour, 
    BaseCamp.Name AS BaseCamp, Event.Comment
  FROM dbo.Tour 
    JOIN dbo.Event 
      ON dbo.Tour.TourID = dbo.Event.TourID 
    JOIN dbo.BaseCamp 
      ON dbo.Tour.BaseCampID = dbo.BaseCamp.BaseCampID
go
-----------------------------------------------------------
-----------------------------------------------------------
-- Stored Procedures

CREATE PROC sp_GetLocks
AS
CREATE TABLE #locks
  (spid INT,
  dbid INT,
  objid INT,
  indid INT,
  type CHAR(5),
  Resource NVARCHAR(255),
  Mode NVARCHAR(255),
  Status NVARCHAR(255))

INSERT #Locks 
  EXEC sp_lock

SELECT  P.loginame, P.spid, l.dbid AS 'Database', S.Name AS 'Object' ,P.cmd, 
    l.type AS 'LockSize', l.mode AS 'LockMode', l.status, P.blocked, P.waittime
  FROM #Locks L
    JOIN sysobjects S
      ON L.ObjID = S.ID
    JOIN Master.dbo.sysprocesses P
      ON L.spid = P.spid
    ORDER BY p.loginame,P.spid, P.dbid, s.Name
RETURN
go 
