-- ============================================================================
-- QUESTION 5: Time-Series & Growth (Hard)
-- Problem: Find products with "Consistent Momentum"
-- Find all ProductIDs where current month sales > previous month sales
-- Constraint: Use window function (LAG)
-- ============================================================================

-- Step 1: CREATE TABLE
-- ============================================================================
CREATE TABLE Monthly_Sales (
    ProductID INT,
    SalesMonth DATE,
    TotalSales DECIMAL(10, 2),
    PRIMARY KEY (ProductID, SalesMonth)
);

-- Step 2: INSERT SAMPLE DATA
-- ============================================================================
-- Sample data with multiple products across 6 months (Jan-Jun 2024)
-- This shows various patterns: growth, decline, spikes

INSERT INTO Monthly_Sales (ProductID, SalesMonth, TotalSales) VALUES
-- Product 1: Consistent growth
(1, '2024-01-01', 5000.00),
(1, '2024-02-01', 6000.00),  -- Higher than Jan ✓
(1, '2024-03-01', 7500.00),  -- Higher than Feb ✓
(1, '2024-04-01', 8000.00),  -- Higher than Mar ✓
(1, '2024-05-01', 9500.00),  -- Higher than Apr ✓
(1, '2024-06-01', 9000.00),  -- Lower than May ✗

-- Product 2: Up and down volatility
(2, '2024-01-01', 8000.00),
(2, '2024-02-01', 7500.00),  -- Lower than Jan ✗
(2, '2024-03-01', 9000.00),  -- Higher than Feb ✓
(2, '2024-04-01', 8500.00),  -- Lower than Mar ✗
(2, '2024-05-01', 10000.00), -- Higher than Apr ✓
(2, '2024-06-01', 11000.00), -- Higher than May ✓

-- Product 3: Steady decline
(3, '2024-01-01', 12000.00),
(3, '2024-02-01', 11000.00), -- Lower than Jan ✗
(3, '2024-03-01', 10000.00), -- Lower than Feb ✗
(3, '2024-04-01', 9500.00),  -- Lower than Mar ✗
(3, '2024-05-01', 8000.00),  -- Lower than Apr ✗
(3, '2024-06-01', 7500.00),  -- Lower than May ✗

-- Product 4: Recent momentum
(4, '2024-01-01', 4000.00),
(4, '2024-02-01', 3500.00),  -- Lower than Jan ✗
(4, '2024-03-01', 3000.00),  -- Lower than Feb ✗
(4, '2024-04-01', 5000.00),  -- Higher than Mar ✓
(4, '2024-05-01', 6500.00),  -- Higher than Apr ✓
(4, '2024-06-01', 7000.00),  -- Higher than May ✓

-- Product 5: Flat then growth
(5, '2024-01-01', 5000.00),
(5, '2024-02-01', 5000.00),  -- Equal (not higher) ✗
(5, '2024-03-01', 5000.00),  -- Equal ✗
(5, '2024-04-01', 6000.00),  -- Higher than Mar ✓
(5, '2024-05-01', 7000.00),  -- Higher than Apr ✓
(5, '2024-06-01', 8000.00);  -- Higher than May ✓

-- ============================================================================
-- SOLUTION: Find products with "Consistent Momentum"
-- ============================================================================
-- Using LAG() window function to get previous month's sales
-- Then compare current month > previous month

SELECT 
    ProductID,
    SalesMonth,
    TotalSales,
    PREVIOUS_MONTH_SALES,
    CASE 
        WHEN TotalSales > PREVIOUS_MONTH_SALES THEN 'YES - Momentum ✓'
        ELSE 'NO - Decline/Flat'
    END AS Has_Growth
FROM (
    SELECT 
        ProductID,
        SalesMonth,
        TotalSales,
        LAG(TotalSales) OVER (PARTITION BY ProductID ORDER BY SalesMonth) AS PREVIOUS_MONTH_SALES
    FROM Monthly_Sales
) AS sales_with_previous
WHERE PREVIOUS_MONTH_SALES IS NOT NULL  -- Exclude first month (no previous data)
ORDER BY ProductID, SalesMonth;

-- ============================================================================
-- ALTERNATIVE: Get only ProductIDs with momentum in current month
-- ============================================================================
-- Identify which products had growth in their latest month

WITH sales_with_lag AS (
    SELECT 
        ProductID,
        SalesMonth,
        TotalSales,
        LAG(TotalSales) OVER (PARTITION BY ProductID ORDER BY SalesMonth) AS PREVIOUS_MONTH_SALES
    FROM Monthly_Sales
)
SELECT 
    ProductID,
    SalesMonth,
    TotalSales,
    PREVIOUS_MONTH_SALES,
    CAST((TotalSales - PREVIOUS_MONTH_SALES) AS DECIMAL(10, 2)) AS Growth_Amount,
    CAST(((TotalSales - PREVIOUS_MONTH_SALES) / PREVIOUS_MONTH_SALES * 100) AS DECIMAL(5, 2)) AS Growth_Percentage
FROM sales_with_lag
WHERE TotalSales > PREVIOUS_MONTH_SALES
ORDER BY ProductID, SalesMonth;

-- ============================================================================
-- ADVANCED: Products with consecutive growth momentum
-- ============================================================================
-- Get products that maintained growth for multiple consecutive months

WITH sales_with_lag AS (
    SELECT 
        ProductID,
        SalesMonth,
        TotalSales,
        LAG(TotalSales) OVER (PARTITION BY ProductID ORDER BY SalesMonth) AS PREVIOUS_MONTH_SALES,
        CASE 
            WHEN TotalSales > LAG(TotalSales) OVER (PARTITION BY ProductID ORDER BY SalesMonth) 
            THEN 1 
            ELSE 0 
        END AS Is_Growth_Month
    FROM Monthly_Sales
),
growth_streaks AS (
    SELECT 
        ProductID,
        SalesMonth,
        TotalSales,
        PREVIOUS_MONTH_SALES,
        Is_Growth_Month,
        SUM(CASE WHEN Is_Growth_Month = 0 THEN 1 ELSE 0 END) 
            OVER (PARTITION BY ProductID ORDER BY SalesMonth) AS streak_group
    FROM sales_with_lag
    WHERE PREVIOUS_MONTH_SALES IS NOT NULL
)
SELECT 
    ProductID,
    streak_group,
    COUNT(*) AS consecutive_growth_months,
    MIN(SalesMonth) AS streak_start,
    MAX(SalesMonth) AS streak_end,
    MIN(TotalSales) AS streak_min_sales,
    MAX(TotalSales) AS streak_max_sales
FROM growth_streaks
WHERE Is_Growth_Month = 1
GROUP BY ProductID, streak_group
HAVING COUNT(*) >= 2  -- At least 2 consecutive growth months
ORDER BY ProductID, consecutive_growth_months DESC;
