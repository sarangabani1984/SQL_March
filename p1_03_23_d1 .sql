-- Question 4: Aggregate Filtering Logic (SQL - Medium)
-- Dataset: Products Table

-- Create the Products table
CREATE TABLE Products (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    Category VARCHAR(50) NOT NULL,
    Price FLOAT NOT NULL
);

-- Insert sample data
INSERT INTO Products (Category, Price) VALUES
('Electronics', 499.99),
('Electronics', 299.99),
('Electronics', 1299.99),
('Furniture', 199.99),
('Furniture', 399.99),
('Furniture', 549.99),
('Clothing', 29.99),
('Clothing', 49.99),
('Clothing', 79.99),
('Clothing', 99.99),
('Home & Garden', 89.99),
('Home & Garden', 149.99),
('Home & Garden', 199.99),
('Electronics', 199.99),
('Furniture', 699.99),
('Books', 12.99),
('Books', 18.99),
('Books', 24.99),
('Sports', 59.99),
('Sports', 89.99);

-- Query 1: Simple GROUP BY with HAVING
SELECT 
    Category, 
    AVG(Price) AS AveragePrice 
FROM Products 
GROUP BY Category 
HAVING AVG(Price) < 500;

-- Query 2: CTE approach (same result, cleaner logic)
WITH CTE AS (
    SELECT Category, AVG(Price) AS AveragePrice 
    FROM Products
    GROUP BY Category
)
SELECT * FROM CTE WHERE AveragePrice < 500;

-- =====================================================
-- Question 5: Departmental Ranking (SQL - Hard)
-- =====================================================

-- Create the Department_Salaries table
CREATE TABLE Department_Salaries (
    EmployeeID INT PRIMARY KEY IDENTITY(1001,1),
    DeptID INT NOT NULL,
    Salary INT NOT NULL
);

-- Insert sample data with multiple employees per department
INSERT INTO Department_Salaries (DeptID, Salary) VALUES
(1, 45000),
(1, 52000),
(1, 58000),
(1, 65000),
(2, 55000),
(2, 62000),
(2, 48000),
(2, 71000),
(2, 59000),
(3, 38000),
(3, 42000),
(3, 39000),
(4, 75000),
(4, 82000),
(4, 78000),
(4, 88000),
(4, 85000),
(5, 51000),
(5, 54000),
(5, 49000),
(1, 61000),
(2, 67000),
(3, 44000),
(4, 92000),
(5, 56000);

-- View all data
SELECT * FROM Department_Salaries ORDER BY DeptID, Salary DESC;

-- Example Query 1: Rank employees within each department by salary (DENSE_RANK)
WITH cte AS (
    SELECT 
        EmployeeID, 
        DeptID,
        DENSE_RANK() OVER(PARTITION BY DeptID ORDER BY Salary DESC) AS rnk
    FROM Department_Salaries
)
SELECT * FROM cte WHERE rnk = 2;

-- Example Query 2: Find top 2 paid employees per department
WITH RankedEmployees AS (
    SELECT 
        EmployeeID,
        DeptID,
        Salary,
        RANK() OVER (PARTITION BY DeptID ORDER BY Salary DESC) AS SalaryRank
    FROM Department_Salaries
)
SELECT * FROM RankedEmployees WHERE SalaryRank <= 2 ORDER BY DeptID, SalaryRank;

-- Example Query 3: Compare salary to department average
SELECT 
    EmployeeID,
    DeptID,
    Salary,
    AVG(Salary) OVER (PARTITION BY DeptID) AS DeptAvgSalary,
    Salary - AVG(Salary) OVER (PARTITION BY DeptID) AS DifFromAvg
FROM Department_Salaries
ORDER BY DeptID, Salary DESC;

-- =====================================================
-- Question 6: Display Nth Row in SQL
-- =====================================================

-- Create Employees table for Nth Row examples
CREATE TABLE Employees_nth (
    EmployeeID INT PRIMARY KEY IDENTITY(101,1),
    EmployeeName VARCHAR(50),
    Department VARCHAR(50),
    JoinDate DATE,
    Salary INT
);

-- Insert sample data
INSERT INTO Employees_nth (EmployeeName, Department, JoinDate, Salary) VALUES
('Alice Johnson', 'IT', '2020-01-15', 75000),
('Bob Smith', 'HR', '2019-05-20', 60000),
('Charlie Brown', 'IT', '2021-03-10', 80000),
('Diana Prince', 'Sales', '2020-07-22', 65000),
('Eve Wilson', 'IT', '2022-11-05', 70000),
('Frank Castle', 'Finance', '2018-09-30', 85000),
('Grace Lee', 'Sales', '2021-02-14', 68000),
('Henry Ford', 'HR', '2020-12-08', 58000),
('Iris Davis', 'Finance', '2019-04-17', 90000),
('Jack Ryan', 'IT', '2021-08-25', 72000);

-- View all employees
SELECT * FROM Employees ORDER BY EmployeeID;

-- =====================================================
-- APPROACH 1: Using OFFSET FETCH (Modern SQL - SQL Server 2012+)
-- =====================================================

-- Get the 5th row (Nth = 5)
-- OFFSET 4 ROWS = skip first 4 rows, FETCH NEXT 1 ROW = get next 1 row
SELECT * FROM Employees_nth offset 4 rows fetch next 1 rows only;


