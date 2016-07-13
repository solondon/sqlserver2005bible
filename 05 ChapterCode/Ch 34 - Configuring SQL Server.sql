
-----------------------------------------------------------
-- SQL Server 2005 Bible 
-- Wiley Publishing 
-- Paul Nielsen

-- Chapter 34 - Configuring SQL Server

---------------------------------------
-- Setting the Options

-- Configuring the Server
Select @@Version

EXEC sp_configure

EXEC xp_msver

-- Configuring the Database
EXEC sp_dboption 

-- Configuring the Connection
Set Ansi_nulls Off

Select SessionProperty ('ANSI_NULLS')


---------------------------------------
-- Configuration Options

-- Displaying the Advanced Options

EXEC sp_configure 'show advanced options', 1

EXEC sp_configure 'min server memory', 16

EXEC sp_configure 'max server memory', 128

RECONFIGURE


-- Startup Stored Procedures
EXEC sp_configure 'scan for startup procs', 1
RECONFIGURE


-- Memory-Configuration Properties
CREATE PROC pSetMaxMemory (
   @Safe INT = 64 )
AS 
  CREATE TABLE #PhysicalMemory (
    [Index] INT,
    [Name] VARCHAR(50),
    [Internal_Value] INT,
    [Character_Value] VARCHAR(50) )
  DECLARE @Memory INT
  INSERT #PhysicalMemory
     EXEC xp_msver 'PhysicalMemory'
  SELECT @Memory = 
     (Select Internal_Value FROM #PhysicalMemory) - @safe
  EXEC sp_configure 'max server memory', @Memory
  RECONFIGURE

go

EXEC pSetMaxMemory  -- sets max memory to physical - 64Mb
EXEC pSetMaxMemory 32 --  sets max memory to physical - 32Mb


EXEC sp_configure 'set working set size', 1
RECONFIGURE

EXEC sp_configure 'min memory per query', 2048
RECONFIGURE

EXEC sp_configure 'query wait', 20
RECONFIGURE

EXEC sp_configure 'AWE Enabled', 20
RECONFIGURE

EXEC sp_configure ' index create memory', 8096
RECONFIGURE

EXEC sp_configure 'locks', 16,767
RECONFIGURE

EXEC sp_configure 'open objects', 16767
RECONFIGURE


-- Processor Properties
EXEC sp_configure 'affinity mask', 3
RECONFIGURE

EXEC sp_configure 'max worker threads', 64
RECONFIGURE

EXEC sp_configure 'priority boost', 1
RECONFIGURE

EXEC sp_configure 'lightweight pooling', 1
RECONFIGURE

EXEC sp_configure 'max degree of parallelism', 1
EXEC sp_configure 'cost threshold for parallelism', 1
RECONFIGURE


---------------------------------------
-- Security Properties

EXEC sp_configure 'C2 audit mode', 1
RECONFIGURE

---------------------------------------
-- Connection Properties

EXEC sp_configure 'user connections', 0
RECONFIGURE

SELECT @@MAX_CONNECTIONS

EXEC sp_configure 'remote access', 0
RECONFIGURE

EXEC sp_configure 'remote query timeout', 600
RECONFIGURE

EXEC sp_configure 'remote proc trans', 1
RECONFIGURE

exec sp_configure 'network packet size', 2048
RECONFIGURE

EXEC sp_configure 'remote login timeout', 2048
RECONFIGURE

EXEC sp_configure 'max text repl size', 16767
RECONFIGURE



---------------------------------------
-- Server Configuration Properties

EXEC sp_configure 'default language', 'English'
RECONFIGURE

EXEC sp_configure 'default full-text language', 'English'
RECONFIGURE

EXEC sp_configure 'query governor cost limit', 10
RECONFIGURE

SET QUERY_GOVERNOR_COST_LIMIT  0 

EXEC sp_configure 'two digit year cutoff', 2041
RECONFIGURE



-------------------------------
-- Database Auto Settings

ALTER DATABASE OBXKites SET AUTO_CLOSE ON

ALTER DATABASE OBXKites SET AUTO_SHRINK ON 

ALTER DATABASE OBXKites SET AUTO_CREATE_STATISTICS ON 

ALTER DATABASE OBXKites SET AUTO_UPDATE_STATISTICS ON 

-------------------------------
-- Cursor Settings

EXEC sp_configure 'cursor threshold', 0
RECONFIGURE WITH OVERRIDE

SET CURSOR_CLOSE_ON_COMMIT ON 

ALTER DATABASE OBXKites SET CURSOR_DEFAULT LOCAL

-------------------------------
-- ANSI Settings


ALTER DATABASE OBXKites SET ANSI_NULL_DEFAULT ON 

ALTER DATABASE OBXKites SET ANSI_NULLS ON

ALTER DATABASE OBXKites SET ANSI_PADDING ON 

ALTER DATABASE OBXKites SET ANSI_WARNINGS ON 

ALTER DATABASE OBXKites SET ARITHABORT ON 

ALTER DATABASE OBXKites SET NUMERIC_ROUNDABORT ON 

ALTER DATABASE OBXKites SET CONCAT_NULL_YIELDS_NULL ON 

ALTER DATABASE OBXKites SET QUOTED_IDENTIFIER ON 

-------------------------------
-- Trigger Configuration Settings

EXEC sp_configure 'nested triggers', 1
RECONFIGURE

ALTER DATABASE database SET RECURSIVE_TRIGGERS ON | OFF

-------------------------------
-- Database Configuration Settings

ALTER DATABASE database SET OFFLINE

ALTER DATABASE database SET READ_ONLY

ALTER DATABASE database SET SINGLE_USER

EXEC sp_dbcmptlevel database, 80