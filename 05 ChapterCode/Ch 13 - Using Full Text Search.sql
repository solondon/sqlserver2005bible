-----------------------------------------------------------
-- SQL Server 2005 Bible 
-- Wiley Publishing 
-- Paul Nielsen

-- Chapter 13 - Using Full Text Search

-- This chapter script uses the 'Aesop's Fables' sample database
-- run Aesop.sql to create and load Aesop

-----------------------------------------------------------
-----------------------------------------------------------

USE AESOP

-- SQL Where Like
SELECT Title
  FROM Fable
  WHERE Fabletext LIKE '%lion%'
    AND Fabletext LIKE '%bold%'

-----------------------------------------------------------
-- Creating a Catalog with T-SQL Code


USE AESOP

CREATE FULLTEXT CATALOG AesopFT

CREATE FULLTEXT INDEX ON dbo.Fable(Title, Moral, Fabletext) 
	KEY INDEX FablePK ON AesopFT 
	WITH CHANGE_TRACKING AUTO


------------------------------------------------------
--Pushing Data to the Full-Text Index

-- Maintenance
EXEC sp_fulltext_table 'Fable', 'start_full'

--EXEC sp_fulltext_table 'Fable', 'start_incremental'
--EXEC sp_fulltext_catalog 'AesopFable', 'drop'

-- Starting the Full-Text Index
--EXEC sp_fulltext_table Fable, 'Start_change_tracking'
--EXEC sp_fulltext_table Fable, 'Start_background_updateindex'

--EXEC sp_fulltext_catalog 'AesopFable', 'rebuild'
--EXEC sp_fulltext_service 'clean_up'

-- sp_help
EXEC sp_help_fulltext_catalogs 'AesopFable'

EXEC sp_help_fulltext_tables 'AesopFable'

EXEC sp_help_fulltext_columns 'fable'



-----------------------------------------------------
-- Noise Files 
-- C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\FTData

-----------------------------------------------------
-- Word Searches

SELECT Title
  FROM Fable 
  WHERE CONTAINS (Fable.*,'Lion')

-- ContainsTable

SELECT * 
  FROM CONTAINSTABLE (Fable, *, 'Lion')

SELECT Fable.Title, Rank 
  FROM Fable  
    JOIN CONTAINSTABLE (Fable, *, 'Lion') FTS
    ON Fable.FableID = FTS.[KEY]
  ORDER BY FTS.Rank DESC

SELECT Fable.Title, Rank 
  FROM Fable  
    JOIN CONTAINSTABLE (Fable, *, 'Lion', 2) FTS
    ON Fable.FableID = FTS.[KEY]
  ORDER BY FTS.Rank

-----------------------------------------------------
-- Advanced Search Options

-- Multiple Word Searches
SELECT Title
  FROM Fable 
  WHERE CONTAINS (FableText,'Tortoise AND Hare')

SELECT Title
  FROM Fable 
  WHERE CONTAINS (*,' "Thrifty AND supperless" ')

SELECT Title
  FROM Fable 
  WHERE CONTAINS (*,'Thrifty')
    AND CONTAINS(*,'supperless')

-- Searches with Wildcards 
SELECT Title
  FROM Fable 
  WHERE CONTAINS (*,' "Hunt*" ')

-- Phrase Searches 
SELECT Title
  FROM Fable 
  WHERE CONTAINS (*,' "Wolf! Wolf!" ')

-- Word-Proximity Searches

SELECT Title
  FROM Fable 
  WHERE CONTAINS (*,'pardoned NEAR forest')

SELECT Title
  FROM Fable 
  WHERE CONTAINS (*,'paw NEAR pain')

SELECT Title
  FROM Fable 
  WHERE CONTAINS (*,'arena NEAR forest')

SELECT Title
  FROM Fable 
  WHERE CONTAINS (*,'Emperor NEAR forest')

SELECT Title
  FROM Fable 
  WHERE CONTAINS (*,'Androcles NEAR forest')

SELECT Title
  FROM Fable 
  WHERE CONTAINS (*,'story NEAR forest')

SELECT Title
  FROM Fable 
  WHERE CONTAINS (*,'victim NEAR forest')

SELECT Title
  FROM Fable 
  WHERE CONTAINS (*,'swollen NEAR bleeding')

