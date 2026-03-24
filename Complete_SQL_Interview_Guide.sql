-- ============================================================================
-- SQL SERVER INTERVIEW PREPARATION - COMPLETE GUIDE WITH 19 QUESTIONS
-- ============================================================================

-- ============================================================================
-- PART 1: SAMPLE TABLE CREATION
-- ============================================================================

-- Create Employees Table
DROP TABLE IF EXISTS Employees;
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    EmployeeName VARCHAR(100),
    Salary DECIMAL(10, 2),
    DepartmentID INT,
    HireDate DATE,
    ManagerID INT
);

-- Create Departments Table
DROP TABLE IF EXISTS Departments;
CREATE TABLE Departments (
    DepartmentID INT PRIMARY KEY,
    DepartmentName VARCHAR(100),
    Location VARCHAR(100)
);

-- Create Sample Data for Employees
INSERT INTO Employees VALUES
(1, 'John Smith', 50000, 1, '2020-01-15', NULL),
(2, 'Sarah Johnson', 60000, 1, '2019-03-20', 1),
(3, 'Mike Davis', 55000, 2, '2021-06-10', 1),
(4, 'Emily Brown', 65000, 2, '2018-11-05', 3),
(5, 'David Wilson', 60000, 3, '2020-08-12', NULL),
(6, 'Lisa Anderson', 70000, 3, '2019-02-14', 5),
(7, 'James Taylor', 55000, 1, '2021-09-01', 1),
(8, 'Jennifer Martinez', 75000, 2, '2017-04-22', 3),
(9, 'Robert Thomas', 60000, 1, '2020-05-30', 1),
(10, 'Patricia Garcia', 80000, 3, '2016-12-10', 5),
(11, 'Michael Rodriguez', 58000, 2, '2019-07-18', 3),
(12, 'Linda Lee', 62000, 1, '2020-10-25', 1);

-- Create Sample Data for Departments
INSERT INTO Departments VALUES
(1, 'Sales', 'New York'),
(2, 'Marketing', 'Los Angeles'),
(3, 'IT', 'Chicago');

-- Create Orders Table (for additional queries)
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    EmployeeID INT,
    OrderAmount DECIMAL(10, 2),
    OrderDate DATE,
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

-- Insert Sample Orders Data
INSERT INTO Orders VALUES
(101, 1, 5000, '2024-01-10'),
(102, 2, 7500, '2024-01-12'),
(103, 1, 6000, '2024-01-15'),
(104, 3, 4500, '2024-01-18'),
(105, 2, 8000, '2024-02-01'),
(106, 4, 9500, '2024-02-05'),
(107, 1, 5500, '2024-02-10'),
(108, 5, 6500, '2024-02-15');

-- ============================================================================
-- QUESTION 1: 2ND HIGHEST SALARY
-- ============================================================================

-- APPROACH 1: Using OFFSET and FETCH (Most Modern & Recommended)
SELECT TOP 1 Salary
FROM Employees
WHERE Salary < (SELECT MAX(Salary) FROM Employees)
ORDER BY Salary DESC;

-- APPROACH 2: Using CTE with ROW_NUMBER()
WITH RankedSalaries AS (
    SELECT Salary, 
           ROW_NUMBER() OVER (ORDER BY Salary DESC) AS SalaryRank
    FROM (SELECT DISTINCT Salary FROM Employees) AS UniqueSalaries
)
SELECT Salary
FROM RankedSalaries
WHERE SalaryRank = 2;

-- ============================================================================
-- QUESTION 2: DEPARTMENT WISE HIGHEST SALARY
-- ============================================================================

-- APPROACH 1: Using GROUP BY with MAX()
SELECT 
    d.DepartmentID,
    d.DepartmentName,
    MAX(e.Salary) AS HighestSalary
FROM Employees e
JOIN Departments d ON e.DepartmentID = d.DepartmentID
GROUP BY d.DepartmentID, d.DepartmentName
ORDER BY d.DepartmentID;

-- APPROACH 2: Using CTE with ROW_NUMBER()
WITH RankedDeptSalaries AS (
    SELECT 
        DepartmentID,
        EmployeeName,
        Salary,
        ROW_NUMBER() OVER (PARTITION BY DepartmentID ORDER BY Salary DESC) AS SalaryRank
    FROM Employees
)
SELECT DISTINCT
    d.DepartmentID,
    d.DepartmentName,
    rds.Salary AS HighestSalary
FROM RankedDeptSalaries rds
JOIN Departments d ON rds.DepartmentID = d.DepartmentID
WHERE rds.SalaryRank = 1;

