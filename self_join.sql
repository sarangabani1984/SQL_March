WITH CTE AS (
    SELECT *, 
           -- Default to TotalSales if no previous record exists
           LAG(TotalSales, 1, TotalSales) OVER (PARTITION BY ProductID ORDER BY SalesMonth) AS PreviousMonthSales
    FROM Monthly_Sales
)
SELECT *,
       CASE 
           WHEN TotalSales > PreviousMonthSales THEN 'Growth'
           WHEN TotalSales < PreviousMonthSales THEN 'Decline'
           ELSE 'No Change' 
       END AS SalesTrend
FROM CTE;