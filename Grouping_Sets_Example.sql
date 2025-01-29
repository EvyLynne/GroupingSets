WITH CTE AS (
SELECT [SalesOrderID]
	, CAST( [ShipDate] AS DATE) [ShipDate]
	, LAG(DATEADD(DAY, 8 - DATEPART(WEEKDAY, ShipDate), CAST(Shipdate AS DATE))) OVER (ORDER BY Shipdate) AS [WeekEnding]
	, DATEPART (WEEK, [ShipDate] ) [ShipWeekNumber]
 	, DATEPART (MONTH, [ShipDate]) [ShipMonthNumber]
	, CASE WHEN DATEPART (MONTH, [ShipDate]) = 12 THEN 'December'
		WHEN DATEPART (MONTH, [ShipDate]) = 11 THEN 'November'
		WHEN DATEPART (MONTH, [ShipDate]) = 10 THEN 'October'
		WHEN DATEPART (MONTH, [ShipDate]) = 9 THEN 'September'
		WHEN DATEPART (MONTH, [ShipDate]) = 8 THEN 'August'
		WHEN DATEPART (MONTH, [ShipDate]) = 7 THEN 'July'
		WHEN DATEPART (MONTH, [ShipDate]) = 6 THEN 'June'
		WHEN DATEPART (MONTH, [ShipDate]) = 5 THEN 'May'
		WHEN DATEPART (MONTH, [ShipDate]) = 4 THEN 'April'
		WHEN DATEPART (MONTH, [ShipDate]) = 3 THEN 'March'
		WHEN DATEPART (MONTH, [ShipDate]) = 2 THEN 'February'
		WHEN DATEPART (MONTH, [ShipDate]) = 1 THEN 'January'
		ELSE NULL
	 END [Month]
	, DATEPART (DAY, [ShipDate]) [ShipDay]
	, DATEPART (YEAR,[ShipDate]) [ShipYear]
 	,[Freight]
	,[TotalDue]
   FROM [AdventureWorks2022].[Sales].[SalesOrderHeader]
   )

   SELECT  [SalesOrderID]
   , [ShipDate]
   ,  [WeekEnding]
	, [ShipWeekNumber]
 	, [ShipMonthNumber]
	, [Month]
	, [ShipDay]
	, [ShipYear]
 	, [Freight]
	, [TotalDue]
	, SUM( [TotalDue])  TotalSales
	, CASE 
		WHEN [SalesOrderID] IS  NULL AND  [ShipDate] IS  NULL AND  [ShipWeekNumber] IS  NULL  AND  [ShipMonthNumber] IS  NULL AND  [Month] IS NULL AND   [ShipDay] IS  NULL AND  [ShipYear] IS NOT NULL AND [Freight] IS NULL AND [TotalDue] IS NULL THEN CONCAT( 'Annual Total For Year: ', [ShipYear])
		WHEN [SalesOrderID] IS  NULL AND  [ShipDate] IS  NULL AND  [ShipWeekNumber] IS  NULL  AND  [ShipMonthNumber] IS NOT NULL AND  [Month] IS NOT NULL AND [ShipDay] IS  NULL AND  [ShipYear] IS NOT NULL AND [Freight] IS NULL AND [TotalDue] IS NULL THEN CONCAT('Monthly Total For Month: ', [Month], ', ', [ShipYear])
		WHEN [SalesOrderID] IS  NULL AND  [ShipDate] IS  NULL AND  [ShipWeekNumber] IS NOT NULL  AND  [ShipMonthNumber] IS NOT NULL AND  [Month] IS NOT NULL AND [ShipDay] IS  NULL AND  [ShipYear] IS NOT NULL AND [Freight] IS NULL AND [TotalDue] IS NULL  THEN CONCAT('Weekly Total For Week ', [ShipWeekNumber], ' out of 52' )
		WHEN [SalesOrderID] IS  NULL AND  [ShipDate] IS NOT NULL AND  [ShipWeekNumber] IS NOT NULL  AND  [ShipMonthNumber] IS NOT NULL AND  [Month] IS NOT NULL AND [ShipDay] IS  NULL AND  [ShipYear] IS NOT NULL AND [Freight] IS NULL AND [TotalDue] IS NULL THEN CONCAT( 'Daily Total For Date: ', [ShipDate])
		WHEN [SalesOrderID] IS  NULL AND  [ShipDate] IS  NULL AND  [ShipWeekNumber] IS  NULL  AND  [ShipMonthNumber] IS  NULL AND  [Month] IS  NULL AND [ShipDay] IS  NULL AND  [ShipYear] IS  NULL AND [Freight] IS NULL AND [TotalDue] IS NULL   THEN 'Grand Total'
	ELSE '0' END AS AggregateTotalSales

   FROM CTE 
  
   GROUP BY GROUPING SETS (
	([SalesOrderID]
	,[ShipDate]
	,  [WeekEnding]
	, [ShipWeekNumber]
 	, [ShipMonthNumber]
	, [Month]
	, [ShipDay]
	, [ShipYear]
 	, [Freight]
	, [TotalDue] )
	, ( [ShipYear])  -- Annual Total
	, ([ShipMonthNumber], [Month] ,  [ShipYear] ) -- Month Total
	, ([ShipMonthNumber], [Month] , [ShipWeekNumber], [ShipYear]) -- Weekly Total
	, ([ShipMonthNumber], [Month] , [ShipWeekNumber], [ShipYear],[ShipDate]) -- Daily Total
	, () -- Grand Total

 )
 