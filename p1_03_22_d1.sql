WITH ranked AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (ORDER BY salary DESC) AS rn
    FROM employees
)
SELECT *
FROM ranked
WHERE rn = 2

