-----------------------------------------------------------
-- SQL Server 2005 Bible 
-- Wiley Publishing 
-- Paul Nielsen

-- Chapter 11  - Aggregating Data

-----------------------------------------------------------
-----------------------------------------------------------

-- Build the sample Data 
USE tempdb

IF EXISTS(SELECT * FROM sysobjects WHERE Name = 'RawData')
  DROP TABLE RawData
go

CREATE TABLE RawData (
  Region VARCHAR(10),
  Category CHAR(1),
  Amount INT,
  SalesDate DateTime
  )

go

INSERT RawData (Region, Category, Amount, SalesDate)
  VALUES( 'South', 'Y',     12, '11/1/2005')
INSERT RawData (Region, Category, Amount, SalesDate)
  VALUES( 'South', 'Y',     24, '11/1/2005')
INSERT RawData (Region, Category, Amount, SalesDate)
  VALUES( 'South', 'Y',     15, '12/1/2005')
INSERT RawData (Region, Category, Amount, SalesDate)
  VALUES( 'NorthEast', 'Y', 28, '12/1/2005')
INSERT RawData (Region, Category, Amount, SalesDate)
  VALUES( 'South', 'X',     11, '1/1/2006')
INSERT RawData (Region, Category, Amount, SalesDate)
  VALUES( 'MidWest', 'X',   24, '1/1/2006')
INSERT RawData (Region, Category, Amount, SalesDate)
  VALUES( 'West', 'X',      36, '2/1/2006')
INSERT RawData (Region, Category, Amount, SalesDate)
  VALUES( 'South', 'Y',     47, '2/1/2006')
INSERT RawData (Region, Category, Amount, SalesDate)
  VALUES( 'MidWest', 'Y',   38, '3/1/2006')
INSERT RawData (Region, Category, Amount, SalesDate)
  VALUES( 'NorthEast', 'Y', 62, '3/1/2006')
INSERT RawData (Region, Category, Amount, SalesDate)
  VALUES( 'South', 'Z',     33, '4/1/2006')
INSERT RawData (Region, Category, Amount, SalesDate)
  VALUES( 'MidWest', 'Z',   83, '4/1/2006')
INSERT RawData (Region, Category, Amount, SalesDate)
  VALUES( 'West', 'Z',      44, '5/1/2006')
INSERT RawData (Region, Category, Amount, SalesDate)
  VALUES( 'NorthEast', 'Z', 55, '5/1/2006')
INSERT RawData (Region, Category, Amount, SalesDate)
  VALUES( 'South', 'X',     68, '6/1/2006')
INSERT RawData (Region, Category, Amount, SalesDate)
  VALUES( 'South', 'X',     86, '6/1/2006')
INSERT RawData (Region, Category, Amount, SalesDate)
  VALUES( 'South', 'Y',     54, '7/1/2006')
INSERT RawData (Region, Category, Amount, SalesDate)
  VALUES( 'South', 'Y',     63, '7/1/2006')
INSERT RawData (Region, Category, Amount, SalesDate)
  VALUES( 'South', 'Y',     72, '8/1/2006')
INSERT RawData (Region, Category, Amount, SalesDate)
  VALUES( 'NorthEast', 'Y', 91, '8/1/2006')
INSERT RawData (Region, Category, Amount, SalesDate)
  VALUES( 'NorthEast', 'Y', null, '8/1/2006')
INSERT RawData (Region, Category, Amount, SalesDate)
  VALUES( 'NorthEast', 'Y', null, '8/1/2006')
INSERT RawData (Region, Category, Amount, SalesDate)
  VALUES( 'NorthEast', 'Y', null, '8/1/2006')
INSERT RawData (Region, Category, Amount, SalesDate)
  VALUES( 'NorthEast', 'Y', null, '8/1/2006')

-- check the Amount
SELECT * FROM RawData

---------------------------------------------
-- Simple Aggregations
SELECT
    Count(*) as Count, 
    Sum(Amount) as [Sum], 
    Avg(Amount) as [Avg], 
    Min(Amount) as [Min], 
    Max(Amount) as [Max]
  FROM RawData

SELECT Avg(Cast((Amount)as Numeric(9,5))) as [Numeric Avg],
  Avg(Amount) as [Int Avg],
  Sum(Amount) / Count(*) as [Manual Avg]
  FROM RawData

---------------------------------------------
-- Beginning Statistics
SELECT 
    StDevP(Amount) as [StDevP],
    VarP(Amount) as [VarP]
  FROM RawData

