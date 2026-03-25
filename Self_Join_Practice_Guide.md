# SQL Self-Join: Practice Questions & Dataset

---

## **SAMPLE DATASET: Employee Table**

### **Table Schema:**
```sql
CREATE TABLE emp (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    department VARCHAR(30),
    manager_id INT,
    salary INT,
    hire_date DATE,
    FOREIGN KEY (manager_id) REFERENCES emp(emp_id)
);
```

### **Sample Data to Insert:**
```sql
INSERT INTO emp VALUES
(1, 'Alice', 'Management', NULL, 80000, '2015-01-10'),
(2, 'Bob', 'Sales', 1, 50000, '2018-03-15'),
(3, 'Charlie', 'Sales', 1, 55000, '2019-05-20'),
(4, 'David', 'IT', 2, 45000, '2020-07-22'),
(5, 'Eve', 'IT', 2, 48000, '2020-08-11'),
(6, 'Frank', 'HR', 1, 52000, '2017-11-05'),
(7, 'Grace', 'HR', 6, 42000, '2021-02-14'),
(8, 'Henry', 'Sales', 3, 40000, '2022-01-08');
```

### **Organizational Hierarchy:**
```
              Alice (1) - CEO
              /    |    \
            Bob   Frank  Charlie
           (2)     (6)      (3)
           /  \     |        |
         David Grace Henry  (none yet)
         (4)   (7)   (8)

Reporting Structure:
- Alice: CEO (no manager)
- Bob, Frank, Charlie: Report to Alice
- David, Eve: Report to Bob
- Grace: Reports to Frank
- Henry: Reports to Charlie
```

---

## **PRACTICE QUESTIONS**

### **LEVEL 1: BEGINNER (Basic Self-Join Concept)**

#### **Q1: Find all employees and their managers**
**Problem:** Display emp_name and their manager's name side by side.

**Solution:**
```sql
SELECT 
    e.emp_id,
    e.emp_name AS employee_name,
    m.emp_name AS manager_name
FROM emp e
LEFT JOIN emp m ON e.manager_id = m.emp_id
ORDER BY e.emp_id;
```

**Expected Output:**
```
emp_id  employee_name  manager_name
------  -------------  -----------
1       Alice          NULL
2       Bob            Alice
3       Charlie        Alice
4       David          Bob
5       Eve            Bob
6       Frank          Alice
7       Grace          Frank
8       Henry          Charlie
```

**Explanation:**
- `e` = Employee table (all employees)
- `m` = Manager table (their managers)
- `LEFT JOIN` → Include Alice (no manager)
- `e.manager_id = m.emp_id` → Link employee to their manager

---

#### **Q2: Find employees who earn more than their manager**
**Problem:** Show employees earning more than their direct manager.

**Solution:**
```sql
SELECT 
    e.emp_id,
    e.emp_name AS employee_name,
    e.salary AS employee_salary,
    m.emp_name AS manager_name,
    m.salary AS manager_salary,
    (e.salary - m.salary) AS salary_difference
FROM emp e
INNER JOIN emp m ON e.manager_id = m.emp_id
WHERE e.salary > m.salary
ORDER BY salary_difference DESC;
```

**Expected Output:**
```
emp_id  employee_name  employee_salary  manager_name  manager_salary  salary_difference
------  -------------- ---------------  -----------   ------          ------
3       Charlie        55000            Alice         80000           -25000
6       Frank          52000            Alice         80000           -28000
(No results - no employee earns more than their manager)
```

**Explanation:**
- Compares employee salary with their manager's salary
- `INNER JOIN` → Only includes those with managers
- `WHERE e.salary > m.salary` → Filter for higher earners

---

#### **Q3: Find all employees in the same department**
**Problem:** For each employee, show their peers (same department).

**Solution:**
```sql
SELECT 
    e1.emp_name AS employee1,
    e2.emp_name AS employee2,
    e1.department
FROM emp e1
INNER JOIN emp e2 ON e1.department = e2.department
WHERE e1.emp_id < e2.emp_id  -- Avoid duplicates and self-match
ORDER BY e1.department, e1.emp_name, e2.emp_name;
```

**Expected Output:**
```
employee1  employee2  department
---------  ---------  ----------
Bob        Charlie    Sales
Bob        Henry      Sales
Charlie    Henry      Sales
David      Eve        IT
Frank      Grace      HR
Alice      (none)     Management
```

**Explanation:**
- Joins table with itself on department
- `e1.emp_id < e2.emp_id` → Prevents duplicate pairs and self-joins
- Shows peers in same department

---

### **LEVEL 2: INTERMEDIATE (Complex Conditions)**

#### **Q4: Find employees and their manager's manager (2-level hierarchy)**
**Problem:** Show employee → manager → manager's manager.

**Solution:**
```sql
SELECT 
    e.emp_id,
    e.emp_name AS employee,
    m1.emp_name AS direct_manager,
    m2.emp_name AS managers_manager
FROM emp e
LEFT JOIN emp m1 ON e.manager_id = m1.emp_id
LEFT JOIN emp m2 ON m1.manager_id = m2.emp_id
ORDER BY e.emp_id;
```

