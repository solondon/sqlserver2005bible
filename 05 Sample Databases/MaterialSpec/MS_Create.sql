
-----------------------------------------------------------
-- SQL Server 2000 Bible 
-- Hungry Minds 
-- Paul Nielsen

-- Dynamic Relational Database Design
-- Material Specs Sample database - CREATE

-- this script will drop an existing MS database 
-- and create a fresh new installation

-- T-SQL KEYWORDS go
-- DatabaseNames  

-----------------------------------------------------------
-----------------------------------------------------------
-- Drop and Create Database

USE master
go
IF EXISTS (SELECT * FROM SysDatabases WHERE NAME='MS')
    DROP DATABASE MS
go

-- Create database
CREATE DATABASE MS
go

-----------------------------------------------------------
-----------------------------------------------------------
-- Create Tables, in order from primary to secondary

use MS
go

CREATE TABLE dbo.MaterialState (
  MaterialStateID  INT PRIMARY KEY NONCLUSTERED,
  Name  NVARCHAR(50) NOT NULL
  ) 
go

CREATE TABLE dbo.MaterialType (
  MaterialTypeID  INT PRIMARY KEY NONCLUSTERED,
  MaterialStateID  INT NOT NULL FOREIGN KEY REFERENCES dbo.MaterialState, 
  Name  NVARCHAR(50) NOT NULL
  ) 
go

CREATE TABLE dbo.Material (
  ProductID  INT PRIMARY KEY NONCLUSTERED,
  MaterialTypeID  INT NOT NULL FOREIGN KEY REFERENCES dbo.MaterialType, 
  Name  NVARCHAR(50) NOT NULL,
  Version  NUMERIC (4,2) NOT NULL,
  PreviousVersionID INT NULL FOREIGN KEY REFERENCES dbo.Material,
  OriginalID  INT NOT NULL FOREIGN KEY REFERENCES dbo.Material
  ) 
go

CREATE TABLE dbo.Property (
  PropertyID  INT PRIMARY KEY NONCLUSTERED,
  Name  NVARCHAR(50) NOT NULL,
  UnitOfMeasure  NVARCHAR(50) NOT NULL,
  [Description]  NVARCHAR(50) NULL
  )
go

CREATE TABLE dbo.MaterialType_mm_Property (
  PKID  INT IDENTITY PRIMARY KEY NONCLUSTERED,
  MaterialTypeID  INT NOT NULL FOREIGN KEY REFERENCES dbo.MaterialType,
  PropertyID  INT NOT NULL FOREIGN KEY REFERENCES dbo.Property 
  ) 
go

CREATE TABLE dbo.PropertyValue (
  PropertyValueID  INT PRIMARY KEY NONCLUSTERED,
  PropertyID  INT NOT NULL FOREIGN KEY REFERENCES dbo.Property, 
  MaterialID  INT NOT NULL FOREIGN KEY REFERENCES dbo.Material,
  Value  NVARCHAR(50) NOT NULL
    ) 
go

CREATE TABLE dbo.BOM (
  BOMID  INT PRIMARY KEY NONCLUSTERED,
  MaterialID  INT NOT NULL FOREIGN KEY REFERENCES dbo.Material, 
  BOMMaterialID  INT NOT NULL FOREIGN KEY REFERENCES dbo.Material,
  Quantity  NVARCHAR(50) NOT NULL
    ) 

go
CREATE VIEW vMaterialType
AS
SELECT TOP 100 PERCENT 
    MaterialType.MaterialTypeID, 
    MaterialState.Name AS MaterialState, 
    MaterialType.Name AS MaterialType
  FROM MaterialType
    JOIN MaterialState
      ON MaterialType.MaterialStateID = MaterialState.MaterialStateID
  ORDER BY MaterialState.MaterialStateID, MaterialType.Name

-----------------------------------------------------------
-----------------------------------------------------------
-- Insert Sample Data

go
INSERT MaterialState (MaterialStateID, Name) 
	VALUES (1, 'Raw Materials')
INSERT MaterialState (MaterialStateID, Name) 
	VALUES (2, 'Parts')
INSERT MaterialState (MaterialStateID, Name)
	VALUES (3, 'Work in Process')
INSERT MaterialState (MaterialStateID, Name)
	VALUES (4, 'Finished Goods')

SELECT * FROM MaterialState
go

INSERT MaterialType (MaterialTypeID, MaterialStateID, Name)
	VALUES (1, 2, 'Motherboard') --1
INSERT MaterialType (MaterialTypeID, MaterialStateID, Name)
	VALUES (2, 2, 'CPU') --2
INSERT MaterialType (MaterialTypeID, MaterialStateID, Name)
	VALUES (3, 2, 'Hard Drive') --3
INSERT MaterialType (MaterialTypeID, MaterialStateID, Name)
	VALUES (4, 2, 'Video Card') --4
INSERT MaterialType (MaterialTypeID, MaterialStateID, Name)
	VALUES (5, 2, 'RAM')--5
INSERT MaterialType (MaterialTypeID, MaterialStateID, Name)
	VALUES (6, 2, 'CD')--6
