-----------------------------------------------------------
-- SQL Server 2000 Bible 
-- Wiley Publishing 
-- Paul Nielsen

-- Chapter 37 - Database Maintenance

-----------------------------------------------------------
-----------------------------------------------------------


--------------------------------------
-- DBCC Commands
DBCC Help ('CheckDB')

--------------------------------------
-- Database Integrity
Use OBXKites

DBCC CheckDB ('OBXKites')
DBCC CheckDB ('OBXKites') with all_errormsgs
DBCC CheckDB ('OBXKites') with no_infomsgs
DBCC CheckDB ('OBXKites') with estimateonly 
DBCC CheckDB ('OBXKites', 'NoIndex')
DBCC CheckDB ('OBXKites') with Physical_Only 

-- Repairing the Database
EXEC sp_dboption OBXKites, 'Single_user', 'True'
DBCC CheckDB ('OBXKites', Repair_Rebuild)
go
EXEC sp_dboption OBXKites, 'Single_user', 'False'
go


-- Multi-User Concerns
DBCC CheckDB ('OBXKites')With TabLock

-- Object-Level Validation
DBCC CheckAlloc ('OBXKites')

USE OBXKites 
DBCC CheckTable ('Product')

DBCC CheckFileGroup ('Primary')

DBCC CleanTable ('OBXKites', 'Product')

-- Data Integrity
DBCC CheckCatalog ('OBXKites')

DBCC CheckConstraints ('Product')

Use CHA2
DBCC CheckIdent ('Customer')

-- Index Maintenance

-- Database Fragmentation
USE Tempdb
Drop Table Frag
go
CREATE TABLE Frag (
  FragID UNIQUEIDENTIFIER DEFAULT NewID() 
    CONSTRAINT Frag_PK PRIMARY KEY CLUSTERED WITH FILLFACTOR = 90,
  Col1 INT,
  Col2 CHAR(200),
  Created DATETIME DEFAULT GetDate(),
  Modified DATETIME DEFAULT GetDate(),
  )

CREATE NONCLUSTERED INDEX ix_col 
  ON Frag (Col1)
  WITH FILLFACTOR = 95, PAD_INDEX
go

CREATE PROC Add100K
as
set nocount on
DECLARE @X INT
SET @X = 0
  WHILE @X < 100000
    BEGIN
      INSERT Frag (Col1,Col2)
        VALUES (@X, 'sample data')
      SET @X = @X + 1
    END
go

EXEC Add100K
EXEC Add100K
EXEC Add100K
EXEC Add100K
EXEC Add100K
DBCC ShowContig (frag) WITH ALL_INDEXES
	 
DBCC IndexDefrag ('Tempdb', 'Frag', 'Frag_PK')
DBCC IndexDefrag ('Tempdb', 'Frag', 'ix_col')
DBCC ShowContig (frag) WITH ALL_INDEXES


-- Index Statistics
use cha2
exec sp_help customer
Update Statistics Customer
DBCC SHOW_STATISTICS (customer, IxCustomerLocation)

-- Index Density 
SET STATISTICS TIME ON
DBCC DBReIndex ('Tempdb.dbo.Frag','',98)
DBCC ShowContig (Frag) WITH ALL_INDEXES
SELECT * FROM FRAG WHERE Col1 Between 1000 AND 2000

DBCC DBReIndex ('Tempdb.dbo.Frag','',10)
DBCC ShowContig (Frag) WITH ALL_INDEXES
SELECT * FROM FRAG WHERE Col1 Between 5000 AND 6000

DBCC DBReIndex ('Tempdb.dbo.Frag','',60)
DBCC ShowContig (Frag) WITH ALL_INDEXES
SELECT * FROM FRAG WHERE Col1 Between 8000 AND 9000
SET STATISTICS TIME OFF

select count(*) from frag
DBCC DBReIndex ('Tempdb.dbo.Frag','',87)
DBCC ShowContig (Frag) WITH ALL_INDEXES
EXEC Add10K

DBCC DBReIndex ('Tempdb.dbo.Frag','',98)
DBCC ShowContig (Frag) WITH ALL_INDEXES


-- Database File Sizes


-- Monitoring Database File Sizes
Select name, size, maxsize from sysfiles;

--DBA Checklist file size query

DBCC Updateusage ('OBXKites')
EXEC sp_spaceused

DBCC SQLPerf(LogSpace)



-- Monitoring File Growth


-- Monitoring Available Disk Space
xp_fixeddrives -- find correct procedure in the DBA CheckList

-- Shrinking the Database
DBCC ShrinkDatabase ('OBXKites', 10) 
DBCC ShrinkFile

-- Shrinking the Transaction Log
BEGIN TRAN
  UPDATE Product
    SET ProductDescription = 'OpenTran'
    WHERE Code = '1002'

  DBCC OpenTran ('OBXKites')

ROLLBACK TRAN

------------------------------
-- Miscellaneous DBCC Commands 

DBCC DropCleanBuffers 

DBCC Inputbuffer(@@SPID)

DBCC Outputbuffer(@@SPID)  

DECLARE @dbid INT, @ObjectID INT
SET @dbid = DB_ID('OBXKites')
SET @ObjectID = Object_ID('OBXKites..Product')
DBCC PinTable(@dbid,@ObjectID )

DBCC UnpinTable(@dbid,@ObjectID )

DBCC ProcCache 

DBCC ConcurrencyViolation 