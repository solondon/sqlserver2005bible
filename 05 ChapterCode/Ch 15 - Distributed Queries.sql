-----------------------------------------------------------
-- SQL Server 2005 Bible 
-- Wiley Publishing 
-- Paul Nielsen

-- Chapter 15 - Distributed Queries

-----------------------------------------------------------
-----------------------------------------------------------


-------------------------------------------------
-- Accessing a Local SQL Server Database
USE CHA2;

SELECT LastName, FirstName 
  FROM OBXKites.dbo.Contact;

SELECT LastName, FirstName 
  FROM OBXKites..Contact;

-------------------------------------------------
-- Linking to External Data Sources

-- Note: the author's development sever is named XPS
-- SQL Server Instances:
-- [XPS]              SQL Server 2000 Developer Edition
-- [XPS\Developer]    SQL Server 2005 Developer Edition
-- [XPS\Standard]     SQL Server 2005 Standard Edition


-- Linking with T-SQL 
EXEC sp_addlinkedserver 
  @server = 'XPS\Standard', 
  @srvproduct = 'SQL Server';

EXEC sp_addlinkedserver 
  @server = 'Yonder', 
  @datasrc = 'XPS\Developer',
  @srvproduct = '',
  @provider='SQLOLEDB';

 -- Viewing Linked Servers w/Catalog View 
SELECT [Name], Product, Provider, Data_source  
  FROM sys.servers
  WHERE Is_Linked = 1;

-- old method
EXEC sp_linkedservers;

-- Drop a linked server
EXEC sp_DropServer @server = 'Yonder';


-- Distributed Security and Logins
EXEC sp_addlinkedsrvlogin 
  @rmtsrvname = 'XPS\Standard',
  @useself = 'true' 

---
SELECT ls.[Name], dp.[Name] 
  FROM sys.servers ls
    JOIN sys.Linked_Logins ll
      ON ls.server_id = ll.server_id
   JOIN sys.database_principals dp
     ON ll.local_principal_id = dp.principal_id
  WHERE Is_Linked = 1;


EXEC sp_helplinkedsrvlogin


EXEC sp_droplinkedsrvlogin
  @rmtsrvname = 'XPS\Standard',
  @locallogin = 'XPS\Pn'; 

EXEC sp_droplinkedsrvlogin 'XPS\Standard', NULL


EXEC sp_helpserver

-- Linked Server Options

Select *   FROM sys.servers;

-- Linking with non-SQL Server Data Sources
EXEC sp_droplinkedsrvlogin 'CHA1_Schedule', NULL
EXEC sp_DropServer @server = 'CHA1_Schedule';

EXEC sp_addlinkedserver 
  @server = 'CHA1_Schedule',
  @srvproduct =  'Excel',
  @provider = 'Microsoft.Jet.OLEDB.4.0',
  @datasrc = 'C:\SQLData\CHA1_Schedule.xls', 
  @provstr = 'Excel 5.0'

EXEC sp_addlinkedsrvlogin 
  @rmtsrvname = 'CHA1_Schedule',
  @useself  = 'false';

EXEC sp_addlinkedserver 
  'CHA1_Customers', 
  'Access 2003', 
  'Microsoft.Jet.OLEDB.4.0', 
  'C:\SQLData\CHA1_Customers.mdb';

-- EXEC sp_DropServer @server = 'CHA1_Customers';
-- EXEC sp_DropServer @server = 'CHA1_Schedule';


----------------------------------------
-- Developing Distributed Queries

-- Local-Distributed Queries

-- Using the Four-Part Name 
SELECT LastName, FirstName 
  FROM [XPS\Standard].Family.dbo.person;

USE CHA2;
INSERT BaseCamp(Name)
  SELECT DISTINCT [Base Camp]
    FROM CHA1_Schedule...[Base_Camp]
    WHERE [Base Camp] IS NOT NULL;