INSERT MaterialType (MaterialTypeID, MaterialStateID, Name)
	VALUES (7, 2, 'Case')--7
INSERT MaterialType (MaterialTypeID, MaterialStateID, Name)
	VALUES (8, 2, 'Floppy')--8
INSERT MaterialType (MaterialTypeID, MaterialStateID, Name)
	VALUES (9, 2, 'DVD')--9
INSERT MaterialType (MaterialTypeID, MaterialStateID, Name)
	VALUES (10, 2, 'Sound Card')--10
INSERT MaterialType (MaterialTypeID, MaterialStateID, Name)
	VALUES (11, 2, 'CD-ROM')--11
INSERT MaterialType (MaterialTypeID, MaterialStateID, Name)
	VALUES (12, 1, 'Plastic')--12
INSERT MaterialType (MaterialTypeID, MaterialStateID, Name)
	VALUES (13, 2, 'Case')--13
INSERT MaterialType (MaterialTypeID, MaterialStateID, Name)
	VALUES (14, 2, 'Power Supply')--14
INSERT MaterialType (MaterialTypeID, MaterialStateID, Name)
	VALUES (15, 2, 'Battery')--15
INSERT MaterialType (MaterialTypeID, MaterialStateID, Name)
	VALUES (16, 2, 'LCD')--16
INSERT MaterialType (MaterialTypeID, MaterialStateID, Name)
	VALUES (17, 4, 'DeskTop System')--17
INSERT MaterialType (MaterialTypeID, MaterialStateID, Name)
	VALUES (18, 4, 'Notebook')--18

SELECT * FROM vMaterialType
go 

INSERT Property (PropertyID, Name, UnitOfMeasure)
	VALUES (1, 'Speed/MHz', 'MHz')
INSERT Property (PropertyID, Name, UnitOfMeasure)
	VALUES (2, 'Speed/GHz', 'MHz')
INSERT Property (PropertyID, Name, UnitOfMeasure)
	VALUES (3, 'Capacity/GB', 'GB')
INSERT Property (PropertyID, Name, UnitOfMeasure)
	VALUES (4, 'Capacity/MB', 'GB')
INSERT Property (PropertyID, Name, UnitOfMeasure)
	VALUES (5, 'Power', 'Watts')
INSERT Property (PropertyID, Name, UnitOfMeasure)
	VALUES (6, 'Read Speed', 'x')
INSERT Property (PropertyID, Name, UnitOfMeasure)
	VALUES (7, 'Write Speed', 'x')
INSERT Property (PropertyID, Name, UnitOfMeasure)
	VALUES (8, 'GPU', 'MegaPixels/Sec')
INSERT Property (PropertyID, Name, UnitOfMeasure)
	VALUES (9, 'Max RAM', 1)
INSERT Property (PropertyID, Name, UnitOfMeasure)
	VALUES (10, 'DDR RAM', 1)
INSERT Property (PropertyID, Name, UnitOfMeasure)
	VALUES (11, 'ATX', 1)
INSERT Property (PropertyID, Name, UnitOfMeasure)
	VALUES (12, 'Dual CPU', 1)
INSERT Property (PropertyID, Name, UnitOfMeasure)
	VALUES (13, 'BIOS', 1)
INSERT Property (PropertyID, Name, UnitOfMeasure)
	VALUES (14, 'Cache Memory', 1)
INSERT Property (PropertyID, Name, UnitOfMeasure)
	VALUES (15, 'Avg Access Time', 1)
INSERT Property (PropertyID, Name, UnitOfMeasure)
	VALUES (16, 'ATA Interface', 1)
INSERT Property (PropertyID, Name, UnitOfMeasure)
	VALUES (17, 'Size', 1)
INSERT Property (PropertyID, Name, UnitOfMeasure)
	VALUES (18, 'Color', 1)
INSERT Property (PropertyID, Name, UnitOfMeasure)
	VALUES (19, 'Cells', 1)
INSERT Property (PropertyID, Name, UnitOfMeasure)
	VALUES (20, 'Width', 1)
INSERT Property (PropertyID, Name, UnitOfMeasure)
	VALUES (21, 'Height', 1)
INSERT Property (PropertyID, Name, UnitOfMeasure)
	VALUES (22, 'Thickness', 1)
INSERT Property (PropertyID, Name, UnitOfMeasure)
	VALUES (23, 'Slot/Socket', 1)

SELECT PropertyID, [Name], UnitOfMeasure FROM Property
go

--  Motherboard
INSERT MaterialType_mm_Property (MaterialTypeID, PropertyID)
	VALUES (1, 1) -- Speed/MHz
INSERT MaterialType_mm_Property (MaterialTypeID, PropertyID)
	VALUES (1, 11)  -- ATX
INSERT MaterialType_mm_Property (MaterialTypeID, PropertyID)
	VALUES (1, 12)  -- Dual CPU
INSERT MaterialType_mm_Property (MaterialTypeID, PropertyID)
	VALUES (1, 13)  -- BIOS
INSERT MaterialType_mm_Property (MaterialTypeID, PropertyID)
	VALUES (1, 11)  -- Max RAM
