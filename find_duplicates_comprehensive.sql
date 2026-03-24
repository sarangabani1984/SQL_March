-- =====================================================
-- FINDING DUPLICATES IN SQL SERVER
-- Multiple Methods & Approaches for Interview Prep
-- =====================================================

-- =====================================================
-- PART 1: CREATE SAMPLE DATASET
-- =====================================================

-- Create sample Employees table with duplicate entries
CREATE TABLE Employees (
    EmployeeID INT,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Email VARCHAR(100),
    Department VARCHAR(50),
    Salary DECIMAL(10, 2)
);

-- Insert sample data with duplicates
INSERT INTO Employees VALUES
(1, 'John', 'Smith', 'john.smith@company.com', 'IT', 50000),
(2, 'Jane', 'Doe', 'jane.doe@company.com', 'HR', 45000),
(3, 'John', 'Smith', 'john.smith@company.com', 'IT', 50000),  -- DUPLICATE of ID 1
(4, 'Mike', 'Johnson', 'mike.j@company.com', 'Sales', 55000),
(5, 'Jane', 'Doe', 'jane.doe@company.com', 'HR', 45000),      -- DUPLICATE of ID 2
(6, 'Sarah', 'Williams', 'sarah.w@company.com', 'IT', 52000),
(7, 'John', 'Smith', 'john.smith@company.com', 'IT', 50000),  -- Another DUPLICATE of ID 1
(8, 'Mike', 'Johnson', 'mike.j@company.com', 'Sales', 55000), -- DUPLICATE of ID 4
(9, 'Robert', 'Brown', 'robert.b@company.com', 'Finance', 60000),
(10, 'Sarah', 'Williams', 'sarah.w@company.com', 'IT', 52000);-- DUPLICATE of ID 6

SELECT * FROM Employees;

-- =====================================================
-- PART 2: METHOD 1 - GROUP BY + HAVING (Most Common)
-- =====================================================
-- Best for: Simple duplicate detection by specific columns
-- Time Complexity: O(n log n)

PRINT '=== METHOD 1: GROUP BY with HAVING ==='
SELECT 
    FirstName, 
    LastName, 
    Email,
    COUNT(*) AS DuplicateCount
FROM Employees
GROUP BY FirstName, LastName, Email
HAVING COUNT(*) > 1
ORDER BY DuplicateCount DESC;

-- =====================================================
-- PART 3: METHOD 2 - ROW_NUMBER() Window Function (Most Flexible)
-- =====================================================
-- Best for: Finding ALL duplicate rows (not just count)
-- Time Complexity: O(n)

PRINT '=== METHOD 2: ROW_NUMBER() Window Function ==='
WITH DuplicatesCTE AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY FirstName, LastName, Email ORDER BY EmployeeID) AS RowNum
    FROM Employees
)
SELECT *
FROM DuplicatesCTE
WHERE RowNum > 1;  -- Shows all duplicate rows except first occurrence

-- =====================================================
-- PART 4: METHOD 3 - Mark ALL Duplicates (including first)
-- =====================================================
-- Shows every duplicate row, including the first occurrence

PRINT '=== METHOD 3: Mark ALL Duplicates (Including First) ==='
WITH DuplicatesCTE AS (
    SELECT 
        *,
        COUNT(*) OVER (PARTITION BY FirstName, LastName, Email) AS DuplicateCount
    FROM Employees
)
SELECT *
FROM DuplicatesCTE
WHERE DuplicateCount > 1
ORDER BY FirstName, LastName, Email;

-- =====================================================
-- PART 5: METHOD 4 - SELF JOIN (Traditional Approach)
-- =====================================================
-- Best for: Older SQL versions, specific scenarios
-- Advantage: More control over join conditions

PRINT '=== METHOD 4: Self Join ==='
SELECT DISTINCT
    e1.EmployeeID,
    e1.FirstName,
    e1.LastName,
    e1.Email,
    e1.Department
FROM Employees e1
INNER JOIN Employees e2
    ON e1.FirstName = e2.FirstName
    AND e1.LastName = e2.LastName
    AND e1.Email = e2.Email
    AND e1.EmployeeID < e2.EmployeeID  -- Avoid self-matching
ORDER BY e1.FirstName, e1.LastName;

-- =====================================================
-- PART 6: METHOD 5 - EXISTS Clause
-- =====================================================
-- Best for: Complex duplicate conditions

PRINT '=== METHOD 5: EXISTS Clause ==='
SELECT e1.*
FROM Employees e1
WHERE EXISTS (
    SELECT 1
    FROM Employees e2
    WHERE e1.FirstName = e2.FirstName
    AND e1.LastName = e2.LastName
    AND e1.Email = e2.Email
    AND e1.EmployeeID != e2.EmployeeID  -- Different row, same data
);

-- =====================================================
-- PART 7: METHOD 6 - IN with Subquery
-- =====================================================
-- Best for: Finding duplicates based on count