SELECT * FROM Employees
ORDER BY EmployeeID
OFFSET 4 ROWS
FETCH NEXT 1 ROW ONLY;

-- =====================================================
-- APPROACH 2: Using ROW_NUMBER() Window Function
-- =====================================================

-- Get the 5th row using ROW_NUMBER()
WITH RankedEmployees AS (
    SELECT 
        EmployeeID,
        EmployeeName,
        Department,
        JoinDate,
        Salary,
        ROW_NUMBER() OVER (ORDER BY EmployeeID) AS RowNum
    FROM Employees
)
SELECT * FROM RankedEmployees WHERE RowNum = 5;

-- =====================================================
-- APPROACH 3: Using TOP and NOT IN (Less Efficient)
-- =====================================================

-- Get the 5th row - less efficient for large datasets
SELECT TOP 1 * FROM Employees
WHERE EmployeeID NOT IN (
    SELECT TOP 4 EmployeeID FROM Employees ORDER BY EmployeeID
)
ORDER BY EmployeeID;

-- =====================================================
-- QUESTION 6A: Display Nth Row with Sorting
-- =====================================================

-- Get the 3rd highest paid employee (Nth by salary)
SELECT TOP 1 * FROM Employees
ORDER BY Salary DESC
OFFSET 2 ROWS;

-- Using ROW_NUMBER approach
WITH RankedBySalary AS (
    SELECT 
        EmployeeID,
        EmployeeName,
        Salary,
        ROW_NUMBER() OVER (ORDER BY Salary DESC) AS SalaryRank
    FROM Employees
)
SELECT * FROM RankedBySalary WHERE SalaryRank = 3;

-- =====================================================
-- QUESTION 6B: Nth Row within Groups (Per Department)
-- =====================================================

-- Get the 2nd employee by salary in each department
WITH RankedByDept AS (
    SELECT 
        EmployeeID,
        EmployeeName,
        Department,
        Salary,
        ROW_NUMBER() OVER (PARTITION BY Department ORDER BY Salary DESC) AS DeptSalaryRank
    FROM Employees
)
SELECT * FROM RankedByDept WHERE DeptSalaryRank = 2 ORDER BY Department;

-- =====================================================
-- QUESTION 6C: Nth Row based on Date Order
-- =====================================================

-- Get the 4th employee by JoinDate (4th employee to join)
WITH RankedByDate AS (
    SELECT 
        EmployeeID,
        EmployeeName,
        JoinDate,
        ROW_NUMBER() OVER (ORDER BY JoinDate ASC) AS JoinOrder
    FROM Employees
)
SELECT * FROM RankedByDate WHERE JoinOrder = 4;

-- =====================================================
-- QUESTION 6D: Get Multiple Nth Rows
-- =====================================================

-- Get the 2nd, 5th, and 8th employees
WITH RankedEmployees AS (
    SELECT 
        EmployeeID,
        EmployeeName,
        Department,
        ROW_NUMBER() OVER (ORDER BY EmployeeID) AS RowNum
    FROM Employees
)
SELECT * FROM RankedEmployees WHERE RowNum IN (2, 5, 8);

-- =====================================================
-- QUESTION 6E: Nth Row using DENSE_RANK (with ties)
-- =====================================================

-- Get employees at the 2nd salary level (handles ties)
WITH RankedBySalary AS (
    SELECT 
        EmployeeID,
        EmployeeName,
        Salary,
        DENSE_RANK() OVER (ORDER BY Salary DESC) AS SalaryLevel
    FROM Employees
)
SELECT * FROM RankedBySalary WHERE SalaryLevel = 2;

-- =====================================================
-- COMPARISON TABLE: Different Approaches
-- =====================================================

/*
APPROACH                  | EFFICIENCY | READABILITY | BEST FOR
--------------------------|------------|-------------|------------------
OFFSET FETCH              | Excellent  | Excellent   | Modern SQL Server
ROW_NUMBER() + CTE        | Excellent  | Good        | Complex logic
TOP + NOT IN              | Poor       | Fair        | Small datasets
DENSE_RANK()              | Excellent  | Good        | Handling ties
NTILE()                   | Excellent  | Fair        | Percentile groups
*/

-- =====================================================
-- BONUS: Get Last N Rows
-- =====================================================

-- Get last 3 employees (based on EmployeeID)
WITH RankedEmployees AS (
    SELECT 
        EmployeeID,
        EmployeeName,
        ROW_NUMBER() OVER (ORDER BY EmployeeID DESC) AS ReverseRowNum
    FROM Employees
)
SELECT * FROM RankedEmployees WHERE ReverseRowNum <= 3 ORDER BY EmployeeID;

-- Using OFFSET FETCH simpler:
SELECT * FROM Employees
ORDER BY EmployeeID DESC
OFFSET 0 ROWS
FETCH NEXT 3 ROWS ONLY;

-- =====================================================
-- BONUS: Nth Row in Subsets
-- =====================================================

-- Get the 1st employee from each department (by salary)
WITH RankedPerDept AS (
    SELECT 
        EmployeeID,
        EmployeeName,
        Department,
        Salary,
        ROW_NUMBER() OVER (PARTITION BY Department ORDER BY Salary DESC) AS DeptRank
    FROM Employees
)
SELECT * FROM RankedPerDept WHERE DeptRank = 1 ORDER BY Department;





