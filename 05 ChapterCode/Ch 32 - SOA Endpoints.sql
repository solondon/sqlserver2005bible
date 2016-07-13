-----------------------------------------------------------
-- SQL Server 2005 Bible 
-- Wiley Publishing 
-- Paul Nielsen

-- Chapter 32  - SOA and Endpoints 
-------------------------------------------------

  
-------------------------------------------
-- HTTP Listening

-- Implicit Endpoints

USE AdventureWorks

CREATE PROCEDURE [db_accessadmin].[upGetCustomer]
@CustId nchar(5)
AS

SELECT CustomerID,CompanyName,ContactName,ContactTitle,Address,City,PostalCode,Country,Phone,Fax 
FROM Customers
WHERE customerid=@custid
ORDER by CompanyName,CustomerID,Country DESC

DROP ENDPOINT sql_endpoint;
GO

sp_reserve_http_namespace N'<fURL:80/sql>'

sp_reserve_http_namespace N'http://XPS:1180/sql3'

sp_delete_http_namespace_reservation N'http://*:1180/sql3'


drop endpoint sql_endpointtest

CREATE ENDPOINT sql_endpointtest
STATE = STARTED
AS HTTP(
   PATH = '/path', 
   AUTHENTICATION = (INTEGRATED), 
   PORTS = (CLEAR), 
   SITE = 'XPS' , CLEAR_PORT = 2000
   )
FOR SOAP (
   WEBMETHOD 'http://tempUri.org/'.'GetSqlInfo' 
            (name='master.dbo.xp_msver', 
             SCHEMA=STANDARD),
   WSDL = DEFAULT,
   SCHEMA = STANDARD ,
   DATABASE = 'master'
   ); 
GO

select * from sys.endpoints






