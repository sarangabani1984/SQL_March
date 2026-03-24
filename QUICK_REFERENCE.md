# SQL Interview Questions - Quick Reference Cheat Sheet

## Quick Links to 19 Questions

| # | Question | Approach 1 | Approach 2 | Difficulty |
|---|----------|-----------|-----------|-----------|
| 1 | 2nd Highest Salary | Subquery + MAX | CTE + ROW_NUMBER | ⭐⭐ |
| 2 | Department Wise Highest | GROUP BY + MAX | CTE + ROW_NUMBER | ⭐⭐ |
| 3 | Alternate Records | ROW_NUMBER + MOD | CTE Method | ⭐⭐ |
| 4 | Display Duplicates | GROUP BY HAVING | CTE with Details | ⭐⭐ |
| 5 | Pattern Matching | LIKE Wildcard | PATINDEX | ⭐ |
| 6 | Pattern Searching 2 | LIKE OR | CHARINDEX | ⭐ |
| 7 | Display Nth Row | OFFSET FETCH | ROW_NUMBER | ⭐⭐ |
| 8 | UNION vs UNION ALL | UNION | UNION ALL | ⭐ |
| 9 | Inner Join | Explicit JOIN | WHERE Clause | ⭐ |
| 10 | Self Join | LEFT JOIN + Alias | WHERE Clause | ⭐⭐⭐ |
| 11 | Left Join | Basic | With Aggregation | ⭐ |
| 12 | Right Join | Basic | With Aggregation | ⭐ |
| 13 | Full Join | FULL OUTER | UNION Method | ⭐⭐ |
| 14 | Cross Join | CROSS JOIN | Comma Syntax | ⭐⭐ |
| 15 | First/Last N Rows | TOP | OFFSET | ⭐ |
| 16 | Nth Highest Salary | DENSE_RANK CTE | ROW_NUMBER OFFSET | ⭐⭐⭐ |
| 17 | INTERSECT | INTERSECT | INNER JOIN | ⭐⭐ |
| 18 | EXCEPT/MINUS | EXCEPT | LEFT JOIN NULL | ⭐⭐ |
| 19 | First Normal Form | Normalized Table | Query Normalized | ⭐⭐ |

---

## Window Functions Quick Reference

```sql
-- ROW_NUMBER() - Sequential numbering, resets with PARTITION
ROW_NUMBER() OVER (PARTITION BY DeptID ORDER BY Salary DESC)
-- Result: 1, 2, 3, 4, 5...

-- RANK() - Ranking with gaps on ties
RANK() OVER (ORDER BY Salary DESC)
-- Result: 1, 2, 2, 4, 5...

-- DENSE_RANK() - Ranking without gaps
DENSE_RANK() OVER (ORDER BY Salary DESC)
-- Result: 1, 2, 2, 3, 4...

-- LAG() and LEAD() - Access previous/next row
LAG(Salary) OVER (ORDER BY HireDate)
LEAD(Salary) OVER (ORDER BY HireDate)

-- SUM/AVG with Window
SUM(Salary) OVER (PARTITION BY DeptID ORDER BY HireDate)
```

---

## Join Types at a Glance

```
INNER JOIN:    ██████████████  (Both tables match only)
LEFT JOIN:     ██████████████████████  (All LEFT + matching RIGHT)
RIGHT JOIN:    ██████████████████████  (All RIGHT + matching LEFT)
FULL OUTER:    ██████████████████████████████  (All both tables)
CROSS JOIN:    ███████████████████████████████████  (Cartesian product)
```

---

## Common SQL Patterns

### Finding Duplicates
```sql
SELECT Column, COUNT(*) cnt
FROM Table
GROUP BY Column
HAVING COUNT(*) > 1;
```

### Finding Nth Value
```sql
WITH Ranked AS (
    SELECT DISTINCT Value,
           DENSE_RANK() OVER (ORDER BY Value DESC) rnk
    FROM Table
)
SELECT Value FROM Ranked WHERE rnk = N;
```

### Top N per Group
```sql
WITH Ranked AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY GroupID ORDER BY Value DESC) rn
    FROM Table
)
SELECT * FROM Ranked WHERE rn <= N;
```

### Handling NULLs
```sql
COALESCE(Column1, Column2, 'Default') AS Result
ISNULL(Column, 'Default') AS Result
```

---

## Query Optimization Tips

| Issue | Solution |
|-------|----------|
| Slow JOIN | Index the ON columns |
| Slow GROUP BY | Index GROUP BY columns |
| Large UNION | Use UNION ALL if duplicates OK |
| Slow LIKE | Use wildcards at end, not start |
| Subquery slow | Convert to JOIN/CTE |

---

## Common Interview Questions Formats