INSERT MaterialType_mm_Property (MaterialTypeID, PropertyID)
	VALUES (1, 9)  -- DDR RAM
INSERT MaterialType_mm_Property (MaterialTypeID, PropertyID)
	VALUES (1, 22)  -- Slot/Socket

-- CPU
INSERT MaterialType_mm_Property (MaterialTypeID, PropertyID)
	VALUES (2, 1) -- Speed MHz
INSERT MaterialType_mm_Property (MaterialTypeID, PropertyID)
	VALUES (2, 14)  -- L2 Cache
INSERT MaterialType_mm_Property (MaterialTypeID, PropertyID)
	VALUES (2, 22)  -- Slot/Socket

-- Hard Drive
INSERT MaterialType_mm_Property (MaterialTypeID, PropertyID)
	VALUES (3, 3)  -- Capacity Gb
INSERT MaterialType_mm_Property (MaterialTypeID, PropertyID)
	VALUES (3, 15) -- Avg Access Time
INSERT MaterialType_mm_Property (MaterialTypeID, PropertyID)
	VALUES (3, 16)  -- ATA Interface
INSERT MaterialType_mm_Property (MaterialTypeID, PropertyID)
	VALUES (3, 17)  -- Size
INSERT MaterialType_mm_Property (MaterialTypeID, PropertyID)
	VALUES (3, 14)  -- Cache Memory

-- Video Card
INSERT MaterialType_mm_Property (MaterialTypeID, PropertyID)
	VALUES (4, 8) -- GPU
INSERT MaterialType_mm_Property (MaterialTypeID, PropertyID)
	VALUES (4, 4) -- Capcity Mb

-- RAM
INSERT MaterialType_mm_Property (MaterialTypeID, PropertyID)
	VALUES (5, 1) -- Speed MHz
INSERT MaterialType_mm_Property (MaterialTypeID, PropertyID)
	VALUES (5, 4) -- Capcity Mb

--  CD
INSERT MaterialType_mm_Property (MaterialTypeID, PropertyID)
	VALUES (6, 1)
INSERT MaterialType_mm_Property (MaterialTypeID, PropertyID)
	VALUES (6, 2)

-- Case
INSERT MaterialType_mm_Property (MaterialTypeID, PropertyID)
	VALUES (7, 1)
INSERT MaterialType_mm_Property (MaterialTypeID, PropertyID)
	VALUES (7, 2)

-- Floppy
INSERT MaterialType_mm_Property (MaterialTypeID, PropertyID)
	VALUES (8, 1)
INSERT MaterialType_mm_Property (MaterialTypeID, PropertyID)
	VALUES (8, 2)

-- DVD
INSERT MaterialType_mm_Property (MaterialTypeID, PropertyID)
	VALUES (9, 1)
INSERT MaterialType_mm_Property (MaterialTypeID, PropertyID)
	VALUES (9, 2)

-- Sound Card
INSERT MaterialType_mm_Property (MaterialTypeID, PropertyID)
	VALUES (10, 1)
INSERT MaterialType_mm_Property (MaterialTypeID, PropertyID)
	VALUES (10, 2)

-- CD-ROM
INSERT MaterialType_mm_Property (MaterialTypeID, PropertyID)
	VALUES (11, 1)
INSERT MaterialType_mm_Property (MaterialTypeID, PropertyID)
	VALUES (11, 2)

-- Plastic
INSERT MaterialType_mm_Property (MaterialTypeID, PropertyID)
	VALUES (12, 1)
INSERT MaterialType_mm_Property (MaterialTypeID, PropertyID)
	VALUES (12, 2)

--  Case
INSERT MaterialType_mm_Property (MaterialTypeID, PropertyID)
	VALUES (13, 11) --ATX
INSERT MaterialType_mm_Property (MaterialTypeID, PropertyID)
	VALUES (13, 1)

-- Power Supply
INSERT MaterialType_mm_Property (MaterialTypeID, PropertyID)
	VALUES (14, 11) -- ATX
INSERT MaterialType_mm_Property (MaterialTypeID, PropertyID)
	VALUES (14,  2)

-- Battery
INSERT MaterialType_mm_Property (MaterialTypeID, PropertyID)
	VALUES (15, 1)
INSERT MaterialType_mm_Property (MaterialTypeID, PropertyID)
	VALUES (15, 2)

-- LCD
INSERT MaterialType_mm_Property (MaterialTypeID, PropertyID)
	VALUES (16,1 )
INSERT MaterialType_mm_Property (MaterialTypeID, PropertyID)
	VALUES (16, 2)

-- DeskTop System
INSERT MaterialType_mm_Property (MaterialTypeID, PropertyID)
	VALUES (17, 1)
INSERT MaterialType_mm_Property (MaterialTypeID, PropertyID)
	VALUES (17, 2)

-- Notebook
INSERT MaterialType_mm_Property (MaterialTypeID, PropertyID)
	VALUES (18, 1)
INSERT MaterialType_mm_Property (MaterialTypeID, PropertyID)
	VALUES (18, 2)


select * from MaterialType
