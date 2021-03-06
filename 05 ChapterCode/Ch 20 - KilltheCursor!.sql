/*
SQL Server 2005 Bible 
www.sqlserverbible.com
Paul Nielsen
John Wiley & Sons, Inc  

Chapter 20 - Kill the Cursor!
*/



---------------------------------------------------
-- Cursors

-- Cursor default scope

ALTER DATABASE Family SET CURSOR_DEFAULT LOCAL

SELECT  DATABASEPROPERTYEX('Family', 'IsLocalCursorsDefault')

-- This cursor example is for comparison with the Recursive Select Variable code
-- List the event dates for a tour

--Denormalizing a List with a Cursor
USE CHA2

-- Check the data
SELECT DateBegin
  FROM Event 
    JOIN Tour
      ON Event.TourID = Tour.TourID
    WHERE Tour.[Name] = 'Outer Banks Lighthouses'

-- The cursor batch
USE CHA2
DECLARE 
  @EventDates VARCHAR(1024),
  @EventDate DATETIME,
  @SemiColon BIT

SET @Semicolon = 0
SET @EventDates = ''

DECLARE cEvent CURSOR FAST_FORWARD
  FOR SELECT DateBegin
      FROM Event 
        JOIN Tour
          ON Event.TourID = Tour.TourID
        WHERE Tour.[Name] = 'Outer Banks Lighthouses'

  OPEN cEvent
  FETCH cEvent INTO @EventDate  -- prime the cursor

  WHILE @@Fetch_Status = 0 
    BEGIN
      IF @Semicolon = 1
        SET @EventDates = @EventDates + '; ' + Convert(VARCHAR(15), @EventDate, 107 )
      ELSE 
        BEGIN
          SET @EventDates = Convert(VARCHAR(15), @EventDate,107 )
          SET @SEMICOLON = 1
        END
       
        FETCH cEvent INTO @EventDate  -- fetch next
    END
  CLOSE cEvent
DEALLOCATE cEvent

SELECT @EventDates







-- The Task:

-- Calculate the adjusted amount depending on ActionCode.Formula:
-- 1-Normal       BaseRate * Amount * ActionCode's BaseMultipler
-- 2-Accelerated  BaseRate * Amount * Acceleration Rate
-- 3-Prototype    Amount * ActionCode's BaseMultipler

-- Exception Handling
-- If there's an Executive OverRide on the Order Row 
--   then ignore the Action Code BaseMultiplier

-- If the TransDate is a weekend add x2.5 multipler
-- If the client is a Premium Client apply 20% discount to Adjusted Rate 
-- If the client is a Probono client adjusted rate is zero

-- If the SalesPerson has less than 90 days employment apply no mulitpler

-- Test Database

USE Master
go
IF EXISTS (SELECT * FROM SysDatabases WHERE NAME='KilltheCursor')
  DROP DATABASE KilltheCursor
go
CREATE DATABASE KilltheCursor
  ON PRIMARY
    (NAME = 'KilltheCursor', FILENAME = 'C:\SQLdata\KilltheCursor.mdf')
  LOG ON (NAME = 'KilltheCursorLog',  FILENAME = 'C:\SQLdata\KilltheCursor.ldf')

go
USE KilltheCursor

-- Test Tables

CREATE TABLE dbo.Variable (
  Name     VARCHAR(25),
  Value    NUMERIC (7,4)
  )

CREATE TABLE dbo.SalesPerson (
  SalesPersonID INT NOT NULL IDENTITY
    PRIMARY KEY,
  Name VARCHAR(25),
  StartDate DATETIME,
  CommissionRate NUMERIC(5,4)
  )

CREATE TABLE dbo.ClientType (
  ClientTypeID INT PRIMARY KEY,
  Name VARCHAR(25),
  Multiplier NUMERIC(4,3)
  ) 

CREATE TABLE dbo.Client ( 
  ClientID INT NOT NULL IDENTITY
    PRIMARY KEY clustered,
  Name VARCHAR(25),
  ClientTypeID INT
    FOREIGN KEY REFERENCES dbo.ClientType,
  SalesPersonID INT
    FOREIGN KEY REFERENCES dbo.SalesPerson
  ) 

CREATE TABLE Category (
  CategryID INT NOT NULL IDENTITY
    PRIMARY KEY,
  Name VARCHAR(25),
  CommissionRate NUMERIC(5,4)
  )

