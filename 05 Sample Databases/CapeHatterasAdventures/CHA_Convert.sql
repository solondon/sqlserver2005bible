
-----------------------------------------------------------
-- SQL Server 2000 Bible 
-- Hungry Minds 
-- Paul Nielsen

-- Cape Hatteras Advntures v.2 sample database - Populate

-- this script will populate the CHA2 database
-- from CHA1_Customers.mdb Access file
-- and CHA1_Schedule.xls Excel Spreadsheet
-- using distributed queries

-- This script mirrors the CHA_Convert DTS package 

-----------------------------------------------------------
-----------------------------------------------------------

USE CHA2

-- establish Access Linked Server
EXEC sp_DropServer @server = 'CHA1_Customers'
go
EXEC sp_addlinkedserver 
  'CHA1_Customers', 
  'Access 2003', 
  'Microsoft.Jet.OLEDB.4.0', 
  'C:\SQLData\CHA1_Customers.mdb'
go

-- establish Excel Linked Server
EXEC sp_DropServer @server = 'CHA1_Schedule'
go
Execute sp_addlinkedserver 
  'CHA1_Schedule', 
  'Excel', 
  'Microsoft.Jet.OLEDB.4.0', 
  'C:\SQLData\CHA1_Schedule.xls',  
  NULL, 
  'Excel 5.0'
go

EXEC sp_helpserver

-- Step 0: Initialize the Database
DELETE Customer
DELETE CustomerType
DELETE Event_mm_Customer
DELETE Event_mm_Guide
DELETE Tour_mm_Guide
DELETE Event
DELETE Tour
DELETE BaseCamp
DELETE Guide

-- Step 1: Customer Types
SELECT DISTINCT CustomerType
  FROM CHA1_Customers...Customers 
  WHERE CustomerType IS NOT NULL

INSERT CustomerType(Name)
  SELECT DISTINCT CustomerType
    FROM CHA1_Customers...Customers 
    WHERE CustomerType IS NOT NULL  

SELECT * FROM CustomerType

-- Step 2: Customers
SELECT DISTINCT ContactLastName, ContactFirstName, CustomerType
  FROM CHA1_Customers...Customers 
  WHERE ContactLastName IS NOT NULL

SELECT * FROM CustomerType
SELECT * FROM CHA1_Customers...Customers

INSERT Customer(LastName, FirstName, CustomerTypeID, Address, 
    City,Country, eMail, NickName,FirstTour, Medical)
  SELECT DISTINCT ContactLastName, ContactFirstName, CustomerTypeID,BillingAddress, 
    City, Country, EMailAddress,NickName, FirstTour, HealthIssues
    FROM CHA1_Customers...Customers C
      LEFT OUTER JOIN CustomerType
        ON C.CustomerType = CustomerType.[Name]
    WHERE ContactLastName IS NOT NULL

SELECT * FROM Customer

-- Step 3: Base Camps
INSERT BaseCamp(Name)
  SELECT DISTINCT [Base Camp]
    FROM CHA1_Schedule...[Base_Camp]
    WHERE [Base Camp] IS NOT NULL

SELECT * FROM BaseCamp

-- Step 4: Tours
INSERT Tour ([Name], BaseCampID)
  SELECT DISTINCT Tour, BaseCampID
    FROM CHA1_Schedule...Tour X
      JOIN BaseCamp
        ON X.[Base Camp] = BaseCamp.Name
    WHERE Tour IS NOT NULL

SELECT * FROM Tour

-- Step 5: Guides
INSERT Guide(FirstName, LastName)
  SELECT DISTINCT 
      LEFT([Lead Guide],CharIndex(' ', [Lead Guide])-1),
      RIGHT([Lead Guide],Len([Lead Guide])-CharIndex(' ', [Lead Guide]))
    FROM CHA1_Schedule...Lead_Guide
    WHERE [Lead Guide] IS NOT NULL

SELECT * FROM Guide

-- Step 6: Events
SELECT DISTINCT *
  FROM CHA1_Schedule...Event

SELECT * FROM Event

INSERT Event (TourID, DateBegin, Code)
  SELECT DISTINCT Tour.TourID, [Date], EventCode
    FROM CHA1_Schedule...Event X
      JOIN Tour 
        ON X.Tour = Tour.Name

-- Step 7: Event_mm_Customer
SELECT * FROM Event_mm_Customer

INSERT Event_mm_Customer(CustomerID, EventID)
  SELECT DISTINCT Customer.CustomerID, Event.EventID
    FROM CHA1_Schedule...Customer X
      JOIN Customer
        ON X.LastName = Customer.LastName
          AND X.FirstName = Customer.FirstName
      JOIN Event 
        ON X.EventCode = Event.Code

-- Step 8: Event_mm_Guide
SELECT * FROM Event_mm_Guide

INSERT Event_mm_Guide(EventID, GuideID, IsLead)
  SELECT DISTINCT Event.EventID, Guide.GuideID, 1 
    FROM CHA1_Schedule...Event X
      JOIN Guide
        ON X.[Lead Guide] = Guide.FirstName + ' ' + Guide.LastName
      JOIN Event
        ON X.EventCode = Event.Code


-- Step 9: Tour_mm_Guide
INSERT Tour_mm_Guide (TourID, GuideID, QualDate)
  SELECT DISTINCT Tour.TourID, Event_mm_Guide.GuideID, '1/1/2000'
    FROM Tour
      JOIN Event
        ON Event.TourID = Tour.TourID
      JOIN Event_mm_Guide
        ON Event.EventID = Event_mm_Guide.EventID

SELECT * FROM Tour_mm_Guide

Select * from vTableRowCount