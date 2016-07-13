-----------------------------------------------------------
-- SQL Server 2005 Bible 
-- Wiley Publishing  
-- Paul Nielsen

-- Chapter 49 - Tuning Queries with Indexes

-----------------------------------------------------------
-----------------------------------------------------------


------------------------------------------
-- Using Performance Monitor
DECLARE @Counter Int
SET @Counter = 0
While @Counter < 100
  BEGIN
    SET @Counter = @Counter + 1
    EXEC sp_user_counter1 @Counter
    WAITFOR Delay '00:00:02'
  END


------------------------------------------
-- Using SQL Trace

/****************************************************/
/* Created by: SQL Server Profiler 2005             */
/* Date: 03/10/2006  03:57:31 PM         */
/****************************************************/


-- Create a Queue
declare @rc int
declare @TraceID int
declare @maxfilesize bigint
set @maxfilesize = 128

-- Please replace the text InsertFileNameHere, with an appropriate
-- filename prefixed by a path, e.g., c:\MyFolder\MyTrace. The .trc extension
-- will be appended to the filename automatically. If you are writing from
-- remote server to local drive, please use UNC path and make sure server has
-- write access to your network share

exec @rc = sp_trace_create @TraceID output, 0, N'C:\Trace123', @maxfilesize, NULL 
if (@rc != 0) goto error

-- Client side File and Table cannot be scripted

-- Set the events
declare @on bit
set @on = 1
exec sp_trace_setevent @TraceID, 12, 15, @on
exec sp_trace_setevent @TraceID, 12, 16, @on
exec sp_trace_setevent @TraceID, 12, 1, @on
exec sp_trace_setevent @TraceID, 12, 9, @on
exec sp_trace_setevent @TraceID, 12, 17, @on
exec sp_trace_setevent @TraceID, 12, 6, @on
exec sp_trace_setevent @TraceID, 12, 10, @on
exec sp_trace_setevent @TraceID, 12, 14, @on
exec sp_trace_setevent @TraceID, 12, 18, @on
exec sp_trace_setevent @TraceID, 12, 11, @on
exec sp_trace_setevent @TraceID, 12, 12, @on
exec sp_trace_setevent @TraceID, 12, 13, @on


-- Set the Filters
declare @intfilter int
declare @bigintfilter bigint

exec sp_trace_setfilter @TraceID, 10, 0, 7, N'SQL Server Profiler - a53a3303-6862-48f3-9df8-3d649121ba55'
-- Set the trace status to start
exec sp_trace_setstatus @TraceID, 1

-- display trace id for future references
select TraceID=@TraceID
goto finish

error: 
select ErrorCode=@rc

finish: 
go

SELECT * FROM  sys.traces

EXEC sp_trace_setstatus 2, 0

-----------------------------------------------
-- Using Transact-SQL

-- Using Statistics 
USE OBXKites
Set statistics io on 
SELECT LastName + ' ' + FirstName as Customer, Product.[Name], Product.code
  FROM dbo.Contact
    JOIN dbo.[Order] 
      ON Contact.ContactID = [Order].ContactID
    JOIN dbo.OrderDetail
      ON [Order].OrderID = OrderDetail.OrderID
    JOIN dbo.Product
      ON OrderDetail.ProductID = Product.ProductID
  WHERE Product.Code = '1002'
  ORDER BY LastName, FirstName
Set statistics io off 
 
 Set statistics time on 
SELECT LastName + ' ' + FirstName as Customer
  FROM dbo.Contact
  ORDER BY LastName, FirstName
Set statistics time off 
 
go
Set showplan_all on 
go
SELECT LastName
  FROM dbo.Contact
go
Set showplan_all off
go
 
Set showplan_xml on 
go
SELECT LastName
  FROM dbo.Contact
go
Set showplan_xml off
go