-- ============================================================================
-- QUESTION 3: DISPLAY ALTERNATE RECORDS
-- ============================================================================

-- APPROACH 1: Using ROW_NUMBER() with Even Numbers
SELECT *
FROM Employees
WHERE EmployeeID IN (
    SELECT EmployeeID
    FROM (
        SELECT EmployeeID, ROW_NUMBER() OVER (ORDER BY EmployeeID) AS RowNum
        FROM Employees
    ) AS NumberedRows
    WHERE RowNum % 2 = 1
);

-- APPROACH 2: Using OFFSET and FETCH with LOOP simulation
SELECT *
FROM (
    SELECT *, ROW_NUMBER() OVER (ORDER BY EmployeeID) AS RowNum
    FROM Employees
) AS AlternateRows
WHERE RowNum % 2 = 1;

-- ============================================================================
-- QUESTION 4: DISPLAY DUPLICATE OF A COLUMN
-- ============================================================================

-- APPROACH 1: Using GROUP BY and HAVING
SELECT Salary, COUNT(*) AS DuplicateCount
FROM Employees
GROUP BY Salary
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC;

-- APPROACH 2: Using CTE with ROW_NUMBER()
WITH DuplicateSalaries AS (
    SELECT 
        Salary,
        ROW_NUMBER() OVER (PARTITION BY Salary ORDER BY EmployeeID) AS DupRank
    FROM Employees
)
SELECT DISTINCT
    e.EmployeeID,
    e.EmployeeName,
    e.Salary,
    (SELECT COUNT(*) FROM Employees WHERE Salary = e.Salary) AS TotalWithSalary
FROM Employees e
WHERE (SELECT COUNT(*) FROM Employees WHERE Salary = e.Salary) > 1
ORDER BY e.Salary DESC;

-- ============================================================================
-- QUESTION 5: PATTERN MATCHING IN SQL
-- ============================================================================

-- APPROACH 1: Using LIKE with Wildcards
SELECT *
FROM Employees
WHERE EmployeeName LIKE 'J%' -- Names starting with J
ORDER BY EmployeeName;

-- APPROACH 2: Using PATINDEX() Function
SELECT *
FROM Employees
WHERE PATINDEX('%smith%', LOWER(EmployeeName)) > 0
ORDER BY EmployeeName;

-- ============================================================================
-- QUESTION 6: PATTERN SEARCHING IN SQL - 2
-- ============================================================================

-- APPROACH 1: Using LIKE for multiple patterns with OR
SELECT *
FROM Employees
WHERE EmployeeName LIKE '%son' -- Ending with 'son'
   OR EmployeeName LIKE '%son%' -- Contains 'son'
ORDER BY EmployeeName;

-- APPROACH 2: Using CHARINDEX() Function
SELECT *
FROM Employees
WHERE CHARINDEX('son', EmployeeName) > 0
   OR CHARINDEX('ed', EmployeeName) > 0
ORDER BY EmployeeName;

-- ============================================================================
-- QUESTION 7: DISPLAY NTH ROW IN SQL
-- ============================================================================

-- APPROACH 1: Using OFFSET and FETCH (Most Recommended)
DECLARE @N INT = 5; -- Get 5th row
SELECT *
FROM Employees
ORDER BY EmployeeID
OFFSET @N - 1 ROWS
FETCH NEXT 1 ROWS ONLY;

-- APPROACH 2: Using ROW_NUMBER()
DECLARE @N INT = 5;
SELECT *
FROM (
    SELECT *, ROW_NUMBER() OVER (ORDER BY EmployeeID) AS RowNum
    FROM Employees
) AS NumberedRows
WHERE RowNum = @N;

-- ============================================================================
-- QUESTION 8: UNION VS UNION ALL
-- ============================================================================

-- APPROACH 1: UNION (Removes Duplicates) - Recommended for unique records
SELECT EmployeeName, Salary
FROM Employees
WHERE DepartmentID = 1
UNION
SELECT EmployeeName, Salary
FROM Employees
WHERE Salary > 65000
ORDER BY EmployeeName;

-- APPROACH 2: UNION ALL (Keeps Duplicates) - Faster, use when duplicates OK
SELECT EmployeeName, Salary
FROM Employees
WHERE DepartmentID = 1
UNION ALL
SELECT EmployeeName, Salary
FROM Employees
WHERE Salary > 65000
ORDER BY EmployeeName;

-- ============================================================================
-- QUESTION 9: INNER JOIN
-- ============================================================================

-- APPROACH 1: Using INNER JOIN Explicitly
SELECT 
    e.EmployeeID,
    e.EmployeeName,
    e.Salary,
    d.DepartmentName
