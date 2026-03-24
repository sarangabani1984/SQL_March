# ICC World Cup SQL - Complete Interview Guide

## **Problem Statement**
Calculate match statistics (total matches, wins, losses) for each team in cricket matches, ordered by most wins and fewest losses.

---

## **Original Query**
```sql
create table icc_world_cup
(
Team_1 Varchar(20),
Team_2 Varchar(20),
Winner Varchar(20)
);
INSERT INTO icc_world_cup values('India','SL','India');
INSERT INTO icc_world_cup values('SL','Aus','Aus');
INSERT INTO icc_world_cup values('SA','Eng','Eng');
INSERT INTO icc_world_cup values('Eng','NZ','NZ');
INSERT INTO icc_world_cup values('Aus','India','India');

with team_wins as (
select Team_1 as Team,
case when Team_1 = Winner then 1 else 0 end as win_flag
from icc_world_cup
union all
select Team_2 as Team,
case when team_2 = Winner then 1 else 0 end as win_flag
from icc_world_cup)
select Team, count(1) as total_matches, 
sum(win_flag) as total_wins, count(1) - sum(win_flag) as total_losses
from team_wins
group by Team order by total_wins desc, total_losses asc;
```

**Output:**
```
Team     total_matches  total_wins  total_losses
India    2              2           0
Aus      2              1           1
NZ       1              1           0
Eng      2              1           1
SL       2              0           2
SA       1              0           1
```

---

## **Interview Questions & Answers**

### **Level 1: Understanding the Query (Beginner)**

**Q1: What is the purpose of this query? What does it calculate?**
- **Answer:** The query calculates statistics for each cricket team:
  - How many total matches each team played
  - How many of those matches they won
  - How many matches they lost
- It consolidates data because teams appear in either `Team_1` or `Team_2` columns

**Q2: Why are there two `SELECT` statements with `UNION ALL`? Why not just one?**
- **Answer:** Because each team can appear in either `Team_1` or `Team_2` column. 
  - First SELECT gets all matches where the team was Team_1
  - Second SELECT gets all matches where the team was Team_2
  - UNION ALL combines both views without removing duplicates
  - Without both selects, we'd miss matches where the team appears as Team_2

**Q3: What does the `CASE` statement do here? Why is it needed?**
- **Answer:** 
  - Creates a `win_flag` column with value 1 if the team won, 0 if they lost
  - Needed to count wins later using `SUM(win_flag)`
  - Makes it easy to calculate losses: `COUNT(*) - SUM(win_flag)`
  - Example: For `('India','SL','India')`, Team_1='India' and Winner='India', so `CASE` returns 1

**Q4: What would happen if we removed the `UNION ALL`?**
- **Answer:** We'd only get statistics for teams appearing in `Team_1`, missing all matches where teams only appeared as `Team_2`
- Teams like "NZ" and "SA" (who only appear as Team_2) wouldn't be in the results

---

### **Level 2: Analysis & Optimization (Intermediate)**

**Q5: Why does the query select from both `Team_1` and `Team_2`? What problem does this solve?**
- **Answer:**
  - **Problem:** The table stores matches with teams in different columns, creating data asymmetry
  - **Solution:** By selecting from both columns separately and unioning them, we get a complete view of each team
  - Each team's perspective is captured: whether they were first or second team doesn't matter

**Q6: Why is `count(1) - sum(win_flag)` used to calculate losses instead of a separate CASE statement?**
- **Answer:**
  - **Efficiency:** Avoids writing another CASE statement; mathematically derived from existing values
  - **Correctness:** `total_matches - total_wins = total_losses` (assuming no draws/ties)
  - **Readability:** More concise than a separate CASE for each loss
  - **Alternative:** `SUM(CASE WHEN Team != Winner THEN 1 ELSE 0 END)` would work but is verbose

**Q7: What does the final `ORDER BY total_wins desc, total_losses asc` do?**
- **Answer:**
  - Orders teams by wins (highest first): `total_wins DESC`
  - For teams with same wins, order by losses (fewest first): `total_losses ASC`
  - Result: Best-performing teams appear at the top
  - India (2 wins, 0 losses) → Aus (1 win, 1 loss) → Eng (1 win, 1 loss) → etc.

**Q8: How would you find the team with the most wins? How would you find the team with the best win-loss ratio?**
- **Answer:**

```sql
-- Team with most wins
SELECT TOP 1 Team, total_wins FROM (
    -- [original query]
) AS stats
ORDER BY total_wins DESC;

-- Team with best win-loss ratio
SELECT TOP 1 Team, total_wins, total_losses, 
       CAST(total_wins AS FLOAT) / total_matches as win_ratio
FROM (
    -- [original query]
) AS stats
ORDER BY win_ratio DESC;
```

