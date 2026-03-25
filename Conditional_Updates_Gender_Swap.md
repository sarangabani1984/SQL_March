# SQL Conditional Updates: Gender Value Swap Challenge

---

## **Problem Statement**

**Scenario:** A data ingestion error swapped gender values in the Orders table.
- 'Male' was recorded as 'Female'
- 'Female' was recorded as 'Male'

**Task:** Write a single UPDATE statement to swap these values back to their correct state **WITHOUT using a temporary table**.

---

## **Sample Dataset**

### **Table Schema:**
```sql
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerName VARCHAR(100),
    CustomerGender VARCHAR(20),
    OrderAmount DECIMAL(10,2),
    OrderDate DATE
);
```

### **Sample Data (BEFORE UPDATE):**
```sql
INSERT INTO Orders VALUES
(1, 'John Doe', 'Female', 1500.00, '2024-01-15'),
(2, 'Jane Smith', 'Male', 2500.00, '2024-01-16'),
(3, 'Mike Johnson', 'Female', 1800.00, '2024-01-17'),
(4, 'Sarah Williams', 'Male', 3000.00, '2024-01-18'),
(5, 'Robert Brown', 'Female', 2200.00, '2024-01-19'),
(6, 'Emma Davis', 'Male', 1900.00, '2024-01-20'),
(7, 'James Wilson', 'Female', 2100.00, '2024-01-21'),
(8, 'Olivia Martinez', 'Male', 2700.00, '2024-01-22');
```

### **Current Data (SWAPPED):**
```
OrderID  CustomerName        CustomerGender  OrderAmount  OrderDate
-------  ----------------    -----           ---------    ----------
1        John Doe            Female          1500.00      2024-01-15
2        Jane Smith          Male            2500.00      2024-01-16
3        Mike Johnson        Female          1800.00      2024-01-17
4        Sarah Williams      Male            3000.00      2024-01-18
5        Robert Brown        Female          2200.00      2024-01-19
6        Emma Davis          Male            1900.00      2024-01-20
7        James Wilson        Female          2100.00      2024-01-21
8        Olivia Martinez     Male            2700.00      2024-01-22
```

---

## **SOLUTIONS**

### **SOLUTION 1: Using CASE Statement (RECOMMENDED ⭐)**

#### **Code:**
```sql
-- APPROACH 1: Standard CASE logic
UPDATE Orders
SET CustomerGender = CASE 
                        WHEN CustomerGender = 'Male' THEN 'Female'
                        WHEN CustomerGender = 'Female' THEN 'Male'
                        ELSE CustomerGender
                     END;
```

#### **Explanation:**
- **CASE statement** evaluates each row
  - If Male → Change to Female
  - If Female → Change to Male
  - Else → Keep as is
- **Simple and readable**
- **Works in ALL SQL databases**
- **ELSE clause protects against NULL or unexpected values**

#### **Pros:**
✅ Easy to understand
✅ Handles edge cases (NULL, other values)
✅ Widely supported (MySQL, SQL Server, PostgreSQL, Oracle)
✅ No temporary data needed

#### **Cons:**
❌ Slightly verbose
❌ Requires reading each value twice

---

### **SOLUTION 2: Using a Placeholder/Temporary Variable (CLEVER TRICK)**

#### **Code (SQL Server / T-SQL):**
```sql
DECLARE @placeholder VARCHAR(20) = '###TEMP###';

UPDATE Orders
SET CustomerGender = CASE 
                        WHEN CustomerGender = 'Male' THEN 'Female'
                        WHEN CustomerGender = 'Female' THEN @placeholder
                     END;

UPDATE Orders
SET CustomerGender = 'Male'
WHERE CustomerGender = @placeholder;
```

#### **Why This Works:**
1. First update: Male → Female, Female → ###TEMP###
2. Second update: ###TEMP### → Male
3. No actual temporary table needed!