SELECT 
    Count(*) as Count, 
    StDev(Amount) as [StDevP],
    Var(Amount) as [VarP]
  FROM RawData
  WHERE Year(SalesDate) = 2006

---------------------------------------------
-- Grouping within a Result Set

-- Simple Groupings
SELECT Category, 
    Count(*) as Count, 
    Sum(Amount) as [Sum], 
    Avg(Amount) as [Avg], 
    Min(Amount) as [Min], 
    Max(Amount) as [Max]
  FROM RawData
  GROUP BY Category

SELECT Year(SalesDate) as [Year], DatePart(q,SalesDate) as [Quarter],
    Count(*) as Count, 
    Sum(Amount) as [Sum], 
    Avg(Amount) as [Avg], 
    Min(Amount) as [Min], 
    Max(Amount) as [Max]
  FROM RawData
  GROUP BY Year(SalesDate), DatePart(q,SalesDate)

-- Group by occurs after the where clause
SELECT Category, 
    Count(*) as Count, 
    Sum(Amount) as [Sum], 
    Avg(Amount) as [Avg], 
    Min(Amount) as [Min], 
    Max(Amount) as [Max]
  FROM RawData
  WHERE Year(SalesDate) = 2006
  GROUP BY Category

-- can group by multiple columns
SELECT Year(SalesDate) as [Year], DatePart(q,SalesDate) as [Quarter],
    Count(*) as Count, 
    Sum(Amount) as [Sum], 
    Avg(Amount) as [Avg], 
    Min(Amount) as [Min], 
    Max(Amount) as [Max]
  FROM RawData
  GROUP BY Year(SalesDate), DatePart(q,SalesDate)

---------------------------------------------
-- Aggravating Queries

-- Amount Aggravations
IF EXISTS(SELECT * FROM sysobjects WHERE Name = 'RawCategory')
  DROP TABLE RawCategory

CREATE TABLE RawCategory (
  RawCategoryID  CHAR(1),
  CategoryName   VARCHAR(25)
  )

INSERT RawCategory (RawCategoryID, CategoryName)
  VALUES ('X', 'Sci-Fi')
INSERT RawCategory (RawCategoryID, CategoryName)
  VALUES ('Y', 'Philosophy')
INSERT RawCategory (RawCategoryID, CategoryName)
  VALUES ('Z', 'Zoology')

-- including Amount outside the aggregate function or group by will cause an error
/* 
SELECT Category, CategoryName, 
    Sum(Amount) as [Sum], 
    Avg(Amount) as [Avg], 
    Min(Amount) as [Min], 
    Max(Amount) as [Max]
  FROM RawData R
    JOIN RawCategory C
      ON R.Category = C.RawCategoryID
  GROUP BY Category
*/

-- Solution 1: include all Amount in the Group By 
SELECT Category, CategoryName, 
    Sum(Amount) as [Sum], 
    Avg(Amount) as [Avg], 
    Min(Amount) as [Min], 
    Max(Amount) as [Max]
  FROM RawData R
    JOIN RawCategory C
      ON R.Category = C.RawCategoryID
  GROUP BY Category, CategoryName
  ORDER BY Category, CategoryName

-- Solution 2: Aggregate in Subquery, addition Amount in outer query
SELECT sq.Category, CategoryName, sq.[Sum], sq.[Avg], sq.[Min], sq.[Max]
  FROM (SELECT Category,
            Sum(Amount) as [Sum], 
            Avg(Amount) as [Avg], 
            Min(Amount) as [Min], 
            Max(Amount) as [Max]
          FROM RawData
          GROUP BY Category ) sq
    JOIN RawCategory C
      ON sq.Category = C.RawCategoryID
  ORDER BY Category, CategoryName

-- How many children has each mother born? (not in text) 
USE Family
SELECT PersonID, FirstName, LastName, Children
  FROM dbo.Person
    JOIN (SELECT MotherID, COUNT(*) AS Children 
               FROM dbo.Person 
               WHERE MotherID IS NOT NULL 
               GROUP BY MotherID) ChildCount
      ON Person.PersonID = ChildCount.MotherID
  ORDER BY Children DESC;


-- Including All Group By Values 
-- Left Outer Join Group Bys
USE Tempdb 
SELECT Year(SalesDate) AS [Year],
    Count(*) as Count, 
    Sum(Amount) as [Sum], 
    Avg(Amount) as [Avg], 
    Min(Amount) as [Min], 
    Max(Amount) as [Max]
  FROM RawData
  WHERE Year(SalesDate) = 2006
  GROUP BY ALL Year(SalesDate)