CREATE TABLE Product (
  ProductID INT NOT NULL IDENTITY
    PRIMARY KEY,
  CategoryID INT
    FOREIGN KEY REFERENCES dbo.Category,
  Name VARCHAR(25)
  )

CREATE TABLE dbo.[Order] (
  OrderID INT NOT NULL IDENTITY
    PRIMARY KEY,
  ClientID INT NOT NULL
    FOREIGN KEY REFERENCES dbo.Client,    
  OrderCode CHAR(7),
  TransDate DATETIME,
  ExecOverride BIT NOT NULL DEFAULT(0)
  )

create nonclustered index orderclient
  on [order](clientid)

CREATE TABLE ActionCode (
  ActionCode CHAR(2)
    PRIMARY KEY,
  BaseMultiplier NUMERIC(3,2),
  Formula SMALLINT
  )

CREATE TABLE dbo.Detail (
  DetailID INT NOT NULL IDENTITY
    PRIMARY KEY, -- nonclustered,
  OrderID INT NOT NULL
    FOREIGN KEY REFERENCES dbo.[Order],
  ActionCode CHAR(2) NOT NULL 
    FOREIGN KEY REFERENCES dbo.ActionCode,
  BaseRate  NUMERIC(7,2)  NULL,
  Amount    NUMERIC(7,2)  NULL,
  AdjAmount NUMERIC(7,2)  NULL
  )

-- create clustered index detailOrderFK
--   ON Detail(OrderID)

CREATE TABLE dbo.DayOfWeekMultiplier (
  DayOfWeek SMALLINT,
  Multiplier NUMERIC(7,2)
  )

CREATE TABLE Performance (
  DataSize INT,
  Method VARCHAR(255),
  Duration DATETIME
  )



-- Create Sprocs
go
IF EXISTS (SELECT * FROM SysObjects WHERE NAME='CalcAdjAmount')
  DROP PROC CalcAdjAmount
go

CREATE PROC CalcAdjAmount (
  @DetailID INT,
  @AdjustedAmount NUMERIC(7,2) OUTPUT
  )
AS 
SET NoCount ON 

-- sproc receives an DetailID
-- and Returns the Adjusted Amount

    DECLARE 
      @Formula SMALLINT,      
      @AccRate NUMERIC (7,4),
      @IgnoreBaseMultiplier BIT,
      @TransDate INT,
      @ClientTypeID INT

    SELECT @Formula = Formula
      FROM Detail
        JOIN ActionCode
          ON Detail.ActionCode = ActionCode.ActionCode
      WHERE DetailID = @DetailID
  
    SET @IgnoreBaseMultiplier = 0

    SELECT @IgnoreBaseMultiplier = ExecOverRide 
      FROM [Order]
        JOIN Detail
          ON [Order].OrderID = Detail.OrderID
      WHERE DetailID = @DetailID

      
    -- 1-Normal       BaseRate * Amount * ActionCode's BaseMultipler
    IF @Formula = 1
      BEGIN
        IF @IgnoreBaseMultiplier = 1
          SELECT @AdjustedAmount = BaseRate * Amount 
            FROM Detail
              JOIN ActionCode
                ON Detail.ActionCode = ActionCode.ActionCode
            WHERE DetailID  = @DetailID 
        ELSE            
          SELECT @AdjustedAmount = BaseRate * Amount * BaseMultiplier
            FROM Detail
              JOIN ActionCode
                ON Detail.ActionCode = ActionCode.ActionCode
            WHERE DetailID  = @DetailID 
      END


    -- 2-Accelerated  BaseRate * Amount * Acceleration Rate
    IF @Formula = 2
      BEGIN
        SELECT @AccRate = Value
          FROM dbo.Variable
            WHERE Name = 'AccRate'
      
        SELECT @AdjustedAmount = BaseRate * Amount * @AccRate
          FROM Detail
            JOIN ActionCode
              ON Detail.ActionCode = ActionCode.ActionCode
          WHERE DetailID = @DetailID 
      END


    -- 3-Prototype    Amount * ActionCode's BaseMultipler
    IF @Formula = 3
        BEGIN
          IF @IgnoreBaseMultiplier = 1
            SELECT @AdjustedAmount = Amount 
              FROM Detail
                JOIN ActionCode
                  ON Detail.ActionCode = ActionCode.ActionCode
              WHERE DetailID = @DetailID 
          ELSE
            SELECT @AdjustedAmount = Amount * BaseMultiplier
              FROM Detail
                JOIN ActionCode
                  ON Detail.ActionCode = ActionCode.ActionCode
              WHERE DetailID = @DetailID 
        END

        -- Weekend Adjustment
        SELECT @TransDate = DatePart(dw,TransDate), @ClientTypeID = ClientTypeID 
          FROM [Order]
            JOIN Detail
              ON [Order].OrderID = Detail.OrderID
            JOIN Client
              ON Client.ClientID = [Order].OrderID
        WHERE DetailID = @DetailID 

        IF @TransDate = 1 OR @TransDate = 7
          SET @AdjustedAmount = @AdjustedAmount * 2.5

        -- Client Adjustments
        IF @ClientTypeID = 1 
          SET @AdjustedAmount = @AdjustedAmount * .8

        IF @ClientTypeID = 2 
          SET @AdjustedAmount = 0
        
