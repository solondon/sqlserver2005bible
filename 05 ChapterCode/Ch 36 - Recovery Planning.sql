-----------------------------------------------------------
-- SQL Server 2005 Bible 
-- Wiley Publishing 
-- Paul Nielsen

-- Chapter 36 - Recovery Planning

-----------------------------------------------------------
-----------------------------------------------------------
USE CHA2;

ALTER DATABASE CHA2 SET Recovery Full;

SELECT [name], recovery_model_desc 
  FROM sys.databases;

-- legecy method
SELECT DatabasePropertyEx('CHA2', 'Recovery');


-- Basic Backup Command

BACKUP DATABASE CHA2
  TO DISK = 'e:\Cha2_Backup.bak'
  WITH 
    NAME = 'CHA2_Backup',
    STATS = 5, init

-- Differential Backup
BACKUP DATABASE CHA2
  TO DISK = 'e:\Cha2_Backup.bak'
  WITH 
    DIFFERENTIAL,
    NAME = 'CHA2_Backup'   ,
    MEDIANAME = 'e:\Cha2Backup4.bak',
    MEDIADESCRIPTION = 'Daily Backup File',
    MEDIAPASSWORD = 'MyPassword',
    INIT



-- Verify Backup
RESTORE VERIFYONLY  
  FROM DISK =  'e:\Cha2Backup.bak'


CHECKPOINT

BACKUP LOG CHA2
  TO DISK = 'e:\Cha2_Backup.bak'
  WITH 
    NAME = 'CHA2_Backup'


BACKUP LOG CHA2
  WITH TRUNCATE_ONLY



---- A Test BackUp a restore

CREATE DATABASE Plan2Recover
go
USE Plan2Recover

CREATE TABLE T1 (
  PK INT Identity PRIMARY KEY,
  Name VARCHAR(15)
  )
Go
INSERT T1 VALUES ('Full')
Go
BACKUP DATABASE Plan2Recover
  TO DISK = 'e:\P2R.bak'
  WITH 
    NAME = 'P2R_Full',
    INIT
Go 
INSERT T1 VALUES ('Log 1')
go
BACKUP Log Plan2Recover
  TO DISK = 'e:\P2R.bak'
  WITH 
    NAME = 'P2R_Log'
go
INSERT T1 VALUES ('Log 2')
go
BACKUP Log Plan2Recover
  TO DISK = 'e:\P2R.bak'
  WITH 
    NAME = 'P2R_Log'
go
SELECT * FROM T1

-- NOW PERFORM THE RESTORE
Use Master
RESTORE DATABASE Plan2Recover
  FROM DISK = 'e:\P2R.bak'
  With FILE = 1, NORECOVERY
go
RESTORE LOG Plan2Recover
  FROM DISK = 'e:\P2R.bak'
  With FILE = 2, NORECOVERY
go
RESTORE LOG Plan2Recover
  FROM DISK = 'e:\P2R.bak'
  With FILE = 3, RECOVERY
go

USE Plan2Recover
Select * from T1
go
USE Master
go
DROP DATABASE Plan2Recover

---------------------------------------------------
-- 

RESTORE DATABASE master 
  FROM 
  DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL$SQL2\BACKUP\systembackup'
  WITH FILE = 1