------------------------------------------------------------------
-- Nested Aggregations
-- Which Category sold the most in each quarter?

-- Can't nest aggregate function - error: 
/*
    Select Y,Q, Max(Sum) as MaxSum 
        FROM ( -- Calculate Sums
              SELECT Category, Year(SalesDate) as Y, DatePart(q,SalesDate) as Q, max(Sum(Amount)) as Sum
                FROM RawData
                GROUP BY Category, Year(SalesDate), DatePart(q,SalesDate)
              ) sq
        GROUP BY Y,Q
        ORDER BY Y,Q
*/

-- Solution: Including Detail description 
   SELECT MaxQuery.Y, MaxQuery.Q, AllQuery.Category, MaxQuery.MaxSum as sales
      FROM (-- Find Max Sum Per Year/Quarter
            Select Y,Q, Max(Sum) as MaxSum 
              FROM ( -- Calculate Sums
                    SELECT Category, Year(SalesDate) as Y, DatePart(q,SalesDate) as Q, Sum(Amount) as Sum
                      FROM RawData
                      GROUP BY Category, Year(SalesDate), DatePart(q,SalesDate)
                    ) sq
              GROUP BY Y,Q
            ) MaxQuery
        JOIN (-- All Amount Query
              SELECT Category, Year(SalesDate) as Y, DatePart(q,SalesDate) as Q, Sum(Amount) as Sum
              FROM RawData
                GROUP BY Category, Year(SalesDate), DatePart(q,SalesDate)
              )AllQuery
          ON MaxQuery.Y = AllQuery.Y
            AND MaxQuery.Q = AllQuery.Q
            AND MaxQuery.MaxSum = AllQuery.Sum
        ORDER BY MaxQuery.Y, MaxQuery.Q

-- Filtering Grouped Results
SELECT Year(SalesDate) as [Year],
    DatePart(q,SalesDate) as [Quarter],
    Count(*) as Count, 
    Sum(Amount) as [Sum], 
    Avg(Amount) as [Avg]
  FROM RawData
  GROUP BY Year(SalesDate), DatePart(q,SalesDate)
  --HAVING Avg(Amount) > 25
  ORDER BY [Year], [Quarter]

---------------------------------------------
-- Generating Totals

-- Rollup Subtotals
SELECT Grouping(Category), Category,        
    CASE Grouping(Category) 
      WHEN 0 THEN Category
      WHEN 1 THEN 'All Categories' 
    END AS Category, 
    Count(*) as Count
  FROM RawData
  GROUP BY Category
    WITH ROLLUP

SELECT     
    CASE Grouping(Category) 
      WHEN 0 THEN Category
      WHEN 1 THEN 'All Categories' 
    END AS Category,
    CASE Grouping(Year(SalesDate)) 
      WHEN 0 THEN Cast(Year(SalesDate) as CHAR(8))
      WHEN 1 THEN 'All Years' 
    END AS Year,
    Count(*) as Count
  FROM RawData
  GROUP BY Category, Year(SalesDate)
    WITH ROLLUP

---------------------------------------------
-- Cube Queries
SELECT     
    CASE Grouping(Category) 
      WHEN 0 THEN Category
      WHEN 1 THEN 'All Categories' 
    END AS Category,
    CASE Grouping(Year(SalesDate)) 
      WHEN 0 THEN Cast(Year(SalesDate) as CHAR(8))
      WHEN 1 THEN 'All Years' 
    END AS Year,    Count(*) as Count
  FROM RawData
  GROUP BY Category, Year(SalesDate)
    WITH CUBE

---------------------------------------------
-- Computing Aggregates  
SELECT Category, SalesDate, Amount
  FROM RawData
  WHERE Year(SalesDate) = '2006'
  COMPUTE  Avg(Amount), sum(Amount)

SELECT Category, SalesDate, Amount
  FROM RawData
  WHERE Year(SalesDate) = '2006'
  ORDER BY Category
  COMPUTE  Avg(Amount), sum(Amount)
    BY Category

SELECT Category, SalesDate, Amount
  FROM RawData
  WHERE Year(SalesDate) = '2006'
  ORDER BY Category
  COMPUTE   avg(Amount), sum(Amount)
  COMPUTE   sum(Amount)
    BY Category

---------------------------------------------
-- Building Crosstab Queries
set statistics time on