RETURN
go

--------------------------------
-- Scalar UDF

CREATE FUNCTION fCalcAdjAmount (@DetailID INT) 
RETURNS NUMERIC(7,2)
AS 
BEGIN


-- sproc receives an DetailID
-- and Returns the Adjusted Amount

    DECLARE 
      @AdjustedAmount NUMERIC(7,2),
      @Formula SMALLINT,      
      @AccRate NUMERIC (7,4),
      @IgnoreBaseMultiplier BIT,
      @TransDate INT,
      @ClientTypeID INT

    SELECT @Formula = Formula
      FROM Detail
        JOIN ActionCode
          ON Detail.ActionCode = ActionCode.ActionCode
      WHERE DetailID = @DetailID
  
    SET @IgnoreBaseMultiplier = 0

    SELECT @IgnoreBaseMultiplier = ExecOverRide 
      FROM [Order]
        JOIN Detail
          ON [Order].OrderID = Detail.OrderID
      WHERE DetailID = @DetailID

      
    -- 1-Normal       BaseRate * Amount * ActionCode's BaseMultipler
    IF @Formula = 1
      BEGIN
        IF @IgnoreBaseMultiplier = 1
          SELECT @AdjustedAmount = BaseRate * Amount 
            FROM Detail
              JOIN ActionCode
                ON Detail.ActionCode = ActionCode.ActionCode
            WHERE DetailID  = @DetailID 
        ELSE            
          SELECT @AdjustedAmount = BaseRate * Amount * BaseMultiplier
            FROM Detail
              JOIN ActionCode
                ON Detail.ActionCode = ActionCode.ActionCode
            WHERE DetailID  = @DetailID 
      END


    -- 2-Accelerated  BaseRate * Amount * Acceleration Rate
    IF @Formula = 2
      BEGIN
        SELECT @AccRate = Value
          FROM dbo.Variable
            WHERE Name = 'AccRate'
      
        SELECT @AdjustedAmount = BaseRate * Amount * @AccRate
          FROM Detail
            JOIN ActionCode
              ON Detail.ActionCode = ActionCode.ActionCode
          WHERE DetailID = @DetailID 
      END


    -- 3-Prototype    Amount * ActionCode's BaseMultipler
    IF @Formula = 3
        BEGIN
          IF @IgnoreBaseMultiplier = 1
            SELECT @AdjustedAmount = Amount 
              FROM Detail
                JOIN ActionCode
                  ON Detail.ActionCode = ActionCode.ActionCode
              WHERE DetailID = @DetailID 
          ELSE
            SELECT @AdjustedAmount = Amount * BaseMultiplier
              FROM Detail
                JOIN ActionCode
                  ON Detail.ActionCode = ActionCode.ActionCode
              WHERE DetailID = @DetailID 
        END

        -- Weekend Adjustment
        SELECT @TransDate = DatePart(dw,TransDate), @ClientTypeID = ClientTypeID 
          FROM [Order]
            JOIN Detail
              ON [Order].OrderID = Detail.OrderID
            JOIN Client
              ON Client.ClientID = [Order].OrderID
        WHERE DetailID = @DetailID 

        IF @TransDate = 1 OR @TransDate = 7
          SET @AdjustedAmount = @AdjustedAmount * 2.5

        -- Client Adjustments
        IF @ClientTypeID = 1 
          SET @AdjustedAmount = @AdjustedAmount * .8

        IF @ClientTypeID = 2 
          SET @AdjustedAmount = 0

    RETURN  @AdjustedAmount 