#### **Single Statement Version (With CTE - SQL Server):**
```sql
WITH SwapValues AS (
    SELECT 
        OrderID,
        CASE 
            WHEN CustomerGender = 'Male' THEN 'Female'
            WHEN CustomerGender = 'Female' THEN 'Male'
            ELSE CustomerGender
        END AS NewGender
    FROM Orders
)
UPDATE Orders
SET CustomerGender = SwapValues.NewGender
FROM SwapValues
WHERE Orders.OrderID = SwapValues.OrderID;
```

#### **Pros:**
✅ Works even if you need exact placeholder control
✅ Shows advanced SQL knowledge

#### **Cons:**
❌ More complex
❌ Requires multiple operations (breaking "single statement" rule)
❌ Placeholder could theoretically exist in data

---

### **SOLUTION 3: Using NULLIF + IIF (SQL Server Specific)**

#### **Code:**
```sql
UPDATE Orders
SET CustomerGender = IIF(
    CustomerGender = 'Male', 
    'Female', 
    IIF(CustomerGender = 'Female', 'Male', CustomerGender)
);
```

#### **How It Works:**
- `IIF()` = Immediate If (SQL Server specific)
- Nested IIF for multiple conditions
- Same logic as CASE, different syntax

#### **Pros:**
✅ Compact syntax
✅ Single statement

#### **Cons:**
❌ SQL Server only (not portable)
❌ Less readable than CASE
❌ Harder to extend for more values

---

### **SOLUTION 4: Using String Replace (TRICKY - Not Recommended)**

#### **Code:**
```sql
UPDATE Orders
SET CustomerGender = REPLACE(
    REPLACE(CustomerGender, 'Male', '###TEMP###'),
    'Female',
    'Male'
), 
CustomerGender = REPLACE(CustomerGender, '###TEMP###', 'Female');
```

#### **How It Works:**
- First REPLACE: Male → ###TEMP###
- Second REPLACE: Female → Male
- Third REPLACE: ###TEMP### → Female

#### **Pros:**
✅ Demonstrates string manipulation knowledge

#### **Cons:**
❌ Risky if data contains placeholder
❌ Less readable
❌ Harder to maintain
❌ Performance issues on large datasets

---

### **SOLUTION 5: Dynamic SQL Update (Advanced)**

#### **Code (SQL Server):**
```sql
DECLARE @sql NVARCHAR(MAX);

SET @sql = 'UPDATE Orders
SET CustomerGender = CASE
    WHEN CustomerGender = ' + CHAR(39) + 'Male' + CHAR(39) + ' THEN ' + CHAR(39) + 'Female' + CHAR(39) + '
    WHEN CustomerGender = ' + CHAR(39) + 'Female' + CHAR(39) + ' THEN ' + CHAR(39) + 'Male' + CHAR(39) + '
    ELSE CustomerGender
END';

EXEC sp_executesql @sql;
```

#### **Why Use:**
- Demonstrates advanced SQL knowledge
- Useful for truly dynamic scenarios

#### **Cons:**
❌ SQL injection risk if built with unsanitized input
❌ Harder to debug
❌ Not necessary for this problem

---

## **VERIFICATION QUERY**

After running the update, verify the swap was successful:

```sql
-- View results
SELECT * FROM Orders;

-- Count by gender
SELECT CustomerGender, COUNT(*) AS count
FROM Orders
GROUP BY CustomerGender;

-- Expected output:
-- Female: 4 (Jane, Sarah, Emma, Olivia)
-- Male: 4 (John, Mike, Robert, James)
```

---

## **PERFORMANCE COMPARISON**

| Solution | Simplicity | Performance | Portability | Recommended |
|----------|-----------|-------------|------------|------------|
| CASE Statement | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ✅ YES |
| CTE + Join | ⭐⭐ | ⭐⭐ | ⭐⭐⭐ | ✅ YES |
| IIF Nested | ⭐⭐⭐ | ⭐⭐⭐ | ⭐ | ❌ Limited |
| REPLACE Chain | ⭐ | ⭐⭐ | ⭐⭐⭐ | ❌ Not Safe |
| Dynamic SQL | ⭐ | ⭐⭐ | ⭐⭐ | ❌ Overkill |

