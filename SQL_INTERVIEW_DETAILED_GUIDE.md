# SQL Server Interview Questions - Complete Preparation Guide

## Content Overview
- **19 SQL Interview Questions** with 2 approaches each
- **Sample Tables** created and populated with realistic data
- **Ready-to-run SQL scripts** for SQL Server
- **Complexity levels**: Beginner to Advanced

---

## TABLE OF CONTENTS

1. [Sample Tables Created](#sample-tables-created)
2. [Question 1: 2nd Highest Salary](#question-1-2nd-highest-salary)
3. [Question 2: Department Wise Highest Salary](#question-2-department-wise-highest-salary)
4. [Question 3: Display Alternate Records](#question-3-display-alternate-records)
5. [Question 4: Display Duplicate of a Column](#question-4-display-duplicate-of-a-column)
6. [Question 5: Pattern Matching in SQL](#question-5-pattern-matching-in-sql)
7. [Question 6: Pattern Searching in SQL - 2](#question-6-pattern-searching-in-sql---2)
8. [Question 7: Display Nth Row in SQL](#question-7-display-nth-row-in-sql)
9. [Question 8: Union vs UnionAll](#question-8-union-vs-unionall)
10. [Question 9: Inner Join](#question-9-inner-join)
11. [Question 10: Self Join](#question-10-self-join)
12. [Question 11: Left Join](#question-11-left-join)
13. [Question 12: Right Join](#question-12-right-join)
14. [Question 13: Full Join](#question-13-full-join)
15. [Question 14: Cross Join](#question-14-cross-join)
16. [Question 15: Display 1st or Last Nth Rows](#question-15-display-1st-or-last-nth-rows)
17. [Question 16: Nth Highest Salary](#question-16-nth-highest-salary)
18. [Question 17: Intersect in SQL](#question-17-intersect-in-sql)
19. [Question 18: Minus/Except in SQL](#question-18-minusexcept-in-sql)
20. [Question 19: First Normal Form (1NF)](#question-19-first-normal-form-1nf)

---

## SAMPLE TABLES CREATED

### Tables in Use:
1. **Employees** - Contains employee records with salary and department info
2. **Departments** - Contains department information
3. **Orders** - Contains order data for employees

### Table Structure:
```
Employees Table:
- EmployeeID (PK)
- EmployeeName
- Salary
- DepartmentID (FK)
- HireDate
- ManagerID (Self-referencing FK)

Departments Table:
- DepartmentID (PK)
- DepartmentName
- Location

Orders Table:
- OrderID (PK)
- EmployeeID (FK)
- OrderAmount
- OrderDate
```

---

## DETAILED QUESTIONS & SOLUTIONS

### **QUESTION 1: 2nd HIGHEST SALARY**

**Problem Statement:** Find the second highest salary in the Employees table.

**Expected Output:** Single salary value

#### **Approach 1: Subquery with MAX() (Traditional)**
```sql
SELECT TOP 1 Salary
FROM Employees
WHERE Salary < (SELECT MAX(Salary) FROM Employees)
ORDER BY Salary DESC;
```

**Advantages:**
- Simple and easy to understand
- Works across all SQL versions
- Minimal performance impact for small datasets

**Disadvantages:**
- Not scalable for finding 3rd, 4th, Nth highest
- Less efficient for large datasets

#### **Approach 2: CTE with ROW_NUMBER() (Modern & Recommended)**
```sql
WITH RankedSalaries AS (
    SELECT Salary, 
           ROW_NUMBER() OVER (ORDER BY Salary DESC) AS SalaryRank
    FROM (SELECT DISTINCT Salary FROM Employees) AS UniqueSalaries
)
SELECT Salary
FROM RankedSalaries
WHERE SalaryRank = 2;
```

**Advantages:**
- Easy to modify for Nth highest (just change WHERE clause)
- Better for complex hierarchical queries
- More readable with window functions

**Disadvantages:**
- Requires SQL Server 2005+
- CTE adds slight complexity

**Real Interview Tip:** Mention both approaches and explain that Approach 2 is more flexible for finding any Nth value, making it better for scalability.

---

### **QUESTION 2: DEPARTMENT WISE HIGHEST SALARY**

**Problem Statement:** Find the highest salary in each department.

**Expected Output:**
```
DepartmentID | DepartmentName | HighestSalary
1            | Sales          | 70000
2            | Marketing      | 75000
3            | IT             | 80000
```

#### **Approach 1: GROUP BY with MAX() & JOIN (Classic)**
```sql
SELECT 
    d.DepartmentID,
    d.DepartmentName,
    MAX(e.Salary) AS HighestSalary
FROM Employees e
JOIN Departments d ON e.DepartmentID = d.DepartmentID
GROUP BY d.DepartmentID, d.DepartmentName
ORDER BY d.DepartmentID;
```

**Advantages:**
- Straightforward and efficient
- Works on all SQL versions
- Simple to understand

**Disadvantages:**
- If you need employee details with highest salary, need additional join
- Less flexible for ranking within groups

#### **Approach 2: CTE with ROW_NUMBER() (Get Employee Details Too)**
```sql
WITH RankedDeptSalaries AS (
    SELECT 
        DepartmentID,
        EmployeeName,
        Salary,
        ROW_NUMBER() OVER (PARTITION BY DepartmentID ORDER BY Salary DESC) AS SalaryRank
    FROM Employees
)
SELECT 
    d.DepartmentID,
    d.DepartmentName,
    rds.EmployeeName,
    rds.Salary AS HighestSalary
FROM RankedDeptSalaries rds
JOIN Departments d ON rds.DepartmentID = d.DepartmentID
WHERE rds.SalaryRank = 1;
```

**Advantages:**
- Can get employee name along with salary
- Flexible for finding top N by department
- Uses `PARTITION BY` for grouping

**Disadvantages:**
- More complex query
- Requires understanding of window functions

**Interview Tip:** This is a great opportunity to showcase knowledge of window functions. Mention both approaches and explain when to use each.

---

### **QUESTION 3: DISPLAY ALTERNATE RECORDS**

**Problem Statement:** Display every alternate row from the Employees table (1st, 3rd, 5th, etc.).

**Expected Output:** Employees with odd row numbers

#### **Approach 1: ROW_NUMBER() with Modulo Operator**
```sql
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
```

**Advantages:**
- Uses modulo operator (% 2) for clarity
- Easy to modify (% 3 for every 3rd, etc.)
- Works efficiently for large datasets

#### **Approach 2: CTE Method (Cleaner)**
```sql
SELECT *
FROM (
    SELECT *, ROW_NUMBER() OVER (ORDER BY EmployeeID) AS RowNum
    FROM Employees
) AS AlternateRows
WHERE RowNum % 2 = 1;
```

**Advantages:**
- Cleaner syntax
- Better readability
- Same performance as Approach 1

**Interview Tip:** Explain the modulo operator: `% 2 = 1` for odd rows, `% 2 = 0` for even rows.

---

### **QUESTION 4: DISPLAY DUPLICATE OF A COLUMN**

**Problem Statement:** Find all salary values that appear more than once in the Employees table.

**Expected Output:**
```
Salary | DuplicateCount
60000  | 3
55000  | 2
```

#### **Approach 1: GROUP BY with HAVING (Simple)**
```sql
SELECT Salary, COUNT(*) AS DuplicateCount
FROM Employees
GROUP BY Salary
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC;
```

**Advantages:**
- Very simple and efficient
- Perfect for finding duplicate values
- Works on all versions

#### **Approach 2: CTE with Detailed Info**
```sql
WITH DuplicateSalaries AS (
    SELECT 
        Salary,
        ROW_NUMBER() OVER (PARTITION BY Salary ORDER BY EmployeeID) AS DupRank
    FROM Employees
)
SELECT 
    e.EmployeeID,
    e.EmployeeName,
    e.Salary,
    (SELECT COUNT(*) FROM Employees WHERE Salary = e.Salary) AS TotalWithSalary
FROM Employees e
WHERE (SELECT COUNT(*) FROM Employees WHERE Salary = e.Salary) > 1
ORDER BY e.Salary DESC;
```

**Advantages:**
- Shows all employee details with duplicate salaries
- More informative
- Better for reporting

**Interview Tip:** Approach 1 is preferred for finding duplicates. Approach 2 when you need detailed records of duplicate entries.

---

### **QUESTION 5: PATTERN MATCHING IN SQL**

**Problem Statement:** Find employees whose names start with 'J' or contain specific patterns.

**Expected Output:** All employees matching pattern

#### **Approach 1: LIKE with Wildcards (Traditional)**
```sql
SELECT *
FROM Employees
WHERE EmployeeName LIKE 'J%' -- Names starting with J
ORDER BY EmployeeName;
```

**Common Patterns:**
- `'A%'` - Starts with A
- `'%son'` - Ends with son
- `'%john%'` - Contains john
- `'J_hn'` - J followed by any char, then hn

#### **Approach 2: PATINDEX() Function (Advanced)**
```sql
SELECT *
FROM Employees
WHERE PATINDEX('%smith%', LOWER(EmployeeName)) > 0
ORDER BY EmployeeName;
```

**Advantages of PATINDEX:**
- Case-insensitive with LOWER()
- Can use regex-like patterns
- More flexible for complex patterns

**Interview Tip:** 
- `LIKE` is most commonly used
- `PATINDEX()` is more powerful but less known
- Mention both in interview

---

### **QUESTION 6: PATTERN SEARCHING IN SQL - 2**

**Problem Statement:** Search for multiple patterns (names ending with 'son' or containing 'ed').

#### **Approach 1: LIKE with Multiple OR Conditions**
```sql
SELECT *
FROM Employees
WHERE EmployeeName LIKE '%son' 
   OR EmployeeName LIKE '%ed'
ORDER BY EmployeeName;
```

#### **Approach 2: CHARINDEX() Function**
```sql
SELECT *
FROM Employees
WHERE CHARINDEX('son', EmployeeName) > 0
   OR CHARINDEX('ed', EmployeeName) > 0
ORDER BY EmployeeName;
```

**Comparison:**
| Feature | LIKE | CHARINDEX |
|---------|------|-----------|
| Case Sensitive | No | Yes (use LOWER) |
| Wildcards | Yes | No |
| Find Position | No | Yes |
| Performance | Better | Good |

---

### **QUESTION 7: DISPLAY NTH ROW IN SQL**

**Problem Statement:** Get the 5th row from the Employees table.

#### **Approach 1: OFFSET FETCH (SQL Server 2012+, Recommended)**
```sql
DECLARE @N INT = 5;
SELECT *
FROM Employees
ORDER BY EmployeeID
OFFSET @N - 1 ROWS
FETCH NEXT 1 ROWS ONLY;
```

**Advantages:**
- Modern SQL standard
- Very efficient
- Works in Azure SQL
- Easy for pagination

#### **Approach 2: ROW_NUMBER() with CTE**
```sql
DECLARE @N INT = 5;
SELECT *
FROM (
    SELECT *, ROW_NUMBER() OVER (ORDER BY EmployeeID) AS RowNum
    FROM Employees
) AS NumberedRows
WHERE RowNum = @N;
```

**Advantages:**
- Works on older SQL versions
- Provides more control

**Interview Tip:** OFFSET FETCH is the modern standard. Use it preferentially.

---

### **QUESTION 8: UNION VS UNION ALL**

**Problem Statement:** Combine results from two different queries and understand the difference.

#### **Scenario:** Employees in Sales dept OR earning > 65000

#### **Approach 1: UNION (Removes Duplicates)**
```sql
SELECT EmployeeName, Salary
FROM Employees
WHERE DepartmentID = 1
UNION
SELECT EmployeeName, Salary
FROM Employees
WHERE Salary > 65000
ORDER BY EmployeeName;
```

**Characteristics:**
- Removes duplicate rows
- Slower due to DISTINCT operation
- Use when you need unique records

#### **Approach 2: UNION ALL (Keeps Duplicates)**
```sql
SELECT EmployeeName, Salary
FROM Employees
WHERE DepartmentID = 1
UNION ALL
SELECT EmployeeName, Salary
FROM Employees
WHERE Salary > 65000
ORDER BY EmployeeName;
```

**Characteristics:**
- Keeps all rows including duplicates
- Faster (no DISTINCT operation)
- Use when duplicates are acceptable

**Comparison Table:**
| Aspect | UNION | UNION ALL |
|--------|-------|-----------|
| Duplicates | Removed | Kept |
| Performance | Slower | Faster |
| Use Case | Unique records needed | Any records |
| Sorting | Often needed | Type columns must match |

**Interview Tip:** Always explain that UNION ALL is faster because it doesn't perform DISTINCT. Use UNION only when you specifically need unique records.

---

### **QUESTION 9: INNER JOIN**

**Problem Statement:** Get employee details along with their department names.

**Expected Output:**
```
EmployeeID | EmployeeName | DepartmentName
1          | John Smith   | Sales
2          | Sarah Johnson| Sales
...
```

#### **Approach 1: INNER JOIN (Explicit, Recommended)**
```sql
SELECT 
    e.EmployeeID,
    e.EmployeeName,
    e.Salary,
    d.DepartmentName
FROM Employees e
INNER JOIN Departments d ON e.DepartmentID = d.DepartmentID
ORDER BY e.EmployeeID;
```

**Advantages:**
- Clear and explicit
- Readable
- Easy to understand intent

#### **Approach 2: WHERE Clause (Implicit Join, Legacy)**
```sql
SELECT 
    e.EmployeeID,
    e.EmployeeName,
    e.Salary,
    d.DepartmentName
FROM Employees e, Departments d
WHERE e.DepartmentID = d.DepartmentID
ORDER BY e.EmployeeID;
```

**Disadvantages of Approach 2:**
- Less readable
- Harder to distinguish join from WHERE filters
- Outdated syntax

**Interview Tip:** Always prefer explicit INNER JOIN syntax. It's clearer and follows modern SQL standards.

---

### **QUESTION 10: SELF JOIN**

**Problem Statement:** Get employee and their manager information from the same Employees table.

**Expected Output:**
```
EmployeeID | Employee | Manager | Salary
1          | John Smith | NULL | 50000
2          | Sarah Johnson | John Smith | 60000
...
```

#### **Approach 1: Self JOIN with LEFT JOIN (Handles NULL Managers)**
```sql
SELECT 
    e.EmployeeID,
    e.EmployeeName AS Employee,
    m.EmployeeName AS Manager,
    e.Salary
FROM Employees e
LEFT JOIN Employees m ON e.ManagerID = m.EmployeeID
ORDER BY e.EmployeeID;
```

**Advantages:**
- Shows all employees even without managers
- Uses LEFT JOIN to handle NULLs

#### **Approach 2: Self JOIN with WHERE (Only Employees with Managers)**
```sql
SELECT 
    e.EmployeeID,
    e.EmployeeName AS Employee,
    m.EmployeeName AS Manager
FROM Employees e, Employees m
WHERE e.ManagerID = m.EmployeeID
ORDER BY e.EmployeeID;
```

**Disadvantages:**
- Misses employees without managers
- Outdated syntax

**Interview Tip:** Self Join is joining a table with itself. Always use aliases (e, m) to distinguish the relationship. The key is the self-referencing foreign key (ManagerID).

---

### **QUESTION 11: LEFT JOIN**

**Problem Statement:** Get all employees with their department, including unassigned employees.

#### **Approach 1: Basic LEFT JOIN**
```sql
SELECT 
    e.EmployeeID,
    e.EmployeeName,
    d.DepartmentName,
    e.Salary
FROM Employees e
LEFT JOIN Departments d ON e.DepartmentID = d.DepartmentID
ORDER BY e.EmployeeID;
```

**Characteristics:**
- All rows from LEFT table (Employees)
- Matching rows from RIGHT table (Departments)
- NULLs where no match

#### **Approach 2: LEFT JOIN with Aggregation**
```sql
SELECT 
    d.DepartmentName,
    COUNT(e.EmployeeID) AS EmployeeCount,
    AVG(e.Salary) AS AvgSalary
FROM Departments d
LEFT JOIN Employees e ON d.DepartmentID = e.DepartmentID
GROUP BY d.DepartmentName;
```

**Advantages:**
- Shows all departments even if no employees
- Provides aggregated data

**Interview Tip:** LEFT JOIN = All from LEFT + Matching from RIGHT

---

### **QUESTION 12: RIGHT JOIN**

**Problem Statement:** Get all departments with their employees.

#### **Approach 1: RIGHT JOIN**
```sql
SELECT 
    e.EmployeeID,
    e.EmployeeName,
    d.DepartmentName
FROM Employees e
RIGHT JOIN Departments d ON e.DepartmentID = d.DepartmentID
ORDER BY d.DepartmentID;
```

#### **Approach 2: RIGHT JOIN with Aggregation**
```sql
SELECT 
    d.DepartmentID,
    d.DepartmentName,
    COUNT(e.EmployeeID) AS TotalEmployees
FROM Employees e
RIGHT JOIN Departments d ON e.DepartmentID = d.DepartmentID
GROUP BY d.DepartmentID, d.DepartmentName;
```

**Interview Tip:** RIGHT JOIN = All from RIGHT + Matching from LEFT
You can usually rewrite RIGHT JOIN as LEFT JOIN by reversing table order (more readable).

---

### **QUESTION 13: FULL JOIN**

**Problem Statement:** Get all employees and all departments, showing relationships.

#### **Approach 1: FULL OUTER JOIN (Direct)**
```sql
SELECT 
    e.EmployeeID,
    e.EmployeeName,
    d.DepartmentName
FROM Employees e
FULL OUTER JOIN Departments d ON e.DepartmentID = d.DepartmentID
ORDER BY e.EmployeeID;
```

**Characteristics:**
- All rows from both tables
- NULLs where no match

#### **Approach 2: FULL OUTER JOIN using UNION**
```sql
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
```

**When to use Approach 2:**
- Older SQL versions without FULL OUTER JOIN
- Need different logic for left/right sides

**Interview Tip:** FULL OUTER JOIN = All from BOTH tables

---

### **QUESTION 14: CROSS JOIN**

**Problem Statement:** Create a Cartesian product of employees and departments.

**Expected Output:** Every employee paired with every department (EmployeeCount × DepartmentCount rows)

#### **Approach 1: CROSS JOIN (Explicit)**
```sql
SELECT 
    e.EmployeeName,
    d.DepartmentName
FROM Employees e
CROSS JOIN Departments d
ORDER BY e.EmployeeName, d.DepartmentName;
```

#### **Approach 2: Implicit CROSS JOIN (Comma Syntax)**
```sql
SELECT 
    e.EmployeeName,
    d.DepartmentName,
    e.Salary
FROM Employees e, Departments d
ORDER BY e.EmployeeName;
```

**Characteristics:**
- No ON condition
- Result rows = Rows(Table1) × Rows(Table2)
- 12 Employees × 3 Departments = 36 rows

**Use Cases:**
- Generate combinations
- Calendar date combinations
- Time slot generation

**Interview Tip:** CROSS JOIN is powerful but use carefully as it can create huge result sets!

---

### **QUESTION 15: DISPLAY 1ST OR LAST NTH ROWS**

**Problem Statement:** Get first 5 or last 5 rows from Employees.

#### **Approach 1: First 5 Rows using TOP**
```sql
SELECT TOP 5 *
FROM Employees
ORDER BY EmployeeID;
```

#### **Approach 2: Last 5 Rows using TOP with DESC**
```sql
SELECT TOP 5 *
FROM Employees
ORDER BY EmployeeID DESC;
```

#### **Approach 3: Last 5 Rows using OFFSET**
```sql
SELECT *
FROM Employees
ORDER BY EmployeeID
OFFSET (SELECT COUNT(*) - 5 FROM Employees) ROWS
FETCH NEXT 5 ROWS ONLY;
```

**Comparison:**
| Method | Use Case |
|--------|----------|
| TOP N | Simple first/last N |
| OFFSET FETCH | Pagination, more control |
| TOP with DESC | Quick last N (may reverse order) |

---

### **QUESTION 16: NTH HIGHEST SALARY**

**Problem Statement:** Find the 3rd highest salary in the table.

#### **Approach 1: DENSE_RANK() with CTE (Recommended)**
```sql
DECLARE @N INT = 3;
WITH RankedSalaries AS (
    SELECT DISTINCT 
        Salary,
        DENSE_RANK() OVER (ORDER BY Salary DESC) AS SalaryRank
    FROM Employees
)
SELECT Salary
FROM RankedSalaries
WHERE SalaryRank = @N;
```

**Why DENSE_RANK()?**
- Doesn't skip ranks with duplicates
- Perfect for finding Nth unique value
- 1st: 80000, 2nd: 75000, 3rd: 70000 (continuous)

#### **Approach 2: ROW_NUMBER() with OFFSET**
```sql
DECLARE @N INT = 3;
SELECT Salary
FROM (
    SELECT DISTINCT Salary
    FROM Employees
) AS UniqueSalaries
ORDER BY Salary DESC
OFFSET @N - 1 ROWS
FETCH NEXT 1 ROWS ONLY;
```

**Window Function Comparison:**
| Function | Behavior with Duplicates |
|----------|------------------------|
| ROW_NUMBER() | 1, 2, 3, 4, 5 (skips) |
| RANK() | 1, 2, 2, 4, 5 (gaps) |
| DENSE_RANK() | 1, 2, 2, 3, 4 (no gaps) |

**Interview Tip:** DENSE_RANK() is usually best for finding Nth highest because it doesn't skip ranks.

---

### **QUESTION 17: INTERSECT IN SQL**

**Problem Statement:** Find employees earning > 58000 AND working in Department 2.

#### **Approach 1: INTERSECT (Set Operation)**
```sql
SELECT EmployeeID
FROM Employees
WHERE Salary > 58000
INTERSECT
SELECT EmployeeID
FROM Employees
WHERE DepartmentID = 2;
```

**Characteristics:**
- Returns rows common to both queries
- Removes duplicates automatically
- Works with any number of columns

#### **Approach 2: INNER JOIN (Alternative)**
```sql
SELECT DISTINCT e1.EmployeeID
FROM Employees e1
INNER JOIN Employees e2 ON e1.EmployeeID = e2.EmployeeID
WHERE e1.Salary > 58000
  AND e2.DepartmentID = 2;
```

**Comparison:**
| Method | Use Case |
|--------|----------|
| INTERSECT | Simple, multiple queries |
| INNER JOIN | Better control, filtering |

**Interview Tip:** INTERSECT is cleaner for finding common records between queries.

---

### **QUESTION 18: MINUS/EXCEPT IN SQL**

**Problem Statement:** Find employees earning > 60000 but NOT in Department 3.

#### **Approach 1: EXCEPT (Set Operation)**
```sql
SELECT EmployeeID
FROM Employees
WHERE Salary > 60000
EXCEPT
SELECT EmployeeID
FROM Employees
WHERE DepartmentID = 3;
```

**Characteristics:**
- Returns rows from first query NOT in second
- Removes duplicates
- SQL Standard operation

#### **Approach 2: LEFT JOIN with NULL check**
```sql
SELECT DISTINCT e1.EmployeeID
FROM Employees e1
LEFT JOIN Employees e2 ON e1.EmployeeID = e2.EmployeeID AND e2.DepartmentID = 3
WHERE e1.Salary > 60000
  AND e2.EmployeeID IS NULL;
```

**Key Concept:**
- `EXCEPT` = A - B (difference)
- Result: In A but not in B

**Interview Tip:** EXCEPT is cleaner but LEFT JOIN gives more control over the logic.

---

### **QUESTION 19: FIRST NORMAL FORM (1NF)**

**Problem Statement:** Normalize a table violating 1NF rules.

#### **Problem: NON-1NF Table (Has Repeating Groups)**
```sql
-- VIOLATES 1NF - Multiple values in single column
EmployeeSkillsNonNormalized:
EmployeeID | EmployeeName | Skills
1          | John Smith   | SQL,Java,Python
2          | Sarah Johnson| C#,.NET,Azure
3          | Mike Davis   | Python,JavaScript,React
```

**Problems:**
- Comma-separated values violate atomicity
- Hard to query single skills
- Difficult to add/remove skills
- Cannot create proper foreign keys

#### **Approach 1: Proper 1NF Table (Separate Row per Value)**
```sql
CREATE TABLE EmployeeSkillsNormalized (
    EmployeeID INT,
    SkillName VARCHAR(100),
    PRIMARY KEY (EmployeeID, SkillName),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

-- Data becomes:
EmployeeID | SkillName
1          | SQL
1          | Java
1          | Python
2          | C#
2          | .NET
...
```

**Benefits:**
- Each cell has single value (Atomic)
- Easy to query: `WHERE SkillName = 'SQL'`
- Can enforce referential integrity
- Can easily add/remove skills
- Enables proper indexing

#### **Approach 2: Query Normalized Data**
```sql
SELECT 
    e.EmployeeID,
    e.EmployeeName,
    STRING_AGG(s.SkillName, ',') AS Skills
FROM Employees e
JOIN EmployeeSkillsNormalized s ON e.EmployeeID = s.EmployeeID
GROUP BY e.EmployeeID, e.EmployeeName;
```

**1NF Rules:**
1. ✓ Atomic values (no repeating groups)
2. ✓ All rows have same number of columns
3. ✓ Unique row identifier (Primary Key)
4. ✓ No duplicate rows

**Interview Tip:** 1NF is about atomicity - each cell must contain single value. Always normalize repeating groups into separate rows and tables.

---

## INTERVIEW TIPS & BEST PRACTICES

### 1. **Always Ask Clarifying Questions:**
   - "Do you want NULL values included?"
   - "Should I include duplicate values?"
   - "What if there are multiple employees with same highest salary?"

### 2. **Performance Considerations:**
   - UNION ALL is faster than UNION (no DISTINCT)
   - Indexed columns in WHERE/JOIN perform better
   - OFFSET FETCH better for pagination than TOP

### 3. **Keys for Success:**
   - Know when to use each JOIN type
   - Understand window functions (ROW_NUMBER, RANK, DENSE_RANK)
   - Master GROUP BY and HAVING
   - Practice set operations (UNION, INTERSECT, EXCEPT)

### 4. **Common Mistakes to Avoid:**
   - Forgetting DISTINCT in queries with JOINs
   - Using UNION when UNION ALL is faster
   - Not using proper aliases in complex JOINs
   - Forgetting GROUP BY when using aggregates

### 5. **When to Use Each Approach:**
   - **Approach 1 (Simple/Traditional):** For clarity and ease of understanding
   - **Approach 2 (Advanced):** For complexity, flexibility, and scalability

---

## PRACTICE EXERCISES

1. Try modifying queries: Find 3rd, 4th, 5th highest salary
2. Add filters: Find department-wise top 2 earners
3. Combine approaches: Use self-join with aggregation
4. Performance test: Compare execution plans for different approaches
5. Normalize data: Take non-1NF examples and normalize them

---

## RESOURCES FOR FURTHER LEARNING

- SQL Server window functions documentation
- Query execution plans analysis
- Indexing strategies for joins
- Set theory in SQL
- Database normalization rules

Good luck with your interview preparation!
