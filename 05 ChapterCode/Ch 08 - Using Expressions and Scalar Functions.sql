-----------------------------------------------------------
-- SQL Server 2005 Bible 
-- Wiley Publishing 
-- Paul Nielsen

-- Chapter 08 - Using Expressions and Scalar Functions
  
-----------------------------------------------------------
-- Building Expressions

-- Operators
SELECT 15%4 AS Modulo, 
  FLOOR(1.25) AS [Floor], 
  CEILING(1.25) AS [Ceiling]

-- String Concatenation
SELECT 123 + 456 AS Addition, 
  'abc' + 'defg' AS Concatenation

SELECT 'Product: ' + ProductName AS [Order]
  FROM Product

-- Bitwise Operations
SELECT 1 & 1

SELECT 1 & 0 

-- 3 = 011 
-- 5 = 101
-- AND --- 
-- 1 = 001

SELECT 3 & 5

-- Boolean OR 
SELECT 1 | 1
SELECT 1 | 0 

-- 3 = 011 
-- 5 = 101
-- OR  --- 
-- 7 = 111

SELECT 3 | 5

-- Boolean Exclusive Or
SELECT 1^1

SELECT 1^0

-- Bitwise Not
DECLARE @A BIT
SET @A = 1
SELECT ~@A

-----------------------------------------------------------
-- Case Expressions

-- Simple Case
USE OBXKites
SELECT CustomerTypeName,
  CASE [Default] 
    WHEN 1 THEN 'default type'
    WHEN 0 THEN 'possible'
      ELSE '-'
  END AS AssignStatus
  FROM CustomerType 

-- Boolean Case 
SELECT 
  CASE
    WHEN 1<0 THEN 'reality is gone.'
    WHEN GETDATE() = '11/30/2005' 
      THEN 'David gets his driver''s license.'
    WHEN 1>0 THEN 'Life is Normal.'
  END AS RealityCheck

--
DECLARE @b INT, @q INT

SET @b = 2007
SET @q = 35

Select  CASE 
   WHEN @b = 2007 AND @q BETWEEN 10 AND 30 THEN 1
   ELSE NULL
END AS Test

-----------------------------------------------------------
-- Working with Nulls

SELECT 1 + NULL

-- Testing for Null
IF NULL = NULL
  SELECT '='
ELSE
  SELECT '!='

IF NULL IS NULL
  SELECT 'Is'
ELSE
  SELECT 'Is Not'

-- Is Null
USE CHA2
SELECT FirstName, LastName, Nickname
  FROM Customer
  WHERE NickName IS NULL
  ORDER BY LastName, FirstName

SELECT FirstName, LastName, Nickname
  FROM Customer
  WHERE NickName IS NOT NULL
  ORDER BY LastName, FirstName

-- Handling Nulls

-- Using the IsNull() Function
SELECT FirstName, LastName, ISNULL(Nickname,'none')
  FROM Customer
  ORDER BY LastName, FirstName

-- Coalesce()
SELECT COALESCE(NULL, 1+NULL, 1+2, 'abc')

SELECT Coalesce(
    Address1 + str(13)+str(10) + Adress2,
    Address1,
    Address2,
    Address3,
    SalesNote) AS NewAddress
  FROM TempSalesContacts

-- NullIf()
UPDATE Customer
  SET NickName = ''
  WHERE LastName = 'Adams'

SELECT LastName, FirstName, 
    CASE NickName
      WHEN '' THEN 'blank'
      ELSE Nickname
    END AS NickName,
  NULLIF(NickName,'') AS NickNameNullIf
  FROM Customer
  WHERE LastName IN ('Adams', 'Anderson', 'Andrews')
  ORDER BY LastName, FirstName

-- Non-Default Null Behavior 

-- Null Concatenation

-- set database option
EXEC SP_DBOPTION 'CHA2',  CONCAT_NULL_YIELDS_NULL, 'false'
SELECT DATABASEPROPERTYEX('CHA2', 'IsNullConcat')
-- set connection setting
SET CONCAT_NULL_YIELDS_NULL OFF 
-- test
SELECT NULL + 'abc'

-- ANSI SQL 92 Nulls Comparisions

-- set database option
EXEC SP_DBOPTION 'CHA2',  ANSI_NULLS, 'false'
SELECT DATABASEPROPERTYEX('CHA2','IsAnsiNullsEnabled')

-- set connection setting
SET ANSI_NULLS OFF
-- test
SELECT 'true' WHERE (NULL = NULL)

-----------------------------------------------------------
-- Scalar Functions

-- User Information Functions
SELECT 
  USER_NAME() AS 'User',
  SUSER_SNAME() AS 'Login',
  HOST_NAME() AS 'Workstation',
  APP_NAME() AS 'Application'

-- Date/Time Functions
SELECT DATENAME(YEAR, GETDATE()) AS YEAR

UPDATE Guide 
  SET DateOfBirth = '9/4/58'
  WHERE lastName = 'Frank'

SELECT LastName, 
    DATENAME(yy,DateOfBirth) AS [Year],
    DATENAME(mm,DateOfBirth) AS [Month],
    DATENAME(dd,DateOfBirth) AS [Day],
    DATENAME(WEEKDAY, DateOfBirth) AS BirthDay
  FROM Guide
  WHERE DateOfBirth IS NOT NULL

SELECT DATEPART(DayofYear, GETDATE()) AS DayCount
SELECT DATEPART(dw, GETDATE()) AS DayWeek

-- Date Math
SELECT DATEDIFF(yy,'1984/5/20', GETDATE()) AS MarriedYears,
  DATEDIFF(dd,'1984/5/20', GETDATE()) AS MarriedDays