END
go

-- Static Test Data

INSERT dbo.DayOfWeekMultiplier ( DayOfWeek, Multiplier)
  VALUES( 1, 2.5)
INSERT dbo.DayOfWeekMultiplier ( DayOfWeek, Multiplier)
  VALUES( 2, 1)
INSERT dbo.DayOfWeekMultiplier ( DayOfWeek, Multiplier)
  VALUES( 3, 1)
INSERT dbo.DayOfWeekMultiplier ( DayOfWeek, Multiplier)
  VALUES( 4, 1)
INSERT dbo.DayOfWeekMultiplier ( DayOfWeek, Multiplier)
  VALUES( 5, 1)
INSERT dbo.DayOfWeekMultiplier ( DayOfWeek, Multiplier)
  VALUES( 6, 1)
INSERT dbo.DayOfWeekMultiplier ( DayOfWeek, Multiplier)
  VALUES( 7, 2.5)

INSERT dbo.ClientType (ClientTypeID, Name, Multiplier)
  VALUES ( 0, 'Normal', 1)
INSERT dbo.ClientType (ClientTypeID, Name, Multiplier)
  VALUES ( 1, 'Premium', .8)
INSERT dbo.ClientType (ClientTypeID, Name, Multiplier)
  VALUES ( 2, 'ProBono', 0)

INSERT dbo.Variable (Name, Value)
  VALUES ('AccRate', 1.3)

INSERT dbo.Category (Name, CommissionRate)
  VALUES ('One', .01)
INSERT dbo.Category (Name, CommissionRate)
  VALUES ('Two', .015)
INSERT dbo.Category (Name, CommissionRate)
  VALUES ('Three', .025)
INSERT dbo.Category (Name, CommissionRate)
  VALUES ('Four', .05)



INSERT dbo.SalesPerson (Name, CommissionRate)
  VALUES ('Sam', .01)
INSERT dbo.SalesPerson (Name, CommissionRate)
  VALUES ('Joe', .02)
INSERT dbo.SalesPerson (Name, CommissionRate)
  VALUES ('Mary', .025)

INSERT dbo.ActionCode (ActionCode, BaseMultiplier, Formula)
  VALUES ('AA', 1.15, 1)
INSERT dbo.ActionCode (ActionCode, BaseMultiplier, Formula)
  VALUES ('xO', 1.25, 1)
INSERT dbo.ActionCode (ActionCode, BaseMultiplier, Formula)
  VALUES ('CO', .864, 1)
INSERT dbo.ActionCode (ActionCode, BaseMultiplier, Formula)
  VALUES ('WA', 1.15, 2)
INSERT dbo.ActionCode (ActionCode, BaseMultiplier, Formula)
  VALUES ('CA', 4.5, 2)
INSERT dbo.ActionCode (ActionCode, BaseMultiplier, Formula)
  VALUES ('FR', 1.28, 3)
go

----------------------------------------------------------------
----------------------------------------------------------------
-- Master Test Loop 
----------------------------------------------------------------
----------------------------------------------------------------
-- Data Gen Loops


DECLARE 
  @Counter    INT,
  @OrderCode  CHAR(7),
  @TransDate  DATETIME,
  @ExecOverRide BIT, 
  @OrderID   INT,
  @ClientID INT, 
  @ActionCode CHAR(2), 
  @BaseRate   NUMERIC(7,2), 
  @Amount     NUMERIC(7,2),
  @MaxOrder  INT,
  @ActionCodeCount SMALLINT,
  @Name VARCHAR(25),
  @ClientTypeID SMALLINT,
  @SalesPersonID INT,
  @SalesPersonCount INT,
  @MaxClientID INT,
  @MasterCounter INT,
  @StartTime DATETIME,
  @cDetailID INT,
  @SprocResult NUMERIC (7,2)

  Set @MasterCounter = 0



-- This determines the size of the data
-- each iteration adds the same number of rows

WHILE @MasterCounter < 10
Begin 

