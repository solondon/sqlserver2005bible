-----------------------------------------------------------
-- SQL Server 2005 Bible 
-- Wiley & Sons 
-- Paul Nielsen

-- Chapter  31 - Using XML, XPath, and XQuery

-----------------------------------------------------------
-----------------------------------------------------------



-----------------------------------
-- XML Data Type

-- XML Schema Collections

CREATE DATABASE XMLearn
USE XMLearn

CREATE XML SCHEMA COLLECTION ItemSchema AS N'
  <xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns="resume-schema"
    targetNamespace="resume-schema"
    elementFormDefault="qualified">
  <xsd:element name="Item" type="ItemType"/>
  <xsd:complexType name="ItemType" mixed="true">
   <xsd:sequence>
    <xsd:element name="SKU" type="xsd:string" minOccurs="1"/>
    <xsd:element name="Size" type="xsd:string" minOccurs="1"/>
    <xsd:element name="Color" type="xsd:string" minOccurs="1"/>
   </xsd:sequence>
  </xsd:complexType>
  </xsd:schema>'


CREATE TABLE XMLGeneric (
  ID INT IDENTITY NOT NULL PRIMARY KEY, 
  Data XML (SchemaName)
  )

---------------------------------------
-- Querying XML Data

-- XPATH
SELECT Customer, OrderDetail.query(
  '/Items[1]/Item[1]/SKU')
  FROM XMLOrders

-- FLWOR Queries
SELECT Customer, OrderDetail.query(
  'for $i in /Items/Item
   where $i/Quantity = 2
   return $i/SKU')
  FROM XMLOrders

-- Merging XQuery with Select 
SELECT Customer
  FROM XMLOrders
  WHERE OrderDetail.exist(
  '/Items/Item[SKU = 234]')=1

SELECT Customer,OrderDetail.value(
  '/Items[1]/Item[1]/SKU[1]', 'VARCHAR(25)')
  FROM XMLOrders

SELECT Customer, OrderDetail.query(
  'for $i in /Items/Item
   return $i/SKU')
  FROM XMLOrders

UPDATE XMLOrders
  SET OrderDetail.modify(
    'insert
    <Items SKU = "678" Quantity = "2"/> 
     into /Items[1]'
   )
  WHERE OrderID = 1

 
UPDATE XMLOrders
  SET OrderDetail.modify(
    'delete /Items/Item[1]'
   )
  WHERE OrderID = 1


----------------------------------------
-- Decomposing XML SQL Server

DECLARE 
  @iDOM int,
  @XML VarChar(8000)

Set @XML = '
<?xml version="1.0" encoding="UTF-8"?>
<Tours>
  <Tour Name="Amazon Trek">
    <Event Code="01-003" DateBegin="2001-03-16T00:00:00"/>
    <Event Code="01-015" DateBegin="2001-11-05T00:00:00"/>
  </Tour>
  <Tour Name="Appalachian Trail">
    <Event Code="01-005" DateBegin="2001-06-25T00:00:00"/>
    <Event Code="01-008" DateBegin="2001-07-14T00:00:00"/>
    <Event Code="01-010" DateBegin="2001-08-14T00:00:00"/>
  </Tour>
  <Tour Name="Bahamas Dive">
    <Event Code="01-002" DateBegin="2001-05-09T00:00:00"/>
    <Event Code="01-006" DateBegin="2001-07-03T00:00:00"/>
    <Event Code="01-009" DateBegin="2001-08-12T00:00:00"/>
  </Tour>
  <Tour Name="Gauley River Rafting">
    <Event Code="01-012" DateBegin="2001-09-14T00:00:00"/>
    <Event Code="01-013" DateBegin="2001-09-15T00:00:00"/>
  </Tour>
  <Tour Name="Outer Banks Lighthouses">
    <Event Code="01-001" DateBegin="2001-02-02T00:00:00"/>
    <Event Code="01-004" DateBegin="2001-06-06T00:00:00"/>
    <Event Code="01-007" DateBegin="2001-07-03T00:00:00"/>
    <Event Code="01-011" DateBegin="2001-08-17T00:00:00"/>
    <Event Code="01-014" DateBegin="2001-10-03T00:00:00"/>
    <Event Code="01-016" DateBegin="2001-11-16T00:00:00"/>
  </Tour>
</Tours>'

-- Generate the internal DOM 
EXEC sp_xml_preparedocument @iDOM OUTPUT, @XML

-- OPENXML provider.
SELECT *
  FROM OPENXML (@iDOM, '/Tours/Tour/Event',8)
         WITH ([Name] VARCHAR(25) '../@Name',
               Code VARCHAR(10),
               DateBegin DATETIME
              )
EXEC sp_xml_removedocument @iDOM


-- Creating XML with SQL Server 2005
-- For XML Raw

SELECT Tour.Name, Event.Code, Event.DateBegin 
  FROM Tour
  JOIN Event
    ON Tour.TourID = Event.TourID
  FOR XML RAW

-- For XML Auto
SELECT Tour.Name, Event.Code, Event.DateBegin 
  FROM Tour
  JOIN Event
    ON Tour.TourID = Event.TourID
  FOR XML AUTO

SELECT Tour.Name, Event.Code, Event.DateBegin 
  FROM Tour
  JOIN Event
    ON Tour.TourID = Event.TourID
  FOR XML AUTO, ELEMENTS


 


