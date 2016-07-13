-----------------------------------------------------------
-- SQL Server 2005 Bible 
-- Wiley Publishing 
-- Paul Nielsen

-- Chapter 19 - Performing Bulk Operations

-----------------------------------------------------------
-----------------------------------------------------------

CREATE DATABASE BulkTest;

USE BulkTest;

ALTER DATABASE BulkTest SET Recovery BULK_LOGGED; 
ALTER DATABASE BulkTest SET Recovery SIMPLE; 
ALTER DATABASE BulkTest SET Recovery FULL; 

CREATE 
-- DROP
TABLE AWAddress (
  ID INT,
  City    VARCHAR(500),
  PostalCode VARCHAR(500),
  Address VARCHAR(500),
  Region  VARCHAR(500),
  GUID VARCHAR(500)
  ); 

CREATE VIEW vAWAddress as (
   SELECT ID, Address, City, Region, PostalCode

BULK INSERT AWAddress
  FROM 'C:\Program Files\Microsoft SQL Server\90\Tools\Samples\AdventureWorks OLTP\Address.csv' 
  WITH (FIRSTROW = 1,ROWTERMINATOR ='\n');

Select * from AWAddress