FROM Employees e
INNER JOIN Departments d ON e.DepartmentID = d.DepartmentID
ORDER BY e.EmployeeID;

-- APPROACH 2: Using WHERE clause (Implicit Join)
SELECT 
    e.EmployeeID,
    e.EmployeeName,
    e.Salary,
    d.DepartmentName
FROM Employees e, Departments d
WHERE e.DepartmentID = d.DepartmentID
ORDER BY e.EmployeeID;

-- ============================================================================
-- QUESTION 10: SELF JOIN
-- ============================================================================

-- APPROACH 1: Join employees to their managers
SELECT 
    e.EmployeeID,
    e.EmployeeName AS Employee,
    m.EmployeeName AS Manager,
    e.Salary
FROM Employees e
LEFT JOIN Employees m ON e.ManagerID = m.EmployeeID
ORDER BY e.EmployeeID;

-- APPROACH 2: Self join using WHERE clause
SELECT 
    e.EmployeeID,
    e.EmployeeName AS Employee,
    m.EmployeeName AS Manager
FROM Employees e, Employees m
WHERE e.ManagerID = m.EmployeeID
ORDER BY e.EmployeeID;

-- ============================================================================
-- QUESTION 11: LEFT JOIN
-- ============================================================================

-- APPROACH 1: LEFT JOIN to include all employees even without departments
SELECT 
    e.EmployeeID,
    e.EmployeeName,
    d.DepartmentName,
    e.Salary
FROM Employees e
LEFT JOIN Departments d ON e.DepartmentID = d.DepartmentID
ORDER BY e.EmployeeID;

-- APPROACH 2: LEFT JOIN with aggregation
SELECT 
    d.DepartmentName,
    COUNT(e.EmployeeID) AS EmployeeCount,
    AVG(e.Salary) AS AvgSalary
FROM Departments d
LEFT JOIN Employees e ON d.DepartmentID = e.DepartmentID
GROUP BY d.DepartmentName;

-- ============================================================================
-- QUESTION 12: RIGHT JOIN
-- ============================================================================

-- APPROACH 1: RIGHT JOIN (All departments shown, even if no employees)
SELECT 
    e.EmployeeID,
    e.EmployeeName,
    d.DepartmentName
FROM Employees e
RIGHT JOIN Departments d ON e.DepartmentID = d.DepartmentID
ORDER BY d.DepartmentID;

-- APPROACH 2: RIGHT JOIN with WHERE for specific condition
SELECT 
    d.DepartmentID,
    d.DepartmentName,
    COUNT(e.EmployeeID) AS TotalEmployees
FROM Employees e
RIGHT JOIN Departments d ON e.DepartmentID = d.DepartmentID
GROUP BY d.DepartmentID, d.DepartmentName;

-- ============================================================================
-- QUESTION 13: FULL JOIN
-- ============================================================================

-- APPROACH 1: FULL OUTER JOIN (All records from both tables)
SELECT 
    e.EmployeeID,
    e.EmployeeName,
    d.DepartmentName
FROM Employees e
FULL OUTER JOIN Departments d ON e.DepartmentID = d.DepartmentID
ORDER BY e.EmployeeID;

-- APPROACH 2: FULL OUTER JOIN using UNION (for older SQL versions)
SELECT 
    e.EmployeeID,
    e.EmployeeName,
    d.DepartmentName
FROM Employees e
LEFT JOIN Departments d ON e.DepartmentID = d.DepartmentID
UNION
SELECT 
    e.EmployeeID,
    e.EmployeeName,
    d.DepartmentName
FROM Employees e
RIGHT JOIN Departments d ON e.DepartmentID = d.DepartmentID;

-- ============================================================================
-- QUESTION 14: CROSS JOIN
-- ============================================================================

-- APPROACH 1: CROSS JOIN (Cartesian Product)
SELECT 
    e.EmployeeName,
    d.DepartmentName
FROM Employees e
CROSS JOIN Departments d
ORDER BY e.EmployeeName, d.DepartmentName;

-- APPROACH 2: CROSS JOIN with Explicit Syntax
SELECT 
    TOP 20
    e.EmployeeName,
    d.DepartmentName,
    e.Salary
FROM Employees e, Departments d
ORDER BY e.EmployeeName;

-- ============================================================================
-- QUESTION 15: DISPLAY 1ST OR LAST NTH ROWS
-- ============================================================================

-- APPROACH 1: First 5 rows using OFFSET FETCH
SELECT TOP 5 *
FROM Employees
ORDER BY EmployeeID;

-- APPROACH 2: Last 5 rows using ORDER BY DESC and TOP
SELECT TOP 5 *
FROM Employees
ORDER BY EmployeeID DESC;