---

## **BEST PRACTICE SOLUTION**

### **Recommended: CASE with WHERE Clause (Optimized)**

```sql
-- Most efficient: Only update rows that need changing
UPDATE Orders
SET CustomerGender = CASE 
                        WHEN CustomerGender = 'Male' THEN 'Female'
                        WHEN CustomerGender = 'Female' THEN 'Male'
                     END
WHERE CustomerGender IN ('Male', 'Female');
```

**Why this is best:**
- ✅ Clear and readable
- ✅ Efficient (WHERE clause limits scope)
- ✅ Only touches necessary rows
- ✅ Handles edge cases with ELSE
- ✅ Industry standard approach

---

## **INTERVIEW FOLLOW-UP QUESTIONS & ANSWERS**

### **Q1: Why can't you use a simple `SET CustomerGender = 'Female' WHERE CustomerGender = 'Male'` approach?**

**Answer:**
```
If you run:
UPDATE Orders SET CustomerGender = 'Female' WHERE CustomerGender = 'Male';

Then run:
UPDATE Orders SET CustomerGender = 'Male' WHERE CustomerGender = 'Female';

Problem: The first update already changed all 'Male' to 'Female', 
so the second statement won't find any 'Female' rows to update!
Result: All values end up as 'Male' (incorrect swap)
```

---

### **Q2: What if there are NULL values in the gender column?**

**Answer:**
```sql
-- Use ISNULL or CASE to handle NULLs
UPDATE Orders
SET CustomerGender = CASE 
                        WHEN CustomerGender = 'Male' THEN 'Female'
                        WHEN CustomerGender = 'Female' THEN 'Male'
                        ELSE CustomerGender  -- Preserves NULL and other values
                     END;
```

---

### **Q3: What if you have more than 2 values to swap? (e.g., Male, Female, Unknown)**

**Answer:**
```sql
UPDATE Orders
SET CustomerGender = CASE 
                        WHEN CustomerGender = 'Male' THEN 'Female'
                        WHEN CustomerGender = 'Female' THEN 'Unknown'
                        WHEN CustomerGender = 'Unknown' THEN 'Male'
                        ELSE CustomerGender
                     END;

-- Or use a UNION-style mapping table:
UPDATE o
SET CustomerGender = m.NewValue
FROM Orders o
INNER JOIN (
    SELECT 'Male' AS OldValue, 'Female' AS NewValue
    UNION ALL
    SELECT 'Female', 'Unknown'
    UNION ALL
    SELECT 'Unknown', 'Male'
) m ON o.CustomerGender = m.OldValue;
```

---

### **Q4: What's the difference between UPDATE with CASE vs CTE approach?**

**Answer:**

| Aspect | CASE Statement | CTE + JOIN |
|--------|-------------|----------|
| **Simplicity** | More direct | Slightly more complex |
| **Performance** | Single pass | Single pass (similar) |
| **Readability** | Very clear | Clear, but more lines |
| **Maintainability** | Easier | Easier with complex logic |
| **When to use** | Simple swaps | Complex logic or multiple sources |

---

### **Q5: How would you do this with a CHECK constraint or validation?**

**Answer:**
```sql
-- Add constraint to prevent invalid values
ALTER TABLE Orders
ADD CONSTRAINT chk_gender CHECK (CustomerGender IN ('Male', 'Female'));

-- This ensures future data is correct
-- But doesn't affect the swapped data - still need UPDATE statement
```

---

### **Q6: What if you needed to log/audit the changes?**

