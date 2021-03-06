-----------------------------------------------------------
-- SQL Server 2005 Bible 
-- Wiley Publishing
-- Paul Nielsen

-- Chapter 12 - Navigating Hierarchical Data

-----------------------------------------------------------
-- Basic Adjacency List Pattern

USE Northwind

SELECT EmployeeID, ReportsTo FROM Employees


USE Family
SELECT 
    Person.FirstName + ' ' + IsNull(Person.SrJr,'') 
      as Grandfather, 
    Gen1.FirstName  + ' ' +  IsNull(Gen1.SrJr,'') as Gen1, 
    Gen2.FirstName  + ' ' +  IsNull(Gen2.SrJr,'') as Gen2
  FROM Person
    LEFT JOIN Person Gen1
      ON Person.PersonID = Gen1.FatherID
    LEFT JOIN Person Gen2
      ON Gen1.PersonID = Gen2.FatherID
  WHERE Person.PersonID = 2


Select * from Person order by PersonID;


-- Using a Cursor
ALTER DATABASE Family SET CURSOR_DEFAULT LOCAL
SELECT DATABASEPROPERTYEX('Family', 'IsLocalCursorsDefault') 

CREATE PROCEDURE ExamineChild 
  (@ParentID INT)
AS
SET Nocount On
DECLARE @ChildID INT,
  @Childname VARCHAR(25)

DECLARE cChild CURSOR LOCAL FAST_FORWARD
  FOR SELECT PersonID, 
          Firstname + ' ' + LastName + ' ' + IsNull(SrJr,'') 
          as PersonName
        FROM Person
        WHERE Person.FatherID = @ParentID
          OR Person.MotherID = @ParentID
        ORDER BY Person.DateOfBirth
  OPEN cChild
  FETCH cChild INTO @ChildID, @ChildName  -- prime the cursor
  WHILE @@Fetch_Status = 0 
    BEGIN
      PRINT 
        SPACE(@@NestLevel * 2) + '+ '
          + Cast(@ChildID as VARCHAR(4))
          + ' ' + @ChildName
      -- Recursively find the grandchildren
      EXEC ExamineChild @ChildID
      FETCH cChild INTO @ChildID, @ChildName 
    END
  CLOSE cChild
DEALLOCATE cChild

go 

EXEC ExamineChild 2 

-- Using a Set-Based Solution
CREATE TABLE #FamilyTree (
  PersonID INT,
  Generation INT,
  FamilyLine VarChar(25) Default ''
  )

DECLARE 
  @Generation INT,
  @FirstPerson INT
  
SET @Generation = 1
SET @FirstPerson = 2

-- prime the temp table with the top person(s) in the queue
INSERT #FamilyTree (PersonID, Generation, FamilyLine)
  SELECT @FirstPerson, @Generation, @FirstPerson

WHILE @@RowCount > 0
  BEGIN 
    SET @Generation = @Generation + 1

    INSERT #FamilyTree (PersonID, Generation, FamilyLine)
      SELECT Person.PersonID, 
             @Generation, 
             #FamilyTree.FamilyLine 
             + ' ' + Str(Person.PersonID,5)
        FROM Person 
          JOIN #FamilyTree
            ON #FamilyTree.Generation = @Generation - 1
              AND 
              (Person.MotherID = #FamilyTree.PersonID
                OR 
               Person.FatherID = #FamilyTree.PersonID)

  END
go 

SELECT PersonID, Generation, FamilyLine
  FROM #FamilyTree
  Order by FamilyLine

SELECT SPACE(Generation * 2) + '+ ' 
          + Cast(#FamilyTree.PersonID as VARCHAR(4)) + ' ' 
          + FirstName + ' ' + LastName
          + IsNull(SrJr,'') AS FamilyTree
  FROM #FamilyTree
    JOIN Person 
      ON #FamilyTree.PersonID = Person.PersonID
  ORDER BY FamilyLine


---------------------------------------------------
-- Using a User-Defined Function 
go
CREATE FUNCTION dbo.FamilyTree
  (@PersonID CHAR(25))
  RETURNS @Tree TABLE (PersonID INT, LastName VARCHAR(25), FirstName VARCHAR(25), Lv INT)
AS 
BEGIN
  DECLARE @LC INT
  SET @LC = 1
  -- insert the anchor level
  INSERT @Tree
    SELECT PersonID, LastName, FirstName, @LC
      FROM dbo.Person with (NoLock)
      WHERE PersonID = @PersonID

   -- Loop through sub-levels
  WHILE @@RowCount > 0 
    BEGIN
        SET @LC = @LC + 1
        -- insert each Generation
        INSERT @Tree
          SELECT Tree.PersonID, Tree.LastName, Tree.FirstName, @LC
            FROM dbo.Person FamilyNode with (NoLock) 
              JOIN dbo.Person Tree with (NoLock) 
                ON FamilyNode.PersonID = Tree.MotherID
                  OR FamilyNode.PersonID = Tree.FatherID
              JOIN @Tree CC
                ON CC.PersonID = FamilyNode.PersonID
            WHERE CC.Lv = @LC - 1
      END 
    RETURN
  END 

-- end of function

Select * From dbo.FamilyTree(10);

-----------------------------------------------------
go
CREATE 
-- alter 
FUNCTION dbo.Ancestors
  (@PersonID CHAR(25))
  RETURNS @Tree TABLE (PersonID INT, LastName VARCHAR(25), FirstName VARCHAR(25), Lv INT)
AS 
BEGIN
  DECLARE @LC INT
  SET @LC = 1
  -- insert the top level
  INSERT @Tree
    SELECT PersonID, LastName, FirstName, @LC
      FROM dbo.Person with (NoLock)
      WHERE PersonID = @PersonID

   -- Loop through sub-levels
  WHILE @@RowCount > 0 
    BEGIN
        SET @LC = @LC + 1
        -- insert the Class level
        INSERT @Tree
          SELECT FamilyTree.PersonID, FamilyTree.LastName, FamilyTree.FirstName, @LC
            FROM dbo.Person FamilyNode with (NoLock) 
              JOIN dbo.Person FamilyTree with (NoLock) 
                ON FamilyNode.FatherID = FamilyTree.PersonID
              JOIN @Tree CC
                ON CC.PersonID = FamilyNode.PersonID
            WHERE CC.Lv = @LC - 1
      END 
    RETURN
  END ;

sELECT * FROM dbo.Ancestors(21)

Select P.PersonID, UDF.* 
  From Person as P
    CROSS APPLY dbo.Ancestors(P.PersonID) as UDF

--------------------------------------------
-- Recursive Query With Common Table Expression 

-- Define the CTE
WITH FamilyTree( LastName, FirstName, PersonID, lv)
AS (
   -- Anchor
      SELECT LastName, FirstName, PersonID, 1
        FROM Person A
        WHERE PersonID = 10

    -- Recursive Call
    UNION ALL
      SELECT Node.LastName,  Node.FirstName,  Node.PersonID, lv + 1
        FROM Person Node
          JOIN FamilyTree ft 
            ON Node.MotherID = ft.PersonID 
             OR Node.FatherID = ft.PersonID
    )
SELECT PersonID, LastName, FirstName,  lv
  FROM FamilyTree;

Select * From dbo.FamilyTree(10);

      














