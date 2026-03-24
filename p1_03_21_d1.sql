use sarang;

EXEC sp_help 'Employees';

SELECT * from Employees;

-- SELECT 
-- FirstName,
-- LastName,
-- Email,
-- Department, 
-- COUNT(*) AS DuplicateCount 
-- FROM Employees GROUP BY FirstName, LastName, Email, Department HAVING COUNT(*) > 1;


with dupilcate as (
    SELECT 
        *,
        COUNT(*) OVER (PARTITION BY FirstName, LastName, Email, Department) AS DuplicateCount
    FROM Employees
)
SELECT *
FROM dupilcate
WHERE DuplicateCount > 1



    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY FirstName, LastName, Email ORDER BY EmployeeID) AS RowNum
    FROM Employees