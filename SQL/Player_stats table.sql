CREATE TABLE player_stats (
    player_name VARCHAR(100) PRIMARY KEY,

    matches_played INT,
    innings INT,

    total_runs INT,
    total_wickets INT,

    strike_rate DECIMAL(10,2),
    batting_average DECIMAL(10,2),

    economy DECIMAL(10,2),
    bowling_average DECIMAL(10,2),

    highest_score INT,
    highest_score_opponent VARCHAR(100),

    best_bowling VARCHAR(20),
    best_bowling_opponent VARCHAR(100),

    hundreds INT,
    fifties INT,

    teams_played TEXT
);


INSERT INTO player_stats(player_name)

SELECT DISTINCT batter
FROM deliveries

UNION

SELECT DISTINCT bowler
FROM deliveries;

select count(*) from player_stats;

SELECT *
FROM player_stats
LIMIT 20;

SET SQL_SAFE_UPDATES = 0;


UPDATE player_stats ps
JOIN (
    SELECT
        player_name,
        COUNT(DISTINCT match_id) AS matches_played
    FROM (
        SELECT batter AS player_name, match_id
        FROM deliveries

        UNION

        SELECT bowler AS player_name, match_id
        FROM deliveries
    ) t
    GROUP BY player_name
) x
ON ps.player_name = x.player_name
SET ps.matches_played = x.matches_played;


SELECT player_name, matches_played
FROM player_stats
ORDER BY matches_played DESC
LIMIT 10;


UPDATE player_stats ps
JOIN (
    SELECT
        batter AS player_name,
        COUNT(DISTINCT CONCAT(match_id,'-',inning)) AS innings
    FROM deliveries
    GROUP BY batter
) x
ON ps.player_name = x.player_name
SET ps.innings = x.innings;


SELECT player_name, innings
FROM player_stats
ORDER BY innings DESC
LIMIT 10;


UPDATE player_stats ps
JOIN (
    SELECT
        batter AS player_name,
        SUM(batsman_runs) AS total_runs
    FROM deliveries
    GROUP BY batter
) x
ON ps.player_name = x.player_name
SET ps.total_runs = x.total_runs;


SELECT player_name, total_runs
FROM player_stats
ORDER BY total_runs DESC
LIMIT 10;


UPDATE player_stats ps
JOIN (
    SELECT
        bowler AS player_name,
        COUNT(*) AS total_wickets
    FROM deliveries
    WHERE dismissal_kind IN (
        'bowled',
        'caught',
        'lbw',
        'stumped',
        'caught and bowled',
        'hit wicket'
    )
    GROUP BY bowler
) x
ON ps.player_name = x.player_name
SET ps.total_wickets = x.total_wickets;


SELECT player_name, total_wickets
FROM player_stats
ORDER BY total_wickets DESC
LIMIT 10;


UPDATE player_stats ps
JOIN (
    SELECT
        batter AS player_name,
        ROUND((SUM(batsman_runs) * 100.0) / COUNT(*), 2) AS strike_rate
    FROM deliveries
    GROUP BY batter
) x
ON ps.player_name = x.player_name
SET ps.strike_rate = x.strike_rate;


SELECT player_name, strike_rate
FROM player_stats
ORDER BY strike_rate DESC
LIMIT 10;

UPDATE player_stats ps
JOIN (
    SELECT
        batter AS player_name,
        ROUND(
            SUM(batsman_runs) /
            NULLIF(
                SUM(
                    CASE
                        WHEN player_dismissed = batter THEN 1
                        ELSE 0
                    END
                ),
            0),
        2) AS batting_average
    FROM deliveries
    GROUP BY batter
) x
ON ps.player_name = x.player_name
SET ps.batting_average = x.batting_average;


SELECT player_name, batting_average
FROM player_stats
ORDER BY batting_average DESC
LIMIT 10;

UPDATE player_stats ps
JOIN (
    SELECT
        bowler AS player_name,
        ROUND(
            SUM(total_runs) /
            (SUM(
                CASE
                    WHEN extras_type IS NULL
                      OR extras_type IN ('legbyes','byes')
                    THEN 1
                    ELSE 0
                END
            ) / 6.0),
        2) AS economy
    FROM deliveries
    GROUP BY bowler
) x
ON ps.player_name = x.player_name
SET ps.economy = x.economy;


SELECT player_name, economy
FROM player_stats
WHERE economy IS NOT NULL
ORDER BY economy
LIMIT 10;

UPDATE player_stats ps
JOIN (
    SELECT
        bowler,
        ROUND(
            SUM(total_runs) /
            NULLIF(
                COUNT(
                    CASE
                        WHEN dismissal_kind IN (
                            'bowled',
                            'caught',
                            'lbw',
                            'stumped',
                            'caught and bowled',
                            'hit wicket'
                        )
                        THEN 1
                    END
                ),
                0
            ),
            2
        ) AS bowling_average
    FROM deliveries
    GROUP BY bowler
) x
ON ps.player_name = x.bowler
SET ps.bowling_average = x.bowling_average;


SELECT player_name, total_wickets, bowling_average
FROM player_stats
ORDER BY bowling_average
LIMIT 20;


SELECT
    COUNT(*) AS TotalPlayers,
    COUNT(total_wickets) AS PlayersWithWickets,
    COUNT(*) - COUNT(total_wickets) AS PlayersWithoutWickets
FROM player_stats;


SELECT player_name, total_wickets
FROM player_stats
WHERE total_wickets IS NOT NULL
ORDER BY total_wickets DESC
LIMIT 10;