-- Alternative for Last N rows using OFFSET
SELECT *
FROM Employees
ORDER BY EmployeeID
OFFSET (SELECT COUNT(*) - 5 FROM Employees) ROWS
FETCH NEXT 5 ROWS ONLY;

-- ============================================================================
-- QUESTION 16: NTH HIGHEST SALARY
-- ============================================================================

-- APPROACH 1: Using CTE with DENSE_RANK()
DECLARE @N INT = 3; -- Get 3rd highest salary
WITH RankedSalaries AS (
    SELECT DISTINCT 
        Salary,
        DENSE_RANK() OVER (ORDER BY Salary DESC) AS SalaryRank
    FROM Employees
)
SELECT Salary
FROM RankedSalaries
WHERE SalaryRank = @N;

-- APPROACH 2: Using Subquery with ROW_NUMBER()
DECLARE @N INT = 3;
SELECT Salary
FROM (
    SELECT DISTINCT Salary
    FROM Employees
) AS UniqueSalaries
ORDER BY Salary DESC
OFFSET @N - 1 ROWS
FETCH NEXT 1 ROWS ONLY;

-- ============================================================================
-- QUESTION 17: INTERSECT IN SQL
-- ============================================================================

-- APPROACH 1: Using INTERSECT (Common records in both queries)
SELECT EmployeeID
FROM Employees
WHERE Salary > 58000
INTERSECT
SELECT EmployeeID
FROM Employees
WHERE DepartmentID = 2;

-- APPROACH 2: Using INNER JOIN (Alternative to INTERSECT)
SELECT DISTINCT e1.EmployeeID
FROM Employees e1
INNER JOIN Employees e2 ON e1.EmployeeID = e2.EmployeeID
WHERE e1.Salary > 58000
  AND e2.DepartmentID = 2;

-- ============================================================================
-- QUESTION 18: MINUS (EXCEPT) IN SQL
-- ============================================================================

-- APPROACH 1: Using EXCEPT (Records in first query but not in second)
SELECT EmployeeID
FROM Employees
WHERE Salary > 60000
EXCEPT
SELECT EmployeeID
FROM Employees
WHERE DepartmentID = 3;

-- APPROACH 2: Using LEFT JOIN with NULL check (Alternative to EXCEPT)
SELECT DISTINCT e1.EmployeeID
FROM Employees e1
LEFT JOIN Employees e2 ON e1.EmployeeID = e2.EmployeeID AND e2.DepartmentID = 3
WHERE e1.Salary > 60000
  AND e2.EmployeeID IS NULL;

-- ============================================================================
-- QUESTION 19: FIRST NORMAL FORM (1NF)
-- ============================================================================

-- Create a NON-1NF Table (Violates 1NF - has repeating groups)
CREATE TABLE EmployeeSkillsNonNormalized (
    EmployeeID INT PRIMARY KEY,
    EmployeeName VARCHAR(100),
    Skills VARCHAR(MAX) -- Contains comma-separated values
);

INSERT INTO EmployeeSkillsNonNormalized VALUES
(1, 'John Smith', 'SQL,Java,Python'),
(2, 'Sarah Johnson', 'C#,.NET,Azure'),
(3, 'Mike Davis', 'Python,JavaScript,React');

-- Create 1NF compliant tables (Normalized)
CREATE TABLE EmployeeSkillsNormalized (
    EmployeeID INT,
    SkillName VARCHAR(100),
    PRIMARY KEY (EmployeeID, SkillName),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

INSERT INTO EmployeeSkillsNormalized VALUES
(1, 'SQL'),
(1, 'Java'),
(1, 'Python'),
(2, 'C#'),
(2, '.NET'),
(2, 'Azure'),
(3, 'Python'),
(3, 'JavaScript'),
(3, 'React');

-- APPROACH 1: Query normalized data to show skills clearly
SELECT 
    e.EmployeeID,
    e.EmployeeName,
    STRING_AGG(s.SkillName, ',') AS Skills
FROM Employees e
JOIN EmployeeSkillsNormalized s ON e.EmployeeID = s.EmployeeID
GROUP BY e.EmployeeID, e.EmployeeName;

-- APPROACH 2: Query normalized data with proper join
SELECT 
    es.EmployeeID,
    e.EmployeeName,
    es.SkillName
FROM EmployeeSkillsNormalized es
JOIN Employees e ON es.EmployeeID = e.EmployeeID
ORDER BY es.EmployeeID, es.SkillName;

-- ============================================================================
-- END OF SQL INTERVIEW QUESTIONS GUIDE
-- ============================================================================