SET @MasterCounter = @MasterCounter + 1

-- Clients
SET @Counter = 0
SELECT @SalesPersonCount = Max(SalesPersonID)
  FROM dbo.SalesPerson
WHILE @Counter < @MasterCounter * 100  --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  BEGIN
    SET @Counter = @Counter + 1

      SET @Name = LEFT(CAST(NewID() as VARCHAR(36)),7)
      
      SET @ClientTypeID = 
        CASE CAST(Rand()*10 AS SMALLINT)
          WHEN 8 THEN 1  -- Premium
          WHEN 9 THEN 1
          WHEN 1 THEN 2  -- Probono
          ELSE 0 
        END 

      SELECT @SalesPersonID = SalesPersonID
        FROM (SELECT SalesPersonID, ROW_NUMBER() OVER (order by SalesPersonID) AS RowNum
                FROM SalesPerson) SQ
        WHERE RowNum = CAST(@SalesPersonCount * RAND() as INT) + 1

      INSERT dbo.Client (Name, ClientTypeID, SalesPersonID)
        VALUES (@Name, @ClientTypeID, @SalesPersonID)
  END 



-- Orders
SELECT @MaxClientID = Max(ClientID)
  FROM dbo.Client
SET @Counter = 0
WHILE @Counter < @MasterCounter * 250  --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  BEGIN
    SET @Counter = @Counter + 1

      SET @OrderCode = LEFT(CAST(NewID() as VARCHAR(36)),7)

      SET @ExecOverRide = 
        CASE CAST(Rand()*10 AS SMALLINT)
          WHEN 7 THEN 1
          ELSE 0 
        END 

    SELECT @ClientID = ClientID
      FROM (SELECT ClientID, ROW_NUMBER() OVER (order by ClientID) AS RowNum
              FROM dbo.Client) SQ
      WHERE RowNum = CAST(@MaxClientID * RAND() as INT) + 1

    INSERT dbo.[Order] (ClientID, OrderCode, TransDate, ExecOverride)
      VALUES (@ClientID, @OrderCode, cast(rand()*50000 as datetime), @ExecOverRide)

   END 

-- Order Details
SET @Counter = 0
SELECT @MaxOrder = Max(OrderID)
  FROM dbo.[Order]
SELECT @ActionCodeCount = COUNT(*)
  FROM dbo.ActionCode

WHILE @Counter < @MasterCounter * 100    -- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  BEGIN
    SET @Counter = @Counter + 1

    SET @OrderID = CAST(@MaxOrder * RAND() as INT) + 1
 
    SELECT @ActionCode = ActionCode
      FROM (SELECT ActionCode, ROW_NUMBER() OVER (order by ActionCode) AS RowNum
              FROM ActionCode) SQ
      WHERE RowNum = CAST(@ActionCodeCount * RAND() as INT) + 1

    SET @BaseRate =  CAST(RAND() * 3 as NUMERIC(7,2))
    SET @Amount =  CAST(RAND() * 5128 as NUMERIC(7,2))    

    INSERT dbo.Detail (OrderID, ActionCode, BaseRate, Amount)
      VALUES (@OrderID, @ActionCode, @BaseRate, @Amount)

  END 



-- attempt to weight the Action Codes
 /*
DECLARE 
  @ActionCodeCount SMALLINT

SELECT @ActionCodeCount = COUNT(*)
  FROM dbo.ActionCode

SELECT ActionCode
  FROM (SELECT ActionCode, ROW_NUMBER() OVER (order by ActionCode) AS RowNum
          FROM ActionCode) SQ
  WHERE RowNum = CAST(@ActionCodeCount * RAND() as INT) + 1

*/



----------------------------------------------------------------
----------------------------------------------------------------
-- Performance Tests


-- The Task:

-- Calculate the adjusted amount depending on ActionCode.Formula:
-- 1-Normal       BaseRate * Amount * ActionCode's BaseMultipler
-- 2-Accelerated  BaseRate * Amount * Acceleration Rate
-- 3-Prototype    Amount * ActionCode's BaseMultipler

-- Caclulate Commission on Adjusted Amount
-- Commission is SalesPerson Rate + Product Type Rate based on BaseRate * Amount

-- Exception Handling
-- If there's an Executive OverRide on the Order Row 
--   then ignore the Action Code BaseMultiplier

