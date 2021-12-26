
-------------------------------------------------------------------CREATING MAIN TEMP DATE TABLE----------------------------------------------------------------------

SET DATEFIRST 1  --Setting the first day number of the week. Put 7 if it starts from Sunday
DECLARE @StartDate  date = '20180101';
DECLARE @CutoffDate date = DATEADD(DAY, -1, DATEADD(YEAR, 10, @StartDate));

WITH seq(n) AS 
(
  SELECT 0 UNION ALL SELECT n + 1 FROM seq
  WHERE n < DATEDIFF(DAY, @StartDate, @CutoffDate)
),
d(d) AS 
(
  SELECT DATEADD(DAY, n, @StartDate) FROM seq
),
src AS
(
  SELECT
    [Date]    = CONVERT(date, d),
    DayNumberOfMonth   = DATEPART(DAY, d),
    [DayName]      = DATENAME(WEEKDAY, d),
    WeekNumberOfYear    = DATEPART(ISO_WEEK,d),

    DayNumberOfWeek    = DATEPART(WEEKDAY, d),
    MonthNumber        = DATEPART(MONTH,  d),
    [MonthName]    = DATENAME(MONTH,  d),
    [Quarter]    = DATEPART(Quarter,  d),
    [Year]        = DATEPART(YEAR,  d),
    FirstDateOfMonth = DATEFROMPARTS(YEAR(d), MONTH(d), 1),
    LastDateOfYear   = DATEFROMPARTS(YEAR(d), 12, 31),
    DayNumberOfYear    = DATEPART(DAYOFYEAR, d)
  FROM d
),
dim AS
(
  SELECT
    [Date], 
    YearMonthDay  = CONVERT(char(8),  [Date], 112),
	YearMonth   = CONVERT(char(4), [Year] ) + CONVERT(char(2),CONVERT(char(8), [Date], 101)),
    [DayName],
	DayNumberOfWeek,
	DayNumberOfMonth,
	DayNumberOfYear,
    WeekNumberOfMonth  = CONVERT(tinyint, DENSE_RANK() OVER (PARTITION BY [Year] , MonthNumber ORDER BY WeekNumberOfYear)),
    WeekNumberOfYear,
    MonthNumber,
    [MonthName],
    IsWeekend   = CASE WHEN DayNumberOfWeek IN (CASE @@DATEFIRST WHEN 1 THEN 6 WHEN 7 THEN 1 END,7)  THEN 1 ELSE 0 END,
    FirstDateOfMonth,
    LastDateOfMonth   = MAX([Date]) OVER (PARTITION BY [Year] , MonthNumber),
    FirstDateOfNextMonth = DATEADD(MONTH, 1, FirstDateOfMonth),
    LastDateOfNextMonth  = DATEADD(DAY, -1, DATEADD(MONTH, 2, FirstDateOfMonth)),
    [Quarter],
    FirstDateOfQuarter   = MIN([Date]) OVER (PARTITION BY [Year] , [Quarter]),
    LastDateOfQuarter    = MAX([Date]) OVER (PARTITION BY [Year] , [Quarter]),
    [Year],
    --Year_2    = [Year] - CASE WHEN MonthNumber = 1 AND WeekNumberOfYear > 51 THEN 1 WHEN MonthNumber = 12 AND WeekNumberOfYear = 1  THEN -1 ELSE 0 END,      
    FirstDateOfYear  = DATEFROMPARTS([Year], 1,  1),
    LastDateOfYear,
	BeforeToday = CASE WHEN [Date] <= GETDATE() THEN 1 ELSE 0 END 

  FROM src
)
SELECT *
INTO #DAYTABLE
FROM dim
ORDER BY [Date]
OPTION (MAXRECURSION 0);

----------------------------------------------------------------------------------------------ADDING TIME FLAGS-----------------------------------------------------------------------------

