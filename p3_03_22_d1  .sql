with CTE AS (
    SELECT *, ROW_NUMBER() OVER (ORDER BY Salary DESC) AS rn FROM Employees
)
SELECT * FROM CTE WHERE rn % 2 = 0