-- If the TransDate is a weekend add x2.5 multipler
-- If the SalesPerson has less than 90 days employment apply no mulitpler
-- If a salesperson other than their normal salesperson makes the sale the two salesperson's split the commision 50-50
-- If the client is a Premium Client apply 20% discount to Adjusted Rate 
-- If the client is a Probono client adjusted rate is zero


----------------------------------------------------------------
----------------------------------------------------------------
-- Single Row Sproc



-- SQL-92 Cursor Cursor & Sproc 
Set @Counter = 0
While @Counter < 3
Begin
  SET @Counter = @Counter + 1
  ----------------------------------
  UPDATE Detail SET AdjAmount = NULL
  ----------------------------------
  SET @StartTime = getdate()

-- 1
DECLARE cDetail CURSOR 
  FOR SELECT DetailID
      FROM Detail 
        WHERE AdjAmount IS NULL
  FOR READ ONLY

-- 2  
OPEN cDetail
-- 3
FETCH cDetail INTO @cDetailID  -- prime the cursor
  EXEC CalcAdjAmount 
    @DetailID = @cDetailID,
    @AdjustedAmount = @SprocResult OUTPUT
  UPDATE Detail
    SET AdjAmount  = @SprocResult
    WHERE DetailID = @cDetailID


  WHILE @@Fetch_Status = 0 
    BEGIN
      BEGIN
        EXEC CalcAdjAmount 
          @DetailID = @cDetailID,
          @AdjustedAmount = @SprocResult OUTPUT 
        UPDATE Detail
          SET AdjAmount  = @SprocResult
          WHERE DetailID = @cDetailID
      END
      
      -- 3       
      FETCH cDetail INTO @cDetailID  -- fetch next
    END

-- 4  
CLOSE cDetail

-- 5
DEALLOCATE cDetail

  INSERT Performance (DataSize, Method, Duration)
    VALUES (@MasterCounter, 'SQL -92 Cursor / Update from Sproc', GetDate() - @StartTime)
END




-- T-SQL Cursor Fast Forward Cursor & Sproc 
Set @Counter = 0
While @Counter < 3
Begin
  SET @Counter = @Counter + 1
  ----------------------------------
  UPDATE Detail SET AdjAmount = NULL
  ----------------------------------
  SET @StartTime = getdate()

-- 1
DECLARE cDetail CURSOR FAST_FORWARD READ_ONLY
  FOR SELECT DetailID
      FROM Detail 
        WHERE AdjAmount IS NULL
-- 2  
OPEN cDetail
-- 3
FETCH cDetail INTO @cDetailID  -- prime the cursor
  EXEC CalcAdjAmount 
    @DetailID = @cDetailID,
    @AdjustedAmount = @SprocResult OUTPUT
  UPDATE Detail
    SET AdjAmount  = @SprocResult
    WHERE DetailID = @cDetailID


  WHILE @@Fetch_Status = 0 
    BEGIN
      BEGIN
        EXEC CalcAdjAmount 
          @DetailID = @cDetailID,
          @AdjustedAmount = @SprocResult OUTPUT 
        UPDATE Detail
          SET AdjAmount  = @SprocResult
          WHERE DetailID = @cDetailID
      END
      
      -- 3       
      FETCH cDetail INTO @cDetailID  -- fetch next
    END

-- 4  
CLOSE cDetail

-- 5
DEALLOCATE cDetail

  INSERT Performance (DataSize, Method, Duration)
    VALUES (@MasterCounter, 'FastForward Cursor / Update from Sproc', GetDate() - @StartTime)
END



-- Fast Forward Cursor / Function
Set @Counter = 0
While @Counter < 3
Begin  
  SET @Counter = @Counter + 1
  ----------------------------------
  UPDATE Detail SET AdjAmount = NULL
  ----------------------------------
  SET @StartTime = getdate()-- 

-- 1
DECLARE cDetail CURSOR FAST_FORWARD READ_ONLY
  FOR SELECT DetailID
      FROM Detail 
        WHERE AdjAmount IS NULL