-- Fixed Column CrossTab - Correlated Subquery Method
SELECT R.Category, 
    (SELECT SUM(Amount)
      FROM RawData
      WHERE Region = 'South' AND Category = R.Category) AS 'South',
    (SELECT SUM(Amount)
      FROM RawData
      WHERE Region = 'NorthEast' AND Category = R.Category) AS 'NorthEast',
    (SELECT SUM(Amount)
      FROM RawData
      WHERE Region = 'MidWest' AND Category = R.Category) AS 'MidWest',
    (SELECT SUM(Amount)
      FROM RawData
      WHERE Region = 'West' AND Category = R.Category) AS 'West',
    SUM(Amount) as Total
  FROM RawData R
  GROUP BY Category

-- Fixed Column CrossTab with Category Subtotal- CASE Method
SELECT Category,
  SUM(Case Region WHEN 'South' THEN Amount ELSE 0 END) AS South,
  SUM(Case Region WHEN 'NorthEast' THEN Amount ELSE 0 END) AS NorthEast,
  SUM(Case Region WHEN 'MidWest' THEN Amount ELSE 0 END) AS MidWest,
  SUM(Case Region WHEN 'West' THEN Amount ELSE 0 END) AS West,
  SUM(Amount) as Total
  FROM RawData
  GROUP BY Category
  ORDER BY Category

  -- Fixed Column Crosstab - PIVOT Method
SELECT Category, SalesDate, South, NorthEast, MidWest, West
  FROM RawData
    PIVOT 
      (Sum (Amount)
      FOR Region IN (South, NorthEast, MidWest, West)
      ) AS pt

SELECT Category, South, NorthEast, MidWest, West
  FROM (Select Category, Region, Amount from RawData) sq
    PIVOT 
      (Sum (Amount)
      FOR Region IN (South, NorthEast, MidWest, West)
      ) AS pt

-- Fixed Column Crosstab with Category Subtotal - PIVOT Method
SELECT Category, South, NorthEast, MidWest, West, 
  IsNull(South,0) + IsNull(NorthEast,0) + IsNull(MidWest,0) + IsNull(West,0) as Total
  FROM RawData
    PIVOT 
      (Sum (Amount)
      FOR Region IN (South, NorthEast, MidWest, West)
      ) AS pt

-- Fixed Column Crosstab with Filter - PIVOT Method
-- Must filter within the FROM clause (using subquery) prior to Pivot operation
SELECT Category, South, NorthEast, MidWest, West, 
  IsNull(South,0) + IsNull(NorthEast,0) + IsNull(MidWest,0) + IsNull(West,0) as Total
  FROM (Select Region, Category, Amount
          From RawData 
          Where Category = 'Z') sq
    PIVOT 
      (Sum (Amount)
      FOR Region IN (South, NorthEast, MidWest, West)
      ) AS pt

-------------------------------------------------
-- Dynamic CrossTabs with Cursor and Pivot Method 
-- using Cursor to dynamically generate the column names 
DECLARE 
  @SQLStr NVARCHAR(1024),
  @RegionColumn VARCHAR(50),
  @SemiColon BIT
SET @Semicolon = 0
SET @SQLStr = ''
DECLARE ColNames CURSOR FAST_FORWARD 
  FOR 
  SELECT DISTINCT Region as [Column]
    FROM RawData
    ORDER BY Region
  OPEN ColNames
  FETCH ColNames INTO @RegionColumn
  WHILE @@Fetch_Status = 0 
    BEGIN
        SET @SQLStr = @SQLStr + @RegionColumn + ', '
        FETCH ColNames INTO @RegionColumn  -- fetch next
    END
  CLOSE ColNames
DEALLOCATE ColNames
SET @SQLStr = Left(@SQLStr, Len(@SQLStr) - 1)
SET @SQLStr = 'SELECT Category, ' 
    + @SQLStr 
    + ' FROM RawData PIVOT (Sum (Amount) FOR Region IN ('
    + @SQLStr
    + ')) AS pt'
PRINT @SQLStr
EXEC sp_executesql  @SQLStr

-------------------------------------------------
-- Dynamic CrossTabs with Multiple Assignment Variable and Pivot Method 
-- Appending to a variable within a query to dynamically generate the column names 

-- DECLARE @SQLStr NVARCHAR(1024)
SET @SQLStr = ''
SELECT @SQLStr = @SQLStr  + [a].[Column] + ', '
  FROM 
    (SELECT DISTINCT Region as [Column]
      FROM RawData  ) as a

SET @SQLStr = Left(@SQLStr, Len(@SQLStr) - 1)