---

### **Level 3: SQL Concepts (Advanced)**

**Q9: What is a CTE (Common Table Expression)? Why use `WITH` clause instead of a subquery?**
- **Answer:**
  - **CTE:** Named temporary result set defined using `WITH` keyword
  - **Benefits over subquery:**
    - More readable and maintainable
    - Can reference itself (recursive CTEs)
    - Easier to test individual parts
    - Can reference the CTE multiple times
  - Here, `team_wins` is a CTE that makes the final SELECT cleaner

**Q10: Can you optimize this query? What if the table had 1 million rows?**
- **Answer:**

```sql
-- OPTIMIZATION 1: Using GROUP BY with aggregation directly
SELECT 
    COALESCE(NULLIF(Team_1, Team_2), Team_1) as Team,
    COUNT(*) as total_matches,
    SUM(CASE WHEN Team_1 = Winner THEN 1 ELSE 0 END) +
    SUM(CASE WHEN Team_2 = Winner THEN 1 ELSE 0 END) as total_wins
FROM icc_world_cup
GROUP BY COALESCE(NULLIF(Team_1, Team_2), Team_1);
-- Note: This doesn't work well with UNION structure, CTE is better

-- OPTIMIZATION 2: Add INDEX for large datasets
CREATE INDEX idx_team_1 ON icc_world_cup(Team_1);
CREATE INDEX idx_team_2 ON icc_world_cup(Team_2);
CREATE INDEX idx_winner ON icc_world_cup(Winner);

-- OPTIMIZATION 3: Use window functions (SQL Server 2012+)
WITH team_wins AS (
  SELECT Team_1 AS Team, CASE WHEN Team_1 = Winner THEN 1 ELSE 0 END AS win_flag FROM icc_world_cup
  UNION ALL
  SELECT Team_2 AS Team, CASE WHEN Team_2 = Winner THEN 1 ELSE 0 END AS win_flag FROM icc_world_cup
)
SELECT Team, COUNT(*) as total_matches, SUM(win_flag) as total_wins, COUNT(*) - SUM(win_flag) as total_losses
FROM team_wins
GROUP BY Team
ORDER BY total_wins DESC, total_losses ASC;
```

**Q11: How would you modify this query to only show teams with more than 2 matches?**
- **Answer:** Use `HAVING` clause (filters after GROUP BY)

```sql
with team_wins as (
    -- [same CTE as before]
)
select Team, count(1) as total_matches, 
       sum(win_flag) as total_wins, count(1) - sum(win_flag) as total_losses
from team_wins
group by Team 
HAVING COUNT(1) > 2  -- Add this line
order by total_wins desc, total_losses asc;
```

**Q12: What if you needed to rank teams by wins? How would you add that?**
- **Answer:** Use `ROW_NUMBER()` or `RANK()` window function

```sql
with team_wins as (
    -- [same CTE as before]
),
team_stats as (
    select Team, count(1) as total_matches, 
           sum(win_flag) as total_wins, count(1) - sum(win_flag) as total_losses
    from team_wins
    group by Team
)
select Team, total_matches, total_wins, total_losses,
       ROW_NUMBER() OVER (ORDER BY total_wins DESC, total_losses ASC) AS rank
from team_stats
order by rank;
```

**Q13: Explain the difference between `UNION` and `UNION ALL` in this context.**
- **Answer:**
  - **UNION:** Removes duplicate rows from combined results
  - **UNION ALL:** Keeps all rows including duplicates
  - **Here:** We use `UNION ALL` because we want to preserve each team's unique match records (no duplicates expected)
  - If we used `UNION`, it would only remove rows that are identical in ALL columns, which doesn't happen here
  - **Performance:** `UNION ALL` is faster (no duplicate check overhead)

---

### **Level 4: Real-World Scenarios (Advanced)**

**Q14: How would you handle ties (draws) in cricket matches if the Winner could be NULL?**
- **Answer:**

```sql
with team_wins as (
select Team_1 as Team,
case when Team_1 = Winner then 1 else 0 end as win_flag,
case when Winner IS NULL then 1 else 0 end as draw_flag
from icc_world_cup
union all
select Team_2 as Team,
case when team_2 = Winner then 1 else 0 end as win_flag,
case when Winner IS NULL then 1 else 0 end as draw_flag
from icc_world_cup)
select Team, 
count(1) as total_matches, 
sum(win_flag) as total_wins, 
sum(draw_flag) as total_draws,
count(1) - sum(win_flag) - sum(draw_flag) as total_losses
from team_wins
group by Team 
order by total_wins desc, total_draws desc, total_losses asc;
```

