-- ===============================================
-- SQL DAY 2: SELF-JOIN PRACTICE
-- Level 2 (Intermediate) & Level 3 (Advanced)
-- ===============================================

-- Dataset: emp2 table (created in Day 1)
-- Run this if starting fresh:

CREATE TABLE emp2 (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    department VARCHAR(30),
    manager_id INT,
    salary INT,
    hire_date DATE,
    FOREIGN KEY (manager_id) REFERENCES emp2(emp_id)
);

INSERT INTO emp2 VALUES
(1, 'Alice', 'Management', NULL, 80000, '2015-01-10'),
(2, 'Bob', 'Sales', 1, 50000, '2018-03-15'),
(3, 'Charlie', 'Sales', 1, 55000, '2019-05-20'),
(4, 'David', 'IT', 2, 45000, '2020-07-22'),
(5, 'Eve', 'IT', 2, 48000, '2020-08-11'),
(6, 'Frank', 'HR', 1, 52000, '2017-11-05'),
(7, 'Grace', 'HR', 6, 42000, '2021-02-14'),
(8, 'Henry', 'Sales', 3, 40000, '2022-01-08');

-- ===============================================
-- LEVEL 2: INTERMEDIATE (Complex Conditions)
-- ===============================================

-- Q4: Find employees and their manager's manager (2-level hierarchy)
-- Problem: Show employee → manager → manager's manager

SELECT 
    e.emp_id,
    e.emp_name AS employee,
    m1.emp_name AS direct_manager,
    m2.emp_name AS managers_manager
FROM emp2 e
LEFT JOIN emp2 m1 ON e.manager_id = m1.emp_id
LEFT JOIN emp2 m2 ON m1.manager_id = m2.emp_id
ORDER BY e.emp_id;

-- Expected output:
-- emp_id | employee | direct_manager | managers_manager
-- 1      | Alice    | NULL           | NULL
-- 2      | Bob      | Alice          | NULL
-- 3      | Charlie  | Alice          | NULL
-- 4      | David    | Bob            | Alice
-- 5      | Eve      | Bob            | Alice
-- 6      | Frank    | Alice          | NULL
-- 7      | Grace    | Frank          | Alice
-- 8      | Henry    | Charlie        | Alice

-- -----------------------------------------------
-- Q5: Find who has direct reports and count them
-- Problem: How many direct reports does each employee have?
-- BONUS: List their direct reports

SELECT 
    m.emp_id,
    m.emp_name AS manager,
    COUNT(e.emp_id) AS number_of_direct_reports,
    STRING_AGG(e.emp_name, ', ') AS direct_reports_list
FROM emp2 m
LEFT JOIN emp2 e ON m.emp_id = e.manager_id
GROUP BY m.emp_id, m.emp_name
ORDER BY number_of_direct_reports DESC;

-- Expected output:
-- emp_id | manager | number_of_direct_reports | direct_reports_list
-- 1      | Alice   | 3                        | Bob, Charlie, Frank
-- 2      | Bob     | 2                        | David, Eve
-- 6      | Frank   | 1                        | Grace
-- 3      | Charlie | 1                        | Henry
-- 4      | David   | 0                        | NULL
-- 5      | Eve     | 0                        | NULL
-- 7      | Grace   | 0                        | NULL
-- 8      | Henry   | 0                        | NULL

-- -----------------------------------------------
-- Q6: Department salary analysis
-- Problem: Which departments have employees earning more on avg than their managers?

SELECT 
    e.department,
    CAST(AVG(e.salary) AS INT) AS avg_employee_salary,
    CAST(AVG(m.salary) AS INT) AS avg_manager_salary,
    CAST(AVG(e.salary) - AVG(m.salary) AS INT) AS difference
FROM emp2 e
INNER JOIN emp2 m ON e.manager_id = m.emp_id
GROUP BY e.department
HAVING AVG(e.salary) > AVG(m.salary)
ORDER BY difference DESC;

-- ===============================================
-- LEVEL 3: ADVANCED (Complex Scenarios)
-- ===============================================

-- Q7: Find employees at the same hierarchical level
-- Problem: Employees with same manager = same level. Find all pairs.

SELECT 
    e1.emp_name AS employee1,
    e1.manager_id,
    e2.emp_name AS employee2,
    e1.salary + e2.salary AS combined_salary
FROM emp2 e1
INNER JOIN emp2 e2 ON e1.manager_id = e2.manager_id
WHERE e1.emp_id < e2.emp_id
ORDER BY e1.manager_id, e1.emp_name, e2.emp_name;

-- Expected output:
-- employee1 | manager_id | employee2 | combined_salary
-- Bob       | 1          | Charlie   | 105000
-- Bob       | 1          | Frank     | 102000
-- Charlie   | 1          | Frank     | 107000
-- David     | 2          | Eve       | 93000

-- -----------------------------------------------
-- Q8: Salary chain - salary progression from employee to top
-- Problem: Calculate salary gap to next manager level

SELECT 
    e.emp_id,
    e.emp_name,
    e.salary,
    m1.emp_name AS direct_manager,
    m1.salary AS manager_salary,
    (m1.salary - e.salary) AS salary_gap_to_manager,
    m2.emp_name AS managers_manager,
    m2.salary AS top_salary
