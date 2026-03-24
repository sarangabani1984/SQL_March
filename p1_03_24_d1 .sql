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


SELECT * from icc_world_cup


-- CTE to combine both Team_1 and Team_2 perspectives
-- Each row represents one match for one team with a win indicator
WITH CTE AS (
    -- Get matches where Team_1 appears
    SELECT 
        Team_1 AS Team,
        CASE WHEN Team_1 = Winner THEN 1 ELSE 0 END AS win_flag
    FROM icc_world_cup
    
    UNION ALL
    
    -- Get matches where Team_2 appears
    -- UNION ALL preserves all records (no duplicate removal needed)
    SELECT 
        Team_2 AS Team,
        CASE WHEN Team_2 = Winner THEN 1 ELSE 0 END AS win_flag
    FROM icc_world_cup
)

-- Aggregate statistics for each team
SELECT 
    Team, 
    COUNT(1) AS Match_Played,                          -- Total matches played
    SUM(win_flag) AS total_wins,                       -- Sum of 1s = total wins
    COUNT(1) - SUM(win_flag) AS total_losses,         -- Matches - Wins = Losses
    SUM(win_flag) * 2 AS total_points                 -- Points earned (2 points per win, standard cricket scoring)
FROM CTE 
GROUP BY Team
ORDER BY total_points DESC, total_wins DESC, total_losses ASC;  -- Rank by points, then wins, then losses