-- 2  
OPEN cDetail
-- 3
FETCH cDetail INTO @cDetailID  -- prime the cursor
  UPDATE Detail
    SET AdjAmount  = dbo.fCalcAdjAmount(@cDetailID)
    WHERE DetailID = @cDetailID


  WHILE @@Fetch_Status = 0 
    BEGIN
        UPDATE Detail
          SET AdjAmount  = dbo.fCalcAdjAmount(@cDetailID)
          WHERE DetailID = @cDetailID
      
      -- 3       
      FETCH cDetail INTO @cDetailID  -- fetch next
    END

-- 4  
CLOSE cDetail

-- 5
DEALLOCATE cDetail

  INSERT Performance (DataSize, Method, Duration)
    VALUES (@MasterCounter, 'Fast Forward Cursor / Update from UDF', GetDate() - @StartTime)
END




-- Update Cursor & Sproc 
Set @Counter = 0
While @Counter < 3
Begin  
  SET @Counter = @Counter + 1
  ----------------------------------
  UPDATE Detail SET AdjAmount = NULL
  ----------------------------------
  SET @StartTime = getdate()

-- 1
DECLARE cDetail CURSOR 
  FOR SELECT DetailID
      FROM Detail 
  WHERE AdjAmount IS NULL
  FOR Update of AdjAmount      

-- 2  
OPEN cDetail
-- 3
FETCH cDetail INTO @cDetailID  -- prime the cursor
  EXEC CalcAdjAmount 
    @DetailID = @cDetailID,
    @AdjustedAmount = @SprocResult OUTPUT
  UPDATE Detail
    SET AdjAmount = @SprocResult
    WHERE Current of cDetail


  WHILE @@Fetch_Status = 0 
    BEGIN
      BEGIN
        EXEC CalcAdjAmount 
          @DetailID = @cDetailID,
          @AdjustedAmount = @SprocResult OUTPUT 
        UPDATE Detail
          SET AdjAmount = @SprocResult
          WHERE Current of cDetail
      END
      
      -- 3       
      FETCH cDetail INTO @cDetailID  -- fetch next
    END

-- 4  
CLOSE cDetail

-- 5
DEALLOCATE cDetail


  INSERT Performance (DataSize, Method, Duration)
    VALUES (@MasterCounter, 'Update Cursor', GetDate() - @StartTime)

END


--------------------------------------------------------------
--------------------------------------------------------------
-- Index Set 1
/*
Drop Index Detail.Detail_OrderFK
Drop Index Detail.Detail_ActionCodeFK
Drop Index Detail.Detail_DTA

Create Index Detail_OrderFK 
  ON dbo.Detail (OrderID, DetailID)

Create Index Detail_ActionCodeFK 
  ON dbo.Detail ( ActionCode, DetailID)

CREATE NONCLUSTERED INDEX Detail_DTA ON [dbo].[Detail] 
(
	[AdjAmount],
	[OrderID],
	[ActionCode],
	[DetailID]
) ON [PRIMARY]

*/


-- Query w/Function
Set @Counter = 0
While @Counter < 3
Begin
  SET @Counter = @Counter + 1
  ----------------------------------
  UPDATE Detail SET AdjAmount = NULL
  ----------------------------------
  SET @StartTime = getdate()
  
    UPDATE dbo.Detail
      SET AdjAmount  = dbo.fCalcAdjAmount(DetailID)
      WHERE AdjAmount IS NULL

  INSERT Performance (DataSize, Method, Duration)
    VALUES (@MasterCounter, 'Query w/Function', GetDate() - @StartTime)
END 


-- Multiple Queries
Set @Counter = 0
While @Counter < 3
Begin
  SET @Counter = @Counter + 1
  ----------------------------------
  UPDATE Detail SET AdjAmount = NULL
  ----------------------------------
  SET @StartTime = getdate()


    -- 1-Normal       BaseRate * Amount * ActionCode's BaseMultipler

UPDATE dbo.Detail
  SET AdjAmount = BaseRate * Amount 
  FROM Detail
    JOIN ActionCode
      ON Detail.ActionCode = ActionCode.ActionCode
    JOIN [Order]
    ON [Order].OrderID = Detail.OrderID
  WHERE (Formula = 1 OR Formula = 3 )AND ExecOverRide = 1
    AND AdjAmount IS NULL

UPDATE dbo.Detail
  SET AdjAmount = BaseRate * Amount * BaseMultiplier
  FROM Detail
    JOIN ActionCode
      ON Detail.ActionCode = ActionCode.ActionCode
    JOIN [Order]
    ON [Order].OrderID = Detail.OrderID
  WHERE Formula = 1 AND ExecOverRide = 0
    AND AdjAmount IS NULL