UPDATE [XPS\Standard].Family.dbo.Person 
  SET LastName = 'Wilson'
  WHERE PersonID = 1;


-- Four Part Name Black Box
Select c.contactcode, o.ordernumber, quantity 
  from [XPS\Standard].obxkites.dbo.orderdetail od
    join [XPS\Standard].obxkites.dbo.[order] o
      on o.orderid = od.orderid
    join [XPS\Standard].obxkites.dbo.contact c
      on o.contactid = c.contactid
  where 
    -- comment out combinations of where clause conditions
    c.contactcode = '102' -- and
  --  o.ordernumber = 1 and
  --  o.Orderid = 'BD0BB9E9-F3BB-452C-8789-C1E5E7D04C17'
;

-- OpenDataSource()
--OpenQuery()
SELECT * 
  FROM OPENQUERY(CHA1_Schedule, 
    'SELECT * FROM Tour WHERE Tour = "Gauley River Rafting"');

UPDATE -- to Excel
     OPENQUERY(CHA1_Schedule, 'SELECT * FROM Tour WHERE Tour = "Gauley River Rafting"')
  SET [Base Camp] = 'Ashville' 
  WHERE Tour = 'Gauley River Rafting';

-- OpenRowSet
SELECT * 
  FROM OPENROWSET ('SQLNCLI', 'Server=hppresent\second;Trusted_Connection=yes;', 
                                   'SELECT LastName, FirstName 
                                      FROM Family.dbo.person;')
 
-- an extra example
SELECT ProductName, UnitsInStock 
  FROM OPENDATASOURCE
    ('Microsoft.Jet.OLEDB.4.0',
      'Data Source = C:\Program Files\Microsoft Office\OFFICE11\Samples\Northwind.mdb')...Products;

UPDATE OpenDataSource( 
    'Microsoft.Jet.OLEDB.4.0',
    'Data Source=C:\SQLData\CHA1_Schedule.xls;
    User ID=Admin;Password=;Extended properties=Excel 5.0'
    )...Tour
  SET [Base Camp] = 'Ashville' 
  WHERE Tour = 'Gauley River Rafting';

SELECT * 
  FROM OpenDataSource( 
    'Microsoft.Jet.OLEDB.4.0',
    'Data Source=C:\SQLData\CHA1_Schedule.xls;
    User ID=Admin;Password=;Extended properties=Excel 5.0'
    )...Tour
  WHERE Tour = 'Gauley River Rafting';

-----------------------------------------------
-- Remote Execution / Pass-Through Distributed Queries

--OpenQuery()

SELECT * 
  FROM OPENQUERY(CHA1_Schedule, 
    'SELECT * FROM Tour WHERE Tour = "Gauley River Rafting"');

UPDATE OPENQUERY(CHA1_Schedule,
   'SELECT * FROM Tour WHERE Tour = "Gauley River Rafting"')
  SET [Base Camp] = 'Ashville' 
  WHERE Tour = 'Gauley River Rafting';

-- OpenRowSet
SELECT ContactFirstName, ContactLastName 
  FROM OPENROWSET ('Microsoft.Jet.OLEDB.4.0', 
  'C:\SQLData\CHA1_Customers.mdb'; 'Admin';'', 
  'SELECT * FROM Customers WHERE CustomerID = 1');
 
UPDATE OPENROWSET ('Microsoft.Jet.OLEDB.4.0', 
  'C:\SQLData\CHA1_Customers.mdb'; 'Admin';'', 
  'SELECT * FROM Customers WHERE CustomerID = 1')
  SET ContactLastName = 'Wilson';


-------------------------------------------------------
-- Ditributed Transactions

USE Family;
SET xact_abort on;
BEGIN DISTRIBUTED TRANSACTION;

  UPDATE Person
    SET LastName = 'Johnson'
    WHERE PersonID = 10;

  UPDATE [XPS\Standard].Family.dbo.Person 
    SET LastName = 'Johnson'
    WHERE PersonID = 10;

COMMIT; 