**Answer:**
```sql
-- Create audit table first
CREATE TABLE Orders_Audit (
    AuditID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT,
    OldGender VARCHAR(20),
    NewGender VARCHAR(20),
    ChangeDate DATETIME DEFAULT GETDATE()
);

-- Update with logging
UPDATE Orders
SET CustomerGender = CASE 
                        WHEN CustomerGender = 'Male' THEN 'Female'
                        WHEN CustomerGender = 'Female' THEN 'Male'
                        ELSE CustomerGender
                     END
OUTPUT inserted.OrderID, deleted.CustomerGender, inserted.CustomerGender INTO Orders_Audit(OrderID, OldGender, NewGender)
WHERE CustomerGender IN ('Male', 'Female');
```

---

### **Q7: Performance on large tables - Any optimization tips?**

**Answer:**
```sql
-- 1. Add WHERE clause to limit scope
WHERE CustomerGender IN ('Male', 'Female');

-- 2. Use batch updates for very large tables
UPDATE Orders
SET CustomerGender = CASE 
                        WHEN CustomerGender = 'Male' THEN 'Female'
                        WHEN CustomerGender = 'Female' THEN 'Male'
                        ELSE CustomerGender
                     END
WHERE OrderID >= 1 AND OrderID < 1000000
  AND CustomerGender IN ('Male', 'Female');

-- 3. Index on CustomerGender helps
CREATE INDEX idx_gender ON Orders(CustomerGender);

-- 4. Use minimal logging if possible
ALTER INDEX ALL ON Orders DISABLE; -- Do updates
ALTER INDEX ALL ON Orders REBUILD; -- Rebuild indexes
```

---

### **Q8: What about transaction safety and rollback?**

**Answer:**
```sql
-- Wrap in transaction for safety
BEGIN TRANSACTION;

UPDATE Orders
SET CustomerGender = CASE 
                        WHEN CustomerGender = 'Male' THEN 'Female'
                        WHEN CustomerGender = 'Female' THEN 'Male'
                        ELSE CustomerGender
                     END
WHERE CustomerGender IN ('Male', 'Female');

-- Verify results
SELECT COUNT(*) FROM Orders WHERE CustomerGender = 'Male';
SELECT COUNT(*) FROM Orders WHERE CustomerGender = 'Female';

-- If counts look good, commit
COMMIT;

-- If something wrong, can rollback
-- ROLLBACK;
```

---

## **PRACTICE EXERCISES**

### **Exercise 1: Swap status values**
```
Update table with Status: 'Active' <-> 'Inactive'
Bonus: Handle 'Pending' status (should remain unchanged)
```

### **Exercise 2: Multiple conditions**
```
Swap based on multiple criteria:
- If Gender='Male' AND Age > 30 → Change to 'Senior_Male'
- If Gender='Female' AND Age > 30 → Change to 'Senior_Female'
```

### **Exercise 3: Conditional with JOIN**
```
Swap gender only for customers who placed orders in specific date range
```

---

## **Common Mistakes to Avoid**

| ❌ Mistake | ✅ Solution |
|-----------|----------|
| Two separate UPDATE statements | Use CASE in one statement |
| Forgetting ELSE clause | Always add ELSE to preserve unexpected values |
| Not using WHERE clause | Add WHERE to limit scope for efficiency |
| Assuming no NULL values | Test with NULL values |
| Updating without backup | CREATE backup table first |
| Not verifying results | Always run verification query |

---

## **Summary**

**Best Answer for Interview:**

```sql
UPDATE Orders
SET CustomerGender = CASE 
                        WHEN CustomerGender = 'Male' THEN 'Female'
                        WHEN CustomerGender = 'Female' THEN 'Male'
                        ELSE CustomerGender
                     END
WHERE CustomerGender IN ('Male', 'Female');
```

**Why this is perfect:**
- ✅ Single UPDATE statement (meets requirement)
- ✅ No temporary table (meets requirement)
- ✅ Clear and readable
- ✅ Handles edge cases (ELSE clause)
- ✅ Efficient (WHERE clause)
- ✅ Standard SQL approach
- ✅ Easy to explain in interview

---

**Created:** March 24, 2026 | **Purpose:** SQL Interview Preparation