PRINT '=== METHOD 6: IN with Subquery ==='
SELECT *
FROM Employees
WHERE (FirstName, LastName, Email) IN (
    SELECT FirstName, LastName, Email
    FROM Employees
    GROUP BY FirstName, LastName, Email
    HAVING COUNT(*) > 1
)
ORDER BY FirstName, LastName, Email;

-- =====================================================
-- PART 8: METHOD 7 - RANK() vs ROW_NUMBER()
-- =====================================================
-- RANK(): Shows same rank for duplicates
-- ROW_NUMBER(): Always unique, ordered

PRINT '=== METHOD 7: Using RANK() Function ==='
WITH RankedDuplicates AS (
    SELECT 
        *,
        RANK() OVER (PARTITION BY FirstName, LastName, Email ORDER BY EmployeeID) AS RankNum
    FROM Employees
)
SELECT *
FROM RankedDuplicates
WHERE RankNum > 1;

-- =====================================================
-- PART 9: METHOD 8 - Find Duplicates with Counts
-- =====================================================
-- Shows duplicates with detailed count information

PRINT '=== METHOD 8: Duplicates with Detailed Counts ==='
SELECT 
    FirstName,
    LastName,
    Email,
    COUNT(*) AS TotalOccurrences,
    COUNT(*) - 1 AS NumberOfDuplicates,
    STRING_AGG(CAST(EmployeeID AS VARCHAR), ', ') AS DuplicateEmployeeIDs
FROM Employees
GROUP BY FirstName, LastName, Email
HAVING COUNT(*) > 1
ORDER BY TotalOccurrences DESC;

-- =====================================================
-- PART 10: METHOD 9 - Find Complete Duplicate Rows
-- =====================================================
-- Show ALL columns to identify complete row duplicates

PRINT '=== METHOD 9: Complete Duplicate Rows ==='
SELECT 
    e.*,
    COUNT(*) OVER (PARTITION BY e.FirstName, e.LastName, e.Email, e.Department, e.Salary) AS DuplicateRowCount
FROM Employees e
WHERE EXISTS (
    SELECT 1
    FROM Employees e2
    WHERE e.FirstName = e2.FirstName
    AND e.LastName = e2.LastName
    AND e.Email = e2.Email
    AND e.Department = e2.Department
    AND e.Salary = e2.Salary
    AND e.EmployeeID != e2.EmployeeID
)
ORDER BY FirstName, LastName;

-- =====================================================
-- PART 11: BONUS - Delete Duplicates (Keep First)
-- =====================================================
-- CAUTION: This will DELETE data!

PRINT '=== BONUS: Delete Duplicates (Keep First Row) ==='
-- Preview which rows will be deleted:
WITH DupCTE AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY FirstName, LastName, Email ORDER BY EmployeeID) AS RowNum
    FROM Employees
)
SELECT * FROM DupCTE WHERE RowNum > 1;

-- Actual delete (uncomment to execute):
/*
WITH DupCTE AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY FirstName, LastName, Email ORDER BY EmployeeID) AS RowNum
    FROM Employees
)
DELETE FROM DupCTE WHERE RowNum > 1;
*/

-- =====================================================
-- PART 12: BONUS - Find Duplicates in Specific Columns Only
-- =====================================================
-- Example: Find duplicates by Email only (ignoring name)

PRINT '=== BONUS: Duplicates by Specific Column (Email) ==='
SELECT 
    Email,
    COUNT(*) AS DuplicateCount,
    STRING_AGG(CONCAT(FirstName, ' ', LastName), ', ') AS AllNames
FROM Employees
GROUP BY Email
HAVING COUNT(*) > 1;

-- =====================================================
-- CLEANUP (Optional)
-- =====================================================
-- Drop the table if needed for re-running script
-- DROP TABLE Employees;

-- =====================================================
-- SUMMARY: When to Use Each Method
-- =====================================================
/*
1. GROUP BY + HAVING
   - Most readable
   - Best for counting duplicates
   - Can only return aggregate info
   
2. ROW_NUMBER() (RECOMMENDED)
   - Most efficient
   - Can return full rows
   - Shows each duplicate separately
   - Modern standard approach
   
3. RANK()
   - Good for understanding rank distribution
   - Handles ties differently than ROW_NUMBER
   
4. SELF JOIN
   - Good for complex conditions
   - Can be slower on large tables
   - More control over matching logic
   
5. EXISTS
   - Good for complex scenarios
   - Better performance than some JOINs
   - More readable logic
   
6. IN Subquery
   - Good for simple cases
   - Can be slower than other methods

Interview Tips:
✓ Always clarify: Are duplicates based on ALL columns or specific columns?
✓ Know the difference between ROW_NUMBER, RANK, and DENSE_RANK
✓ Window functions are preferred in modern SQL (SQL Server 2005+)
✓ Be able to explain time complexity of each approach
✓ Know how to delete duplicates safely (always preview first!)
*/
