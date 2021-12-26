USE KinetEcoDW;
GO

CREATE VIEW dbo.OrdersByDate
    WITH SCHEMABINDING
    AS
        SELECT Orders.OrderID, Orders.CustomerKey, Orders.OrderTotal,
            Date.FullDate, Date.DayName, Date.DayNumber,
            Date.MonthName, Date.MonthNumber, Date.QuarterNumber, Date.Year
        FROM Fact.Orders JOIN Dimension.Date ON Orders.DateKey = Date.DateKey
;
GO

CREATE UNIQUE CLUSTERED INDEX IDX_OrdersByDate
   ON dbo.OrdersByDate (OrderID);
GO

SELECT * FROM dbo.OrdersByDate;
GO


/* We create index on view to prevent the database engine from having to perform 
a table join when accessing data from fact and dimension tables