SELECT DATEADD(hh,100, GETDATE()) AS [100HoursFromNow]

USE Family

SELECT Person.FirstName + ' ' + Person.LastName AS Mother, 
    DATEDIFF(yy, Person.DateOfBirth, 
    Child.DateOfBirth) AS Age,Child.FirstName
  FROM Person
    JOIN Person Child 
      ON Person.PersonID = Child.MotherID 
  ORDER By Age DESC

-- String Functions
SELECT SUBSTRING('abcdefg', 3, 2)

SELECT STUFF('abcdefg', 3, 2, '123')

SELECT STUFF('123456789', 4, 0, '-')
SELECT STUFF(STUFF('123456789', 4, 0, '-'), 7, 0, '-')

SELECT CHARINDEX('c', 'abcdefg', 1) 

SELECT PATINDEX('%[cd]%', 'abdcdefg') 

SELECT RIGHT('Nielsen',2) AS [Right], LEFT('Nielsen',2) AS 'Left'

SELECT LEN('Supercalifragilisticexpialidocious') AS LEN

SELECT RTRIM('   middle earth   ') AS [RTrim], LTRIM('   middle earth   ') AS [LTrim]

Select UPPER('one TWO tHrEe') AS [UpperCase], LOWER('one TWO tHrEe') AS [LowerCase]

-- Replace
USE OBXKites

UPDATE Contact 
  SET LastName = 'Adam''s'
  WHERE LastName = 'Adams' 

SELECT LastName, REPLACE(LastName, '''', '') 
  FROM Contact
  WHERE LastName LIKE '%''%'

UPDATE Contact
  SET LastName = REPLACE(LastName, '''', '')
  WHERE LastName LIKE '%''%'


-- TitleCase
IF EXISTS (SELECT * FROM sysobjects WHERE name = 'TitleCase')
  DROP FUNCTION TitleCase

go
CREATE FUNCTION TitleCase (
  @StrIn NVARCHAR(1024))
RETURNS NVARCHAR(1024)
AS
  BEGIN
    DECLARE 
      @StrOut NVARCHAR(1024),
      @CurrentPosition INT,
      @NextSpace INT,
      @CurrentWord NVARCHAR(1024),
      @StrLen INT,
      @LastWord BIT

    SET @NextSpace = 1
    SET @CurrentPosition = 1
    SET @StrOut = ''
    SET @StrLen = LEN(@StrIn)
    SET @LastWord = 0

    WHILE @LastWord = 0
      BEGIN 
        SET @NextSpace = CHARINDEX(' ',@StrIn, @CurrentPosition+ 1)
        IF  @NextSpace = 0 -- no more spaces found
          BEGIN
            SET @NextSpace = @StrLen
            SET @LastWord = 1
          END
        SET @CurrentWord = UPPER(SUBSTRING(@StrIn, @CurrentPosition, 1)) 
        SET @CurrentWord = @CurrentWord + LOWER(SUBSTRING(@StrIn, @CurrentPosition+1, @NextSpace - @CurrentPosition))
        SET @StrOut = @StrOut +@CurrentWord
        SET @CurrentPosition = @NextSpace + 1
    END
    RETURN @StrOut
  END
go

SELECT dbo.TitleCase('one TWO tHrEe') AS [TitleCase]

-- Soundex()
USE CHA2
SELECT DISTINCT LastName, SOUNDEX(LastName)
  FROM Customer
  ORDER BY LastName

SELECT SOUNDEX('Nielsen') AS Nielsen, SOUNDEX('Nelson') AS NELSON, SOUNDEX('Neilson') AS NEILSON

USE CHA2

Set statistics time on 
SELECT LastName, FirstName 
  FROM Customer
  WHERE SOUNDEX('Nikolsen') = SOUNDEX(LastName)
    AND LastName LIKE 'N%'

USE OBXKites
SELECT SOUNDEX('Smith')

SELECT LastName, FirstName, SoundexCode 
  FROM Contact
  WHERE SoundexCode = 'S530'

Set statistics time off

USE CHA2
SELECT LastName, DIFFERENCE ('Smith', LastName) AS NameSearch
  FROM Customer
  ORDER BY DIFFERENCE ('Smyth', LastName) DESC

-- Data Type Conversions
SELECT CAST('Away' AS NVARCHAR(5)) AS 'Tom Hanks'

SELECT CAST(123 AS NVARCHAR(15)) AS Int2String

SELECT  GETDATE() AS RawDate,
  CONVERT (NVARCHAR(25), GETDATE(), 100) AS Date100,
  CONVERT (NVARCHAR(25), GETDATE(), 1) AS Date1

SELECT STR(123,5,2) AS [Str]

-- Alternate Date Conversions
DECLARE @MyDate CHAR(8)
SET @MyDate = '102801'
SET @MyDate = '20' + SUBSTRING(@MyDate,5,2) + SUBSTRING(@MyDate,1,2)+ SUBSTRING(@MyDate,3,2) 
PRINT @MyDate
DECLARE @NewDate DATETIME
SET @NewDate = CAST(@MyDate AS DATETIME)
PRINT @NewDate

-- Server Environment Functions
SELECT GETDATE() AS 'Date',
  DB_NAME() AS 'Database'

SELECT @@SERVERNAME  

SELECT 
  SERVERPROPERTY ('ServerName') AS ServerName,
  SERVERPROPERTY ('Edition') AS Edition,
  SERVERPROPERTY ('EngineEdition') AS EngineEdition, 
  SERVERPROPERTY ('ProductLevel') AS ProductLevel