**Expected Output:**
```
emp_id  employee   direct_manager  managers_manager
------  ---------  -----          -------
1       Alice      NULL           NULL
2       Bob        Alice          NULL
3       Charlie    Alice          NULL
4       David      Bob            Alice
5       Eve        Bob            Alice
6       Frank      Alice          NULL
7       Grace      Frank          Alice
8       Henry      Charlie        Alice
```

**Explanation:**
- First join: `e` to `m1` (get manager)
- Second join: `m1` to `m2` (get manager's manager)
- Multiple `LEFT JOINs` → Preserve all employees
- Shows 2-level hierarchy

---

#### **Q5: Find employees and count how many people report to them (direct reports)**
**Problem:** How many direct reports does each employee have?

**Solution:**
```sql
SELECT 
    m.emp_id,
    m.emp_name AS manager,
    COUNT(e.emp_id) AS number_of_direct_reports,
    STRING_AGG(e.emp_name, ', ') AS direct_reports_list
FROM emp m
LEFT JOIN emp e ON m.emp_id = e.manager_id
GROUP BY m.emp_id, m.emp_name
ORDER BY number_of_direct_reports DESC;
```

**Expected Output:**
```
emp_id  manager   number_of_direct_reports  direct_reports_list
------  -------   -----                     -------
1       Alice     3                         Bob, Charlie, Frank
2       Bob       2                         David, Eve
6       Frank     1                         Grace
3       Charlie   1                         Henry
4       David     0                         (null)
5       Eve       0                         (null)
7       Grace     0                         (null)
8       Henry     0                         (null)
```

**Explanation:**
- `LEFT JOIN` → Include managers with no reports
- `COUNT(e.emp_id)` → Count how many employees report to each manager
- `STRING_AGG()` → List all direct reports (SQL Server specific)
- `GROUP BY` → Aggregate by manager

---

#### **Q6: Find salary hierarchy - Departments where avg employee salary > avg manager salary**
**Problem:** Which departments have employees earning more on average than their managers?

**Solution:**
```sql
SELECT 
    e.department,
    CAST(AVG(e.salary) AS INT) AS avg_employee_salary,
    CAST(AVG(m.salary) AS INT) AS avg_manager_salary,
    CAST(AVG(e.salary) - AVG(m.salary) AS INT) AS difference
FROM emp e
INNER JOIN emp m ON e.manager_id = m.emp_id
GROUP BY e.department
HAVING AVG(e.salary) > AVG(m.salary)
ORDER BY difference DESC;
```

**Expected Output:**
```
department  avg_employee_salary  avg_manager_salary  difference
----------  ---                  ---                 ------
(No results - employees don't earn more than managers on average)
```

**Explanation:**
- Groups by department
- Compares average employee salary with average manager salary
- `HAVING` → Filter aggregated groups
- Shows pay anomalies

---

### **LEVEL 3: ADVANCED (Complex Scenarios)**

#### **Q7: Find employees who are at the same hierarchical level**
**Problem:** Employees with same manager = same level. Find all pairs.

**Solution:**
```sql
SELECT 
    e1.emp_name AS employee1,
    e1.manager_id,
    e2.emp_name AS employee2,
    e1.salary + e2.salary AS combined_salary
FROM emp e1
INNER JOIN emp e2 ON e1.manager_id = e2.manager_id
WHERE e1.emp_id < e2.emp_id
ORDER BY e1.manager_id, e1.emp_name, e2.emp_name;
```

**Expected Output:**
```
employee1  manager_id  employee2  combined_salary
---------  ---------   ---------  -------
Bob        1           Charlie    105000
Bob        1           Frank      102000
Charlie    1           Frank      107000
David      2           Eve        93000
```

**Explanation:**
- Joins on `manager_id` (same manager = same level)
- `e1.emp_id < e2.emp_id` → Avoids duplicates
- Shows peer relationships

---

#### **Q8: Find the salary chain - All employees and their salary gap to next manager level**
**Problem:** Calculate salary progression from employee to manager to manager's manager.

**Solution:**
```sql
SELECT 
    e.emp_id,
    e.emp_name,
    e.salary,
    m1.emp_name AS direct_manager,
    m1.salary AS manager_salary,
    (m1.salary - e.salary) AS salary_gap_to_manager,
    m2.emp_name AS managers_manager,
    m2.salary AS top_salary
FROM emp e
LEFT JOIN emp m1 ON e.manager_id = m1.emp_id
LEFT JOIN emp m2 ON m1.manager_id = m2.emp_id
ORDER BY e.salary DESC;
```

**Expected Output:**
```
emp_id  emp_name  salary  direct_manager  manager_salary  salary_gap_to_manager  managers_manager  top_salary
------  --------  ------  -----           ------          ------                 -----             ------
1       Alice     80000   NULL            NULL            NULL                   NULL              NULL
2       Bob       50000   Alice           80000           30000                  NULL              NULL
3       Charlie   55000   Alice           80000           25000                  NULL              NULL
6       Frank     52000   Alice           80000           28000                  NULL              NULL
5       Eve       48000   Bob             50000           2000                   Alice             80000
4       David     45000   Bob             50000           5000                   Alice             80000
8       Henry     40000   Charlie         55000           15000                  Alice             80000
7       Grace     42000   Frank           52000           10000                  Alice             80000
```

**Explanation:**
- Multiple joins to trace salary chain
- `salary_gap_to_manager` = progression between levels
- Shows compensation structure visually

---

#### **Q9: Find cycles or circular reporting (Data Quality Check)**
**Problem:** Detect if manager_id creates a circular reporting structure (A→B→C→A).

**Solution:**
```sql
WITH RECURSIVE hierarchy AS (
    -- Base case: All employees
    SELECT 
        emp_id,
        emp_name,
        manager_id,
        1 AS level,
        CAST(emp_id AS VARCHAR(MAX)) AS path
    FROM emp
    
    UNION ALL
    
    -- Recursive case: Follow manager chain
    SELECT 
        h.emp_id,
        h.emp_name,
        e.manager_id,
        h.level + 1,
        h.path + ' → ' + CAST(e.emp_id AS VARCHAR(MAX))
    FROM hierarchy h
    INNER JOIN emp e ON h.manager_id = e.emp_id
    WHERE h.level < 10  -- Prevent infinite loops
        AND h.path NOT LIKE '%' + CAST(e.emp_id AS VARCHAR) + '%'
)
SELECT *
FROM hierarchy
WHERE level > 5
ORDER BY emp_id, level;
```

**Expected Output:**
```
(No results - no circular reporting in this dataset)
```

**Explanation:**
- Recursive CTE to trace reporting chain to top
- Detects if employee eventually reports to themselves
- `path` shows the chain for debugging
- Data quality check for bad data

---

#### **Q10: Find organizational structure - Employees and their "span of control"**
**Problem:** Create org chart showing employees, managers, and depth in organization.

**Solution:**
```sql
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
    FROM emp
    WHERE manager_id IS NULL
    
    UNION ALL
    
    -- Level 1+: Everyone else
    SELECT 
        e.emp_id,
        e.emp_name,
        e.manager_id,
        e.department,
        e.salary,
        oh.org_level + 1,
        oh.hierarchy_path + ' → ' + e.emp_name
    FROM emp e
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
```

**Expected Output:**
```
emp_name              org_level  department   salary  hierarchy_path
--------              --------   ----------   ------  -------
Alice                 0          Management   80000   Alice
  Bob                 1          Sales        50000   Alice → Bob
    David             2          IT           45000   Alice → Bob → David
    Eve               2          IT           48000   Alice → Bob → Eve
  Charlie             1          Sales        55000   Alice → Charlie
    Henry             2          Sales        40000   Alice → Charlie → Henry
  Frank               1          HR           52000   Alice → Frank
    Grace             2          HR           42000   Alice → Frank → Grace
```

**Explanation:**
- Recursive CTE starting from CEO
- `org_level` shows depth (0=CEO, 1=direct reports, etc.)
- `REPLICATE()` indents hierarchy visually
- `hierarchy_path` shows full chain of command

---

## **BONUS: Interview Follow-up Questions**

### **Q1: What's the difference between INNER JOIN and LEFT JOIN in self-join context?**
- **INNER JOIN:** Only includes records with matching manager_id (excludes CEO)
- **LEFT JOIN:** Includes all employees even if manager_id is NULL (includes CEO)

### **Q2: Why use `e1.emp_id < e2.emp_id` when finding peers?**
- Avoids duplicate pairs: (A,B) and (B,A) are the same
- Prevents self-joins: An employee shouldn't match themselves

### **Q3: Can you optimize a self-join on a large table?**
- **Add indexes:** `CREATE INDEX idx_manager_id ON emp(manager_id);`
- **Use recursive CTE:** Better for hierarchy traversal
- **Denormalize:** Store manager name in emp table (if hierarchy doesn't change often)
- **Materialized view:** Pre-calculate relationships

### **Q4: What about cycles or multiple parents in the data?**
- **Cycles:** Use recursive CTE with depth limit and path tracking
- **Multiple parents:** Not possible in standard RDBMS (one manager_id per employee)
- **Multiple hierarchies:** Need additional hierarchy_id column

---

## **Quick Reference: Self-Join Patterns**

| Pattern | Use Case | Example |
|---------|----------|---------|
| `INNER JOIN` | Exclude nulls (no NULL managers) | Employees with managers only |
| `LEFT JOIN` | Include nulls (include CEO) | All employees including CEO |
| `pair join` (e1 < e2) | Find relationships | Peers at same level |
| `Recursive CTE` | Multi-level hierarchy | Report to CEO chain |
| `GROUP BY + Aggregate` | Count/sum relationships | Direct reports count |

---

**Practice these questions and you'll master self-joins!** 🚀
