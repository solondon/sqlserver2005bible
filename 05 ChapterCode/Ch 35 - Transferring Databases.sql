-----------------------------------------------------------
-- SQL Server 2005 Bible 
-- Wiley Publishing 
-- Paul Nielsen

-- Chapter 35 - Transfering Databases

-----------------------------------------------------------
-----------------------------------------------------------

sp_detach_db 'OBXKites' 

EXEC sp_attach_db @dbname = 'OBXKites', 
   @filename1 = 'e:\SQLServerBible\OBXKites.mdf', 
   @filename2 = 'e:\SQLServerBible\OBXKitesStatic.ndf',
   @filename3 = 'e:\SQLServerBible\OBXKites.ldf'

