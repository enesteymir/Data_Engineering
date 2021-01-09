-- ================================
-- Enable Database for CDC Template
-- ================================
USE [AdventureWorks2014OLTP]
GO

EXEC sys.sp_cdc_enable_db
GO


EXEC sp_changedbowner 'sa'
    GO