SET @SQLStr = 'SELECT Category, ' 
    + @SQLStr 
    + ' FROM RawData PIVOT (Sum (Amount) FOR Region IN ('
    + @SQLStr
    + ')) AS pt'
PRINT @SQLStr

EXEC sp_executesql @SQLStr

---------------------------------------------------------------
-- UnPivot

IF EXISTS(SELECT * FROM sysobjects WHERE Name = 'PTable')
  DROP TABLE Ptable
go

SELECT Category, South, NorthEast, MidWest, West into PTable
  FROM (Select Category, Region, Amount from RawData) sq
    PIVOT 
      (Sum (Amount)
      FOR Region IN (South, NorthEast, MidWest, West)
      ) AS pt

Select * from PTable

Select * 
  FROM PTable
    UnPivot 
      (Measure FOR Region IN (South, NorthEast, MidWest, West)) as sq
  
---------------------------------------------------------------
-- Cummulative - Running Totals  (not in text) 

-- Simple Correlated Subquery Method
-- Groups same DateTime data together
-- All data 
SELECT SalesDate, Amount,
    (SELECT SUM(Amount) 
       FROM RawData
       WHERE SalesDate <= R.SalesDate ) as Balance
  FROM RawData R
  ORDER BY SalesDate

-----------------------------------------
-- Beginning with a balance
ALTER TABLE RawData
  ADD Balance INT

-- Post some balances
UPDATE RawData 
  SET Balance = 
    (SELECT SUM(Amount) 
       FROM RawData
       WHERE SalesDate <= R.SalesDate )
  FROM RawData R
  WHERE SalesDate <= '4/1/2006'

-- check the balances
SELECT * FROM RawData ORDER BY SalesDate

-- determine last balance entry
SELECT Max(SalesDate) FROM RawData WHERE Balance IS NOT NULL

-- update new rows following previous update
SELECT *,
    (SELECT SUM(Amount) + 
        (SELECT DISTINCT Balance
          FROM RawData 
          WHERE SalesDate = (
            SELECT Max(SalesDate) 
              FROM RawData 
              WHERE Balance IS NOT NULL))
       FROM RawData
       WHERE SalesDate <= R.SalesDate
         AND SalesDate > (SELECT Max(SalesDate) 
              FROM RawData 
              WHERE Balance IS NOT NULL) )
  FROM RawData R
  WHERE Balance IS NULL
    
----------------------------------------------------------
-- reset the Balance
UPDATE RawData SET Balance = NULL

----------------------------------------------------------
-- Cursor Method

-- Row based work will require a PK
ALTER TABLE RawData
  ADD ID INT IDENTITY NOT NULL PRIMARY KEY

-- Identify the last good balance date
-- row prior to earliest row with null balance

----------------------------------------------------------
-- Cursor - 5 steps 
DECLARE 
  @BeginningBalanceDate DateTime,
  @BeginningBalanceAmount INT,
  @CurrentBalance INT,
  @CurrentID INT,
  @CurrentAmount INT

SELECT 
  @BeginningBalanceDate = SalesDate,
  @CurrentBalance = Balance
  FROM RawData
  WHERE SalesDate = 
      (SELECT Max(SalesDate)
        FROM RawData
        WHERE SalesDate < 
            (SELECT Min(SalesDate)
              FROM RawData
              WHERE Balance IS NULL))

-- 1 Declare the cursor
-- Select all rows foloowing last row with a good balance
-- (this will handle gaps in the balance)
DECLARE cBalance CURSOR FAST_FORWARD READ_ONLY
  FOR SELECT ID, Amount
        FROM RawData 
        WHERE SalesDate > @BeginningBalanceDate
        ORDER BY SalesDate

-- 2 Open the Cursor
OPEN cBalance
-- 3 Prime the Cursor, then loop 
FETCH cBalance INTO @CurrentID, @CurrentAmount  -- prime the cursor

  WHILE @@Fetch_Status = 0
    BEGIN
      SET @CurrentBalance = @CurrentBalance + IsNull(@CurrentAmount, 0)

      UPDATE RawData
        SET Balance = @CurrentBalance 
        WHERE ID = @CurrentID

        PRINT @CurrentBalance
      
      -- 3       
      FETCH cBalance INTO @CurrentID, @CurrentAmount  -- fetch next
    END

-- 4 Close 
CLOSE cBalance

-- 5 Clean up Memory
DEALLOCATE cBalance

-- check the balances
SELECT * FROM RawData ORDER BY SalesDate