### "What's the difference between X and Y?"
- UNION vs UNION ALL
- ROW_NUMBER vs RANK vs DENSE_RANK
- INNER vs LEFT JOIN
- WHERE vs HAVING
- GROUP BY vs PARTITION BY

### "Write a query to..."
- Find duplicates
- Calculate running totals
- Rank/number rows
- Find top N per group
- Join multiple tables

### "Optimize this query"
- Look for missing indexes
- Check for unnecessary JOINs
- Verify GROUP BY efficiency
- Consider window functions vs subqueries

---

## Sample Data Quick Lookup

### Employees Table
```
ID   Name     Salary  DeptID  ManagerID
1    John     50000   1       NULL
2    Sarah    60000   1       1
3    Mike     55000   2       1
4    Emily    65000   2       3
5    David    60000   3       NULL
6    Lisa     70000   3       5
7    James    55000   1       1
8    Jennifer 75000   2       3
9    Robert   60000   1       1
10   Patricia 80000   3       5
11   Michael  58000   2       3
12   Linda    62000   1       1
```

### Departments Table
```
ID   Name        Location
1    Sales       New York
2    Marketing   Los Angeles
3    IT          Chicago
```

---

## Syntax Reminders

### CASE Statement
```sql
SELECT 
    EmployeeName,
    CASE 
        WHEN Salary > 70000 THEN 'High'
        WHEN Salary > 55000 THEN 'Medium'
        ELSE 'Low'
    END AS SalaryCategory
FROM Employees;
```

### String Functions
```sql
UPPER(Column)           -- Convert to uppercase
LOWER(Column)           -- Convert to lowercase
SUBSTRING(Column, 1, 3) -- Extract substring
LEN(Column)             -- Length
LTRIM(Column)           -- Remove left spaces
RTRIM(Column)           -- Remove right spaces
```

### Date Functions
```sql
GETDATE()               -- Current datetime
DATEADD(DAY, 5, Date)   -- Add days
DATEDIFF(DAY, Date1, Date2) -- Difference
CONVERT(VARCHAR, Date, 101) -- Format date
```

### Aggregate Functions
```sql
COUNT(*)        -- All rows
COUNT(Column)   -- Non-NULL rows
SUM(Column)     -- Sum
AVG(Column)     -- Average
MAX(Column)     -- Maximum
MIN(Column)     -- Minimum
```

---

## Most Asked Combinations

**Self Join + Aggregation:**
```sql
SELECT m.ManagerName, COUNT(e.EmployeeID) as TeamSize
FROM Employees e
LEFT JOIN Employees m ON e.ManagerID = m.EmployeeID
GROUP BY m.ManagerName;
```

**Multiple JOINs:**
```sql
SELECT e.Name, d.Name, COUNT(o.OrderID) as Orders
FROM Employees e
JOIN Departments d ON e.DeptID = d.ID
LEFT JOIN Orders o ON e.ID = o.EmployeeID
GROUP BY e.Name, d.Name;
```

**CTE with Window Function:**
```sql
WITH Ranked AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY DeptID ORDER BY Salary DESC) rn
    FROM Employees
)
SELECT * FROM Ranked WHERE rn <= 3;
```

---

## Practice Checklist

- [ ] Run all 19 queries with sample data
- [ ] Modify each query (change N value, filter criteria)
- [ ] Explain output for each approach
- [ ] Understand performance differences
- [ ] Practice writing from scratch (not copy-paste)
- [ ] Explain when to use each approach
- [ ] Answer "why" questions about choices
- [ ] Handle edge cases (NULLs, empty sets, ties)
- [ ] Write queries with proper formatting
- [ ] Use meaningful table aliases

---

## Red Flags Interviewers Look For

❌ Not knowing difference between JOINs
❌ Using UNION instead of UNION ALL unnecessarily
❌ Not using window functions when appropriate
❌ Slow queries that could be optimized
❌ Not handling NULL values
❌ Incorrect GROUP BY usage
❌ Missing field in GROUP BY (SQL non-aggregate error)
❌ Not understanding set operations
❌ Inefficient subqueries
❌ Not normalizing data properly

---

## Green Flags Interviewers Look For

✅ Clean, readable query formatting
✅ Using modern SQL features (CTEs, window functions)
✅ Explaining multiple approaches
✅ Performance consideration awareness
✅ Proper alias usage
✅ Understanding of query execution
✅ Edge case handling
✅ Database normalization knowledge
✅ Index awareness
✅ Clear explanation of logic

---

## Practice Command

To practice all 19 questions:

1. Open SQL Server Management Studio
2. Create the database and tables using provided SQL
3. Run each query one by one
4. Modify queries to understand variations
5. Explain output to yourself
6. Hide the query and rewrite from memory
7. Time yourself (Interview constraint)

Good luck! You've got this! 🚀
