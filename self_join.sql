with cte as (
select *, 
LAG(TotalSales) OVER (PARTITION BY ProductID ORDER BY SalesMonth) AS PreviousMonthSales
 
from Monthly_Sales)
select ProductID, SalesMonth, TotalSales, PreviousMonthSales,
case when TotalSales > PreviousMonthSales then 'Growth'
     when TotalSales < PreviousMonthSales then 'Decline'
     else 'No Change' end as SalesTrend
from cte;

-- 