FROM emp2 e
LEFT JOIN emp2 m1 ON e.manager_id = m1.emp_id
LEFT JOIN emp2 m2 ON m1.manager_id = m2.emp_id
ORDER BY e.salary DESC;

-- Expected output (sorted by employee salary desc):
-- emp_id | emp_name | salary | direct_manager | manager_salary | salary_gap... 
-- 1      | Alice    | 80000  | NULL           | NULL           | NULL
-- 3      | Charlie  | 55000  | Alice          | 80000          | 25000
-- 6      | Frank    | 52000  | Alice          | 80000          | 28000
-- 2      | Bob      | 50000  | Alice          | 80000          | 30000
-- 5      | Eve      | 48000  | Bob            | 50000          | 2000
-- 4      | David    | 45000  | Bob            | 50000          | 5000
-- 7      | Grace    | 42000  | Frank          | 52000          | 10000
-- 8      | Henry    | 40000  | Charlie        | 55000          | 15000

-- -----------------------------------------------
-- Q9: RECURSIVE - Find chain of command to top
-- Problem: Trace each employee to the CEO and show the path

WITH RECURSIVE hierarchy AS (
    -- Base case: All employees
    SELECT 
        emp_id,
        emp_name,
        manager_id,
        1 AS level,
        CAST(emp_id AS VARCHAR(MAX)) AS path
    FROM emp2
    
    UNION ALL
    
    -- Recursive case: Follow manager chain
    SELECT 
        h.emp_id,
        h.emp_name,
        e.manager_id,
        h.level + 1,
        h.path + ' → ' + CAST(e.emp_id AS VARCHAR(MAX))
    FROM hierarchy h
    INNER JOIN emp2 e ON h.manager_id = e.emp_id
    WHERE h.level < 10  -- Prevent infinite loops
)
SELECT 
    emp_id,
    emp_name,
    manager_id,
    level,
    path
FROM hierarchy
ORDER BY emp_id, level;

-- -----------------------------------------------
-- Q10: RECURSIVE - Full organizational structure
-- Problem: Show org chart with indentation and hierarchy

WITH RECURSIVE org_hierarchy AS (
    -- Level 0: CEO
    SELECT 
        emp_id,
        emp_name,
        manager_id,
        department,
        salary,
        0 AS org_level,
        CAST(emp_name AS VARCHAR(MAX)) AS hierarchy_path
    FROM emp2
    WHERE manager_id IS NULL
    
    UNION ALL
    
    -- Level 1+: Reports to managers above
    SELECT 
        e.emp_id,
        e.emp_name,
        e.manager_id,
        e.department,
        e.salary,
        oh.org_level + 1,
        oh.hierarchy_path + ' → ' + e.emp_name
    FROM emp2 e
    INNER JOIN org_hierarchy oh ON e.manager_id = oh.emp_id
)
SELECT 
    REPLICATE('  ', org_level) + emp_name AS emp_name,
    org_level,
    department,
    salary,
    hierarchy_path
FROM org_hierarchy
ORDER BY hierarchy_path;

-- Expected org structure:
-- emp_name              | org_level | department  | salary | hierarchy_path
-- Alice                 | 0         | Management  | 80000  | Alice
--   Bob                 | 1         | Sales       | 50000  | Alice → Bob
--     David             | 2         | IT          | 45000  | Alice → Bob → David
--     Eve               | 2         | IT          | 48000  | Alice → Bob → Eve
--   Charlie             | 1         | Sales       | 55000  | Alice → Charlie
--     Henry             | 2         | Sales       | 40000  | Alice → Charlie → Henry
--   Frank               | 1         | HR          | 52000  | Alice → Frank
--     Grace             | 2         | HR          | 42000  | Alice → Frank → Grace

-- ===============================================
-- CHALLENGE QUESTIONS (Try These!)
-- ===============================================

-- CHALLENGE 1: Find employees reporting to someone 2 levels below them
-- (i.e., someone else's manager who also has their own reports)

-- CHALLENGE 2: What's the maximum depth of the hierarchy?
-- (How many levels from CEO to deepest employee?)

-- CHALLENGE 3: Create a "compensation range" report showing:
-- For each department, min, max, and avg salary

-- CHALLENGE 4: Find employees who have the same salary as their manager
-- (Unusual scenario - show these anomalies)

-- CHALLENGE 5: Create a "supervisor summary" showing:
-- - Supervisor name
-- - Department
-- - Total compensation (supervisor + all direct reports combined)
-- - Average report salary
-- - Most paid direct report

-- ===============================================
-- KEY PATTERNS TO REMEMBER
-- ===============================================

-- Pattern 1: INNER JOIN vs LEFT JOIN
-- INNER JOIN: excludes CEO (no records where manager_id is null)
-- LEFT JOIN: includes CEO (shows all employees even with NULL managers)

-- Pattern 2: e1.emp_id < e2.emp_id
-- Prevents duplicate pairs: (A,B) and (B,A) are the same
-- Avoids self-joins: An employee shouldn't pair with themselves

-- Pattern 3: Recursive CTE
-- WITH RECURSIVE name AS (
--     BASE CASE (starting point)
--     UNION ALL
--     RECURSIVE CASE (how to get next rows)
-- )
-- Used for hierarchies, trees, and chains

-- ===============================================
-- NEXT: Practice until you can write these from memory!
-- ===============================================