SELECT Title
  FROM Fable 
  WHERE CONTAINS (*,'pardoned NEAR forest')

SELECT Title
  FROM Fable 
  WHERE CONTAINS (*,'lion NEAR paw NEAR bleeding')

SELECT Fable.Title, Rank 
  FROM Fable  
    JOIN CONTAINSTABLE (Fable, *,'life NEAR death') FTS
     ON Fable.FableID = FTS.[KEY]
  ORDER BY FTS.Rank DESC

SELECT Fable.Title, FTS.Rank
  FROM Fable  
    JOIN CONTAINSTABLE (Fable, fabletext, 'ISABOUT (Lion weight (.5), Brave weight (.5), Eagle weight (.5))',20) FTS
    ON Fable.FableID = FTS.[KEY]
    ORDER BY Rank DESC

SELECT Fable.Title, FTS.Rank
  FROM Fable  
    JOIN CONTAINSTABLE (Fable, fabletext, 'ISABOUT (Lion weight (.2), Brave weight (.2), Eagle weight (.8))',20) FTS
    ON Fable.FableID = FTS.[KEY]
    ORDER BY Rank DESC

SELECT Fable.Title, FTS.Rank
  FROM Fable  
    JOIN CONTAINSTABLE (Fable, *, 'ISABOUT (Lion weight (.2), Brave weight (.2), Eagle weight (.8))',20) FTS
    ON Fable.FableID = FTS.[KEY]
    ORDER BY Rank DESC

-- Word-Inflection Searches
SELECT Title
  FROM Fable 
  WHERE CONTAINS (*,'FORMSOF(INFLECTIONAL,die)')

SELECT Title
  FROM Fable 
  WHERE CONTAINS (*,'FORMSOF(INFLECTIONAL,pity)')

SELECT Title
  FROM Fable 
  WHERE CONTAINS (*,'FORMSOF(INFLECTIONAL,geese)')

SELECT Title
  FROM Fable 
  WHERE CONTAINS (*,'FORMSOF(INFLECTIONAL,carry)')

SELECT Title
  FROM Fable 
  WHERE CONTAINS (*,'FORMSOF(INFLECTIONAL,fly)')

-- Weighting 

SELECT Title
  FROM Fable 
  WHERE CONTAINS (*,'ISABOUT (Lion weight (.9), Brave weight (.1))')

SELECT Title
  FROM Fable 
  WHERE CONTAINS (*,'ISABOUT (Lion weight (.1), Brave weight (.9))')

----------------------------------------------------
-- Fuzzy Searches

-- FreeText

SELECT Title
  FROM Fable 
  WHERE FREETEXT (*,'The Tortoise beat the Hare in the big race')

SELECT Title
  FROM Fable 
  WHERE FREETEXT (*,'The eagle was shot by an arrow')

SELECT Title
  FROM Fable 
  WHERE FREETEXT (*,'The brave hunter kills the lion')

-- FreetextTable
SELECT Fable.Title, FTS.Rank
  FROM Fable  
    JOIN FREETEXTTABLE (Fable, *, 'The brave hunter kills the lion',20) FTS
      ON Fable.FableID = FTS.[KEY]
  ORDER BY Rank DESC

SELECT Fable.Title, FTS.Rank
  FROM Fable  
    JOIN FREETEXTTABLE (Fable, *, 'The eagle was shot by an arrow',20) FTS
      ON Fable.FableID = FTS.[KEY]
  ORDER BY Rank DESC

---------------------------------------------------
-- Indexing Images

EXEC sp_fulltext_column 'Fable','Blob','add',0x0409,'BlobType'

EXEC sp_fulltext_table 'Fable', 'start_incremental'

EXEC sp_fulltext_table 'Fable', 'start_full'

EXEC sp_help_fulltext_columns 'fable'

SELECT Title, BlobType
  FROM Fable 
  WHERE CONTAINS (*,'jumped')


---------------------------------------------------
-- Performance

sp_fulltext_service 'resource_usage'

ALTER FULLTEXT CATALOG catalog_name REORGANIZE

sp_configure 'max full-text crawl range', 100.

sp_configure 'ft crawl bandwidth (max)', 1000