-- 2-Accelerated  BaseRate * Amount * Acceleration Rate

UPDATE dbo.Detail
  SET AdjAmount = BaseRate * Amount * (SELECT Value
                                          FROM dbo.Variable
                                            WHERE Name = 'AccRate')
  FROM Detail
    JOIN ActionCode
      ON Detail.ActionCode = ActionCode.ActionCode
    JOIN [Order]
    ON [Order].OrderID = Detail.OrderID
  WHERE Formula = 2 
    AND AdjAmount IS NULL

-- 3-Prototype    Amount * ActionCode's BaseMultipler

UPDATE dbo.Detail
  SET AdjAmount = Amount * BaseMultiplier
  FROM Detail
    JOIN ActionCode
      ON Detail.ActionCode = ActionCode.ActionCode
    JOIN [Order]
    ON [Order].OrderID = Detail.OrderID
  WHERE Formula = 3 AND ExecOverRide = 0
    AND AdjAmount IS NULL

-- Exceptions

-- WeekEnd Adjustment
UPDATE dbo.Detail
  SET AdjAmount = AdjAmount * Multiplier
  FROM Detail
    JOIN [Order]
      ON [Order].OrderID = Detail.OrderID
    JOIN DayOfWeekMultiplier DWM
      ON CAST(DatePart(dw,[Order].TransDate) as SMALLINT) = DWM.DayOfWeek

    -- Client Adjustments
UPDATE dbo.Detail
  SET AdjAmount = AdjAmount * Multiplier
  FROM Detail
    JOIN [Order]
      ON [Order].OrderID = Detail.OrderID
    JOIN Client
      ON [Order].ClientID = Client.ClientID
    Join ClientType
      ON Client.ClientTypeID = ClientType.ClientTypeID
    INSERT Performance (DataSize, Method, Duration)
      VALUES (@MasterCounter, 'Multiple Queries', GetDate() - @StartTime)
  END


-- Case Expression
Set @Counter = 0
While @Counter < 3
Begin
  SET @Counter = @Counter + 1
  ----------------------------------
  UPDATE Detail SET AdjAmount = NULL
  ----------------------------------
  SET @StartTime = getdate()
  
UPDATE dbo.Detail
SET AdjAmount = DWM.Multiplier * ClientType.Multiplier *
  CASE
    WHEN Formula = 1 AND ExecOverRide = 0
      THEN BaseRate * Amount * BaseMultiplier
    WHEN (Formula = 1 OR Formula = 3 )AND ExecOverRide = 1  
      THEN BaseRate * Amount 
    WHEN Formula = 2
      THEN BaseRate * Amount * (SELECT Value
                                        FROM dbo.Variable
                                          WHERE Name = 'AccRate')
    WHEN (Formula = 3 AND ExecOverRide = 0)
      THEN Amount * BaseMultiplier
  END 
FROM Detail
  JOIN ActionCode
    ON Detail.ActionCode = ActionCode.ActionCode
  JOIN [Order]
    ON [Order].OrderID = Detail.OrderID
  JOIN Client
    ON [Order].ClientID = Client.ClientID
  Join ClientType
    ON Client.ClientTypeID = ClientType.ClientTypeID
  JOIN DayOfWeekMultiplier DWM
    ON CAST(DatePart(dw,[Order].TransDate) as SMALLINT) = DWM.DayOfWeek

WHERE AdjAmount IS NULL

      INSERT Performance (DataSize, Method, Duration)
        VALUES (@MasterCounter, 'Query w/Case', GetDate() - @StartTime)
    END



END -- Master Loop



-----------------------------------------------
SELECT Method, [1],[2],[3],[4],[5], [6],[7] , [8], [9], [10]
  FROM
  (Select Method, DataSize, 
    (DatePart(n, Duration) * 60000) + 
    (DatePart(s,Duration) * 1000) + 
    DatePart(ms, Duration) as ms
  from Performance) p
PIVOT
  (
  avg(ms)
  FOR DataSize IN ([1],[2],[3],[4],[5], [6],[7], [8], [9], [10])
  ) AS pvt
ORDER BY [4] Desc



Select Count(*) From Detail


















