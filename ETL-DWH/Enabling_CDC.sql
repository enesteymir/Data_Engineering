--More Detail, go to : https://solutioncenter.apexsql.com/enable-use-sql-server-change-data-capture/

--At First, Ensure that SQLSERVER AGENT SERVICE is running !!

--Control If CDC is active for DBs. 1 is Enabled 0 is Disabled
SELECT name,is_CDC_enabled 
from MASTER.SYS.Databases


--If it is not enabled for related DB, Then Enable the CDC on DB
USE [AdventureWorks2014OLTP]
EXEC sys.sp_cdc_enable_db
GO


--If you get an error, The login used must have SQL Server sysadmin privileges and must be a db_owner of the database. To fix error, you can use this;
EXEC sp_changedbowner 'sa'
    GO
EXEC sys.sp_cdc_enable_db
    GO


--Control if CDC is enabled for related Table. 
USE [AdventureWorks2014OLTP]
SELECT Name,is_tracked_by_cdc
FROM sys.tables
Where Name = 'SalesOrderDetail'


--If it is 0, then execute below script.You have to enable the feature for each table you want to track
--There are four parameters available: @captured_column_list, @filegroup_name, @role_name, and @supports_net_changes
--By default, all columns in the table are tracked. If you want to track only the specific ones, use the @captured_column_list parameter.
EXEC sys.sp_cdc_enable_table
@source_schema = Sales,
@source_name = 'SalesOrderDetail',
@role_name = NULL,
@supports_net_changes = 1,
@capture_instance = 'SalesOrderDetail'
--@captured_column_list = N'SalesOrderID, SalesOrderDetailID,ProductID'