declare @thisyear as char(4)
set @thisyear = (select [Year] from #DAYTABLE (nolock) where YearMonthDay = convert(char(8),getdate()-1,112))

declare @lastyear as char(4)
set @lastyear = (select [Year] from #DAYTABLE (nolock) where YearMonthDay = convert(char(8),getdate()-366,112))

declare @ThisMonth as char(4)
set @ThisMonth = (select MonthNumber  from #DAYTABLE (nolock) where YearMonthDay = convert(char(8),getdate()-1,112))

declare @LastMonthYear as char(4)
set @LastMonthYear = (select [Year] from #DAYTABLE (nolock) where YearMonthDay = convert(char(8),getdate()-30,112))

declare @LastWeek as char(8)
set @LastWeek = (select WeekNumberOfYear from #DAYTABLE (nolock) where YearMonthDay = convert(char(8),getdate()-7,112))

declare @ThisWeek as char(8)
set @ThisWeek = (select WeekNumberOfYear from #DAYTABLE (nolock) where YearMonthDay = convert(char(8),getdate(),112))

declare @LastDay as char(8)
set @LastDay = (select YearMonthDay from #DAYTABLE (nolock) where YearMonthDay = convert(char(8),getdate()-1,112) )

declare @Today as char(8)
set @Today = (select YearMonthDay from #DAYTABLE (nolock) where YearMonthDay = convert(char(8),getdate(),112) )

declare @LastDayYTD as char(8)
set @LastDayYTD = (select YearMonthDay from #DAYTABLE (nolock) where YearMonthDay = convert(char(8),getdate()-366,112) )

declare @YesterdayWeekDay as char(3)
set @YesterdayWeekDay =(select DayNumberOfWeek from #DAYTABLE (nolock) where YearMonthDay = convert(char(8),getdate()-1,112) )


SELECT dt.*,
CASE WHEN [Year]=@thisyear THEN 1 ELSE 0 END AS ThisYear,
CASE WHEN [Year]=@thisyear and BeforeToday=1 THEN 1 ELSE 0 END AS ThisYearYTD,
CASE WHEN [Year]=@lastyear THEN 1 ELSE 0 END AS LastYear,
CASE WHEN [Year]=@lastyear AND YearMonthDay<= CONVERT(char(8),DATEADD(YEAR,-1,GETDATE()),112) THEN 1 ELSE 0 END AS LastYearYTD,
CASE WHEN [Year]=@thisyear AND MonthNumber=@ThisMonth THEN 1 ELSE  0 END AS ThisMonth,
CASE WHEN [Year]=@thisyear AND MonthNumber=@ThisMonth AND BeforeToday=1 THEN 1 ELSE 0 END AS ThisMonthMTD,
CASE WHEN [Year]=@LastMonthYear AND MonthNumber= (CASE WHEN @ThisMonth=1 THEN 12 ELSE @ThisMonth-1 END) THEN 1 ELSE 0 END AS LastMonth,
CASE WHEN [Year]=@LastMonthYear AND MonthNumber= (CASE WHEN @ThisMonth=1 THEN 12 ELSE @ThisMonth-1 END) AND DayNumberOfMonth<=DATEPART(DAY,GETDATE()) THEN 1 ELSE 0 END AS LastMonthMTD,
CASE WHEN [Year]=@thisyear AND  WeekNumberOfYear = @ThisWeek THEN 1 else 0 END AS ThisWeek,
CASE WHEN [Year]=@thisyear AND WeekNumberOfYear = @ThisWeek AND BeforeToday=1 THEN 1 else 0 END AS ThisWeekWTD,
CASE WHEN [Year]=(CASE WHEN @ThisWeek = 1 THEN @lastyear ELSE @thisyear END) AND WeekNumberOfYear = @LastWeek THEN 1 else 0 END AS LastWeek,
CASE WHEN [Year]=(CASE WHEN @ThisWeek = 1 THEN @lastyear ELSE @thisyear END) AND WeekNumberOfYear = @LastWeek AND DayNumberOfWeek<=DATEPART(WEEKDAY,GETDATE())  THEN 1 else 0 END AS LastWeekWTD,
CASE WHEN YearMonthDay=@Today THEN 1 ELSE 0 END AS Today,
CASE WHEN YearMonthDay=@LastDay THEN 1 ELSE 0 END AS Yesterday,
CASE WHEN YearMonthDay=@LastDayYTD THEN 1 ELSE 0 END AS LastYearYesterday,
CASE WHEN YearMonthDay IN ( SELECT YearMonthDay FROM #DAYTABLE WHERE YearMonthDay BETWEEN CONVERT(CHAR(8),GETDATE()-7,112) AND CONVERT(CHAR(8),GETDATE()-1,112)) THEN 1 else 0 END AS Last7Days,
CASE WHEN YearMonthDay IN ( SELECT YearMonthDay FROM #DAYTABLE WHERE YearMonthDay BETWEEN CONVERT(CHAR(8),GETDATE()-30,112) AND CONVERT(CHAR(8),GETDATE()-1,112)) THEN 1 else 0 END AS Last30Days,
CASE WHEN YearMonthDay IN ( SELECT YearMonthDay FROM #DAYTABLE WHERE DayNumberOfWeek = @YesterdayWeekDay AND [Year]=@thisyear AND WeekNumberOfYear IN
													    ( SELECT DISTINCT TOP 8 WeekNumberOfYear FROM #DAYTABLE  WHERE YearMonthDay < CONVERT(CHAR(8),GETDATE(),112) and [Year]=@thisyear ORDER BY WeekNumberOfYear DESC ))  THEN 1 ELSE 0 END AS YesterdayForLast7Weeks
INTO #DATE
FROM  #DAYTABLE as dt
ORDER BY YearMonthDay 

-------------------------------------------------------------------- CREATING A DATE TABLE ----------------------------------------------------------------------------

SELECT *
INTO dbo.DimDate
FROM #DATE


IF EXISTS (SELECT * FROM #DAYTABLE) DROP TABLE #DAYTABLE
IF EXISTS (SELECT * FROM #DATE) DROP TABLE #DATE


SELECT * FROM DimDate ORDER BY 1 