UPDATE player_stats ps
JOIN (
    SELECT
        batter AS player_name,
        MAX(runs) AS highest_score
    FROM (
        SELECT
            batter,
            match_id,
            SUM(batsman_runs) AS runs
        FROM deliveries
        GROUP BY batter, match_id
    ) t
    GROUP BY batter
) x
ON ps.player_name = x.player_name
SET ps.highest_score = x.highest_score;

UPDATE player_stats ps
JOIN (
SELECT batter AS player_name,
       bowling_team AS highest_score_opponent
FROM (
SELECT
batter,
bowling_team,
match_id,
SUM(batsman_runs) runs,
ROW_NUMBER() OVER(
PARTITION BY batter
ORDER BY SUM(batsman_runs) DESC
) rn
FROM deliveries
GROUP BY batter,bowling_team,match_id
)t
WHERE rn=1
)x
ON ps.player_name=x.player_name
SET ps.highest_score_opponent=x.highest_score_opponent;


UPDATE player_stats ps
JOIN (
SELECT
batter player_name,
COUNT(*) hundreds
FROM(
SELECT
batter,
match_id,
SUM(batsman_runs) runs
FROM deliveries
GROUP BY batter,match_id
HAVING runs>=100
)t
GROUP BY batter
)x
ON ps.player_name=x.player_name
SET ps.hundreds=x.hundreds;

UPDATE player_stats ps
JOIN (
SELECT
batter player_name,
COUNT(*) fifties
FROM(
SELECT
batter,
match_id,
SUM(batsman_runs) runs
FROM deliveries
GROUP BY batter,match_id
HAVING runs BETWEEN 50 AND 99
)t
GROUP BY batter
)x
ON ps.player_name=x.player_name
SET ps.fifties=x.fifties;


UPDATE player_stats ps
JOIN (
    SELECT
        batter AS player_name,
        GROUP_CONCAT(
            DISTINCT batting_team
            ORDER BY batting_team
            SEPARATOR '\n'
        ) AS teams
    FROM deliveries
    GROUP BY batter
) x
ON ps.player_name = x.player_name
SET ps.teams_played = x.teams;


UPDATE player_stats ps
JOIN (
SELECT
    bowler AS player_name,
    CONCAT(wickets,'/',runs_conceded) AS best_bowling
FROM(
SELECT
    bowler,
    batting_team,
    match_id,

    COUNT(
        CASE
            WHEN dismissal_kind IN
            ('bowled',
             'caught',
             'lbw',
             'stumped',
             'caught and bowled',
             'hit wicket')
            THEN 1
        END
    ) wickets,

    SUM(
        CASE
            WHEN extras_type IN ('byes','legbyes')
            THEN batsman_runs
            ELSE total_runs
        END
    ) runs_conceded,

    ROW_NUMBER() OVER(
        PARTITION BY bowler
        ORDER BY
        COUNT(
            CASE
                WHEN dismissal_kind IN
                ('bowled',
                 'caught',
                 'lbw',
                 'stumped',
                 'caught and bowled',
                 'hit wicket')
                THEN 1
            END
        ) DESC,

        SUM(
            CASE
                WHEN extras_type IN ('byes','legbyes')
                THEN batsman_runs
                ELSE total_runs
            END
        ) ASC
    ) rn

FROM deliveries

GROUP BY
bowler,
batting_team,
match_id

)t

WHERE rn=1

)x

ON ps.player_name=x.player_name

SET ps.best_bowling=x.best_bowling;



UPDATE player_stats ps
JOIN (
SELECT
    bowler AS player_name,
    batting_team AS best_bowling_opponent
FROM(
SELECT
    bowler,
    batting_team,
    match_id,

    COUNT(
        CASE
            WHEN dismissal_kind IN
            ('bowled',
             'caught',
             'lbw',
             'stumped',
             'caught and bowled',
             'hit wicket')
            THEN 1
        END
    ) wickets,

    SUM(
        CASE
            WHEN extras_type IN ('byes','legbyes')
            THEN batsman_runs
            ELSE total_runs
        END
    ) runs_conceded,

    ROW_NUMBER() OVER(
        PARTITION BY bowler
        ORDER BY
        COUNT(
            CASE
                WHEN dismissal_kind IN
                ('bowled',
                 'caught',
                 'lbw',
                 'stumped',
                 'caught and bowled',
                 'hit wicket')
                THEN 1
            END
        ) DESC,

        SUM(
            CASE
                WHEN extras_type IN ('byes','legbyes')
                THEN batsman_runs
                ELSE total_runs
            END
        ) ASC
    ) rn

FROM deliveries

GROUP BY
bowler,
batting_team,
match_id

)t

WHERE rn=1

)x

ON ps.player_name=x.player_name

SET ps.best_bowling_opponent=x.best_bowling_opponent;


SELECT
player_name,
best_bowling,
best_bowling_opponent
FROM player_stats
ORDER BY
CAST(SUBSTRING_INDEX(best_bowling,'/',1) AS UNSIGNED) DESC,
CAST(SUBSTRING_INDEX(best_bowling,'/',-1) AS UNSIGNED) ASC
LIMIT 20;


SELECT *
FROM player_stats
LIMIT 20;

SELECT *
FROM player_stats
WHERE player_name = 'KL Rahul';


SELECT
player_name,
matches_played,
innings,
total_runs,
total_wickets,
strike_rate,
batting_average,
economy,
bowling_average,
highest_score,
hundreds,
fifties,
teams_played
FROM player_stats
WHERE player_name='V Kohli';