**Q15: How would you calculate win percentage for each team?**
- **Answer:**

```sql
with team_wins as (
    -- [same CTE as before]
)
select Team, 
       count(1) as total_matches, 
       sum(win_flag) as total_wins, 
       count(1) - sum(win_flag) as total_losses,
       CAST(sum(win_flag) AS FLOAT) / COUNT(1) * 100 AS win_percentage
from team_wins
group by Team 
order by win_percentage desc, total_wins desc;
```

**Q16: If you needed to add a "home" column showing which is the home team, how would the query change?**
- **Answer:** Would need to modify table structure first:

```sql
-- Modified table
CREATE TABLE icc_world_cup (
    Team_1 VARCHAR(20),
    Team_2 VARCHAR(20),
    Winner VARCHAR(20),
    Home_Team VARCHAR(20)  -- New column
);

-- Modified query to respect home/away
WITH team_wins AS (
    SELECT Team_1 as Team,
           'Home' as location,
           CASE WHEN Team_1 = Winner THEN 1 ELSE 0 END as win_flag
    FROM icc_world_cup
    UNION ALL
    SELECT Team_2 as Team,
           'Away' as location,
           CASE WHEN Team_2 = Winner THEN 1 ELSE 0 END as win_flag
    FROM icc_world_cup
)
SELECT Team, location,
       COUNT(1) as total_matches,
       SUM(win_flag) as total_wins,
       COUNT(1) - SUM(win_flag) as total_losses
FROM team_wins
GROUP BY Team, location
ORDER BY total_wins DESC, total_losses ASC;
```

---

## **Alternative Solutions**

### **Solution 2: Using Subqueries instead of CTE**
```sql
select Team, count(1) as total_matches, 
sum(win_flag) as total_wins, count(1) - sum(win_flag) as total_losses
from (
    select Team_1 as Team, case when Team_1 = Winner then 1 else 0 end as win_flag
    from icc_world_cup
    union all
    select Team_2 as Team, case when Team_2 = Winner then 1 else 0 end as win_flag
    from icc_world_cup
) as team_wins
group by Team 
order by total_wins desc, total_losses asc;
```

### **Solution 3: Using CROSS APPLY (SQL Server specific)**
```sql
SELECT DISTINCT t.Team,
       (SELECT COUNT(*) FROM icc_world_cup WHERE Team_1 = t.Team OR Team_2 = t.Team) as total_matches,
       (SELECT COUNT(*) FROM icc_world_cup WHERE Winner = t.Team) as total_wins,
       (SELECT COUNT(*) FROM icc_world_cup WHERE (Team_1 = t.Team OR Team_2 = t.Team) AND Winner != t.Team) as total_losses
FROM (
    SELECT DISTINCT Team_1 as Team FROM icc_world_cup
    UNION
    SELECT DISTINCT Team_2 FROM icc_world_cup
) t
ORDER BY total_wins DESC, total_losses ASC;
```

### **Solution 4: Using UNPIVOT (SQL Server 2005+)**
```sql
WITH unpivoted AS (
    SELECT Team_1 as Team, Winner FROM icc_world_cup
    UNION ALL
    SELECT Team_2, Winner FROM icc_world_cup
)
SELECT Team,
       COUNT(*) as total_matches,
       SUM(CASE WHEN Team = Winner THEN 1 ELSE 0 END) as total_wins,
       SUM(CASE WHEN Team != Winner THEN 1 ELSE 0 END) as total_losses
FROM unpivoted
GROUP BY Team
ORDER BY total_wins DESC, total_losses ASC;
```

---

## **Key Concepts to Remember**

| Concept | Key Takeaway |
|---------|--------------|
| **Data Normalization Problem** | Two teams in separate columns requires UNION to combine perspectives |
| **CTE vs Subquery** | Both work; CTE is more readable for complex queries |
| **Aggregation** | COUNT(*) for total, SUM() for binary flags, CASE for logic |
| **Ordering** | PRIMARY sort by wins (DESC), secondary by losses (ASC) |
| **UNION vs UNION ALL** | ALL preserves duplicates; essential when no true duplicates exist |
| **Window Functions** | ROW_NUMBER(), RANK(), DENSE_RANK() for ranking without GROUP BY |
| **Performance** | Indexes on Team_1, Team_2, Winner help with large datasets |

---

## **Follow-up Questions to Ask**

1. How would you test this query to ensure correctness?
2. What edge cases might break this query? (empty table, NULL values, ties)
3. How would you handle a scenario with 100M+ matches?
4. What if winners could be drawn matches (Winner = 'DRAW' or NULL)?
5. How would you track head-to-head records between specific teams?

---

**Created:** March 24, 2026 | **Purpose:** SQL Interview Preparation
