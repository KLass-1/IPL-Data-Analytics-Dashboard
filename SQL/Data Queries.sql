-- Relationship Verification:-
SELECT COUNT(*)
FROM deliveries d
LEFT JOIN matches m
ON d.match_id = m.match_id
WHERE m.match_id IS NULL;


-- Creating Indexes:-
CREATE INDEX idx_match_id
ON deliveries(match_id);

CREATE INDEX idx_batter
ON deliveries(batter);

CREATE INDEX idx_bowler
ON deliveries(bowler);

CREATE INDEX idx_season
ON matches(season);

CREATE INDEX idx_winner
ON matches(winner);

SELECT DISTINCT match_type
FROM matches;

-- Season Dashboard analysis Page:-
-- Season Winner:- 
SELECT
    season,
    winner AS IPL_Winner
FROM matches
WHERE match_type = 'Final'
ORDER BY season;


-- Runnerup team:
SELECT
    season,
    winner,
    CASE
        WHEN winner = team1 THEN team2
        ELSE team1
    END AS Runner_Up
FROM matches
WHERE match_type='Final'
ORDER BY season;

-- Total matches:
SELECT
    season,
    COUNT(*) AS Total_Matches
FROM matches
GROUP BY season
ORDER BY season;

-- Total Runs:
SELECT
    m.season,
    SUM(d.total_runs) AS Total_Runs
FROM deliveries d
JOIN matches m
ON d.match_id = m.match_id
GROUP BY m.season
ORDER BY m.season;


-- Total Sixes:
SELECT
    m.season,
    COUNT(*) AS Total_Sixes
FROM deliveries d
JOIN matches m
ON d.match_id = m.match_id
WHERE d.batsman_runs = 6
GROUP BY m.season
ORDER BY m.season;


-- Total Fours:
SELECT
    m.season,
    COUNT(*) AS Total_Fours
FROM deliveries d
JOIN matches m
ON d.match_id = m.match_id
WHERE d.batsman_runs = 4
GROUP BY m.season
ORDER BY m.season;

-- Total Wickets:
SELECT
    m.season,
    COUNT(*) AS Total_Wickets
FROM deliveries d
JOIN matches m
ON d.match_id = m.match_id
WHERE d.player_dismissed IS NOT NULL
GROUP BY m.season
ORDER BY m.season;

-- Number of Matches:
SELECT
    season,
    COUNT(*) AS Matches
FROM matches
GROUP BY season
ORDER BY season;

-- Number of Teams:
SELECT
    season,
    COUNT(DISTINCT team1) AS Teams
FROM matches
GROUP BY season;

-- Orange Cap Winner:
WITH OrangeCap AS
(
SELECT
    m.season,
    d.batter,
    SUM(d.batsman_runs) AS Runs,
    ROW_NUMBER() OVER(PARTITION BY m.season
    ORDER BY SUM(d.batsman_runs) DESC) AS rn
FROM deliveries d
JOIN matches m
ON d.match_id=m.match_id
GROUP BY m.season,d.batter
)

SELECT season,batter,Runs
FROM OrangeCap
WHERE rn=1;

-- Purple Cap Winner:
WITH PurpleCap AS
(
SELECT
m.season,
d.bowler,
COUNT(*) AS Wickets,
ROW_NUMBER() OVER
(
PARTITION BY m.season
ORDER BY COUNT(*) DESC
) rn
FROM deliveries d
JOIN matches m
ON d.match_id=m.match_id
WHERE dismissal_kind IS NOT NULL
AND dismissal_kind NOT IN
(
'run out',
'retired hurt',
'obstructing the field'
)
GROUP BY
m.season,
d.bowler
)
SELECT
season,
bowler,
Wickets
FROM PurpleCap
WHERE rn=1;

-- Best Stike-rate (Minimum 200 Balls Faced):
WITH StrikeRate AS
(
SELECT
m.season,
d.batter,
SUM(batsman_runs) AS Runs,
COUNT(*) AS Balls,
ROUND
(
SUM(batsman_runs)*100.0/COUNT(*),
2
) Strike_Rate,
ROW_NUMBER() OVER
(
PARTITION BY m.season
ORDER BY
SUM(batsman_runs)*100.0/COUNT(*) DESC
) rn
FROM deliveries d
JOIN matches m
ON d.match_id=m.match_id
WHERE extras_type<>'wides'
OR extras_type IS NULL
GROUP BY
m.season,
d.batter
HAVING COUNT(*)>=200
)
SELECT
season,
batter,
Runs,
Balls,
Strike_Rate
FROM StrikeRate
WHERE rn=1;


-- Best Economy (Minimum 20 Overs Bowled):
WITH Economy AS
(
SELECT

m.season,

d.bowler,

SUM(
CASE
WHEN extras_type IN ('byes','legbyes')
THEN batsman_runs
ELSE total_runs
END
) AS Runs_Conceded,

COUNT(
CASE
WHEN extras_type NOT IN ('wides','noballs')
OR extras_type IS NULL
THEN 1
END
) AS Legal_Balls,

ROUND(

SUM(
CASE
WHEN extras_type IN ('byes','legbyes')
THEN batsman_runs
ELSE total_runs
END
)

*6.0/

COUNT(
CASE
WHEN extras_type NOT IN ('wides','noballs')
OR extras_type IS NULL
THEN 1
END
)

,2) AS Economy,

ROW_NUMBER() OVER(

PARTITION BY m.season

ORDER BY

SUM(
CASE
WHEN extras_type IN ('byes','legbyes')
THEN batsman_runs
ELSE total_runs
END
)

*6.0/

COUNT(
CASE
WHEN extras_type NOT IN ('wides','noballs')
OR extras_type IS NULL
THEN 1
END
)

) rn

FROM deliveries d
JOIN matches m
ON d.match_id=m.match_id

GROUP BY
m.season,
d.bowler

HAVING COUNT(
CASE
WHEN extras_type NOT IN ('wides','noballs','byes','legbyes','penalty')
OR extras_type IS NULL
THEN 1
END
)>=100
)

SELECT
season,
bowler,
Runs_Conceded,
Legal_Balls,
Economy
FROM Economy
WHERE rn=1;

-- Best Batting Average:
WITH AverageTable AS
(
SELECT
m.season,
d.batter,
SUM(batsman_runs) Runs,
COUNT(player_dismissed) Outs,
ROUND
(
SUM(batsman_runs)
/COUNT(player_dismissed),
2
) Batting_Average,
ROW_NUMBER() OVER
(
PARTITION BY m.season
ORDER BY
SUM(batsman_runs)
/COUNT(player_dismissed) DESC
) rn
FROM deliveries d
JOIN matches m
ON d.match_id=m.match_id
WHERE dismissal_kind NOT IN
(
'retired hurt'
)
OR dismissal_kind IS NULL
GROUP BY
m.season,
d.batter
HAVING COUNT(player_dismissed)>=10
)
SELECT
season,
batter,
Runs,
Outs,
Batting_Average
FROM AverageTable
WHERE rn=1;

-- Total Centuries:
WITH InningsRuns AS
(
SELECT
m.season,
d.match_id,
d.batter,
SUM(batsman_runs) Runs
FROM deliveries d
JOIN matches m
ON d.match_id=m.match_id
GROUP BY
m.season,
d.match_id,
d.batter
)
SELECT
season,
COUNT(*) Total_Centuries
FROM InningsRuns
WHERE Runs>=100
GROUP BY season;

-- Total Half-Centuries:
WITH InningsRuns AS
(
SELECT
m.season,
d.match_id,
d.batter,
SUM(batsman_runs) Runs
FROM deliveries d
JOIN matches m
ON d.match_id=m.match_id
GROUP BY
m.season,
d.match_id,
d.batter
)
SELECT
season,
COUNT(*) Total_Half_Centuries
FROM InningsRuns
WHERE Runs BETWEEN 50 AND 99
GROUP BY season;


-- Total Teams:
SELECT
    season,
    COUNT(DISTINCT team_name) AS Teams
FROM
(
    SELECT season, team1 AS team_name
    FROM matches

    UNION

    SELECT season, team2
    FROM matches
) t
GROUP BY season
ORDER BY season;


-- Batting Analysis page:-

-- Total Runs:
SELECT SUM(batsman_runs) AS Total_Runs
FROM deliveries;

-- Total Fours:
SELECT COUNT(*) AS Total_Fours
FROM deliveries
WHERE batsman_runs = 4;

-- Total Sixes:
SELECT COUNT(*) AS Total_Sixes
FROM deliveries
WHERE batsman_runs = 6;

-- Total Centuries:
WITH Player_Innings AS
(
SELECT
match_id,
batter,
SUM(batsman_runs) AS Runs
FROM deliveries
GROUP BY match_id,batter
)

SELECT COUNT(*) AS Total_Centuries
FROM Player_Innings
WHERE Runs>=100;

-- Total Half-Centuries:
WITH Player_Innings AS
(
SELECT
match_id,
batter,
SUM(batsman_runs) AS Runs
FROM deliveries
GROUP BY match_id,batter
)

SELECT COUNT(*) AS Total_Half_Centuries
FROM Player_Innings
WHERE Runs BETWEEN 50 AND 99;


-- Highest individual Score:
SELECT
batter,
SUM(batsman_runs) AS Highest_Score
FROM deliveries
GROUP BY match_id,batter
ORDER BY Highest_Score DESC
LIMIT 1;

-- Top 10 run scorers:
SELECT
batter,
SUM(batsman_runs) AS Runs
FROM deliveries
GROUP BY batter
ORDER BY Runs DESC
LIMIT 10;

-- Top 10 Strike rate:
SELECT
batter,
COUNT(*) AS Balls,
SUM(batsman_runs) AS Runs,
ROUND(
SUM(batsman_runs)*100.0
/
COUNT(*),
2
) Strike_Rate
FROM deliveries
GROUP BY batter
HAVING COUNT(*)>=500
ORDER BY Strike_Rate DESC
LIMIT 10;

-- Top 10 Most Sixes:
SELECT
batter,
COUNT(*) AS Sixes
FROM deliveries
WHERE batsman_runs=6
GROUP BY batter
ORDER BY Sixes DESC
LIMIT 10;

-- Top 10 Most Fours:
SELECT
batter,
COUNT(*) AS Fours
FROM deliveries
WHERE batsman_runs=4
GROUP BY batter
ORDER BY Fours DESC
LIMIT 10;

-- Top 10 Batting Average:
WITH Runs AS
(
    SELECT
        batter,
        SUM(batsman_runs) AS Runs
    FROM deliveries
    GROUP BY batter
),

Outs AS
(
    SELECT
        player_dismissed AS batter,
        COUNT(*) AS Outs
    FROM deliveries
    WHERE player_dismissed IS NOT NULL
      AND dismissal_kind <> 'retired hurt'
    GROUP BY player_dismissed
)

SELECT
    r.batter,
    r.Runs,
    o.Outs,
    ROUND(r.Runs / o.Outs, 2) AS Batting_Average
FROM Runs r
JOIN Outs o
ON r.batter = o.batter
WHERE o.Outs >= 10
ORDER BY Batting_Average DESC
LIMIT 10;

-- Runs Distribution by Teams:
SELECT
batting_team,
SUM(batsman_runs) AS Runs
FROM deliveries
GROUP BY batting_team
ORDER BY Runs DESC;

-- Top 5 Players with Most centuries:
WITH Player_Innings AS
(
SELECT
match_id,
batter,
SUM(batsman_runs) AS Runs
FROM deliveries
GROUP BY match_id,batter
)
SELECT
batter,
COUNT(*) AS Centuries
FROM Player_Innings
WHERE Runs>=100
GROUP BY batter
ORDER BY Centuries DESC
LIMIT 10;

-- Top 10 players with most half-centuries:
WITH Player_Innings AS
(
SELECT
match_id,
batter,
SUM(batsman_runs) AS Runs
FROM deliveries
GROUP BY match_id,batter
)
SELECT
batter,
COUNT(*) AS Half_Centuries
FROM Player_Innings
WHERE Runs BETWEEN 50 AND 99
GROUP BY batter
ORDER BY Half_Centuries DESC
LIMIT 10;


-- Most Ducks by Players:
WITH Player_Innings AS
(
SELECT
match_id,
batter,
SUM(batsman_runs) AS Runs
FROM deliveries
GROUP BY match_id,batter
)
SELECT
batter,
COUNT(*) AS Ducks
FROM Player_Innings
WHERE Runs=0
GROUP BY batter
HAVING COUNT(*)>=10
ORDER BY Ducks DESC
LIMIT 10;



-- Bowling Analysis Page:-

-- Total Wickets:
SELECT COUNT(*) AS Total_Wickets
FROM deliveries
WHERE is_wicket = 1
AND dismissal_kind NOT IN ('run out','retired hurt','retired out','obstructing the field');

-- Best Bowling Figure:
WITH BowlingFigures AS
(
SELECT
match_id,
bowler,
COUNT(*) AS Wickets,
SUM(total_runs) AS Runs
FROM deliveries
WHERE is_wicket=1
AND dismissal_kind NOT IN ('run out','retired hurt','retired out','obstructing the field')
GROUP BY match_id,bowler
)

SELECT
bowler,
Wickets,
Runs
FROM BowlingFigures
ORDER BY Wickets DESC,Runs ASC
LIMIT 1;

-- Best Economy:
WITH Economy AS
(
SELECT
bowler,
SUM(
CASE
WHEN extras_type='byes' OR extras_type='legbyes'
THEN 0
ELSE total_runs
END
) AS Runs,
SUM(
CASE
WHEN extras_type='wides' OR extras_type='noballs'
THEN 0
ELSE 1
END
) AS Balls
FROM deliveries
GROUP BY bowler
)

SELECT
bowler,
ROUND(Runs*6.0/Balls,2) AS Economy
FROM Economy
WHERE Balls>=600
ORDER BY Economy
LIMIT 1;

-- Best Bowling Average:
WITH Bowling AS
(
SELECT
bowler,
SUM(
CASE
WHEN extras_type IN ('byes','legbyes')
THEN 0
ELSE total_runs
END
) AS Runs,
SUM(
CASE
WHEN is_wicket=1
AND dismissal_kind NOT IN
('run out','retired hurt','retired out','obstructing the field')
THEN 1
ELSE 0
END
) AS Wickets
FROM deliveries
GROUP BY bowler
)

SELECT
bowler,
ROUND(Runs/Wickets,2) AS Bowling_Average
FROM Bowling
WHERE Wickets>=20
ORDER BY Bowling_Average
LIMIT 1;

-- Best Bowling Stike Rate:
WITH Bowling AS
(
SELECT
bowler,
SUM(
CASE
WHEN extras_type IN ('wides','noballs')
THEN 0
ELSE 1
END
) AS Balls,
SUM(
CASE
WHEN is_wicket=1
AND dismissal_kind NOT IN
('run out','retired hurt','retired out','obstructing the field')
THEN 1
ELSE 0
END
) AS Wickets
FROM deliveries
GROUP BY bowler
)

SELECT
bowler,
ROUND(Balls/Wickets,2) AS Strike_Rate
FROM Bowling
WHERE Wickets>=20
ORDER BY Strike_Rate
LIMIT 1;

-- Top 10 Wicket takers:
SELECT
bowler,
COUNT(*) AS Wickets
FROM deliveries
WHERE is_wicket=1
AND dismissal_kind NOT IN
('run out','retired hurt','retired out','obstructing the field')
GROUP BY bowler
ORDER BY Wickets DESC
LIMIT 10;

-- Top 10 Economy:
WITH Economy AS
(
SELECT
bowler,
SUM(
CASE
WHEN extras_type IN ('byes','legbyes')
THEN 0
ELSE total_runs
END
) Runs,
SUM(
CASE
WHEN extras_type IN ('wides','noballs')
THEN 0
ELSE 1
END
) Balls
FROM deliveries
GROUP BY bowler
)

SELECT
bowler,
ROUND(Runs*6.0/Balls,2) Economy
FROM Economy
WHERE Balls>=600
ORDER BY Economy
LIMIT 10;

-- Top 10 Average:
WITH Bowling AS
(
SELECT
bowler,
SUM(
CASE
WHEN extras_type IN ('byes','legbyes')
THEN 0
ELSE total_runs
END
) Runs,
SUM(
CASE
WHEN is_wicket=1
AND dismissal_kind NOT IN
('run out','retired hurt','retired out','obstructing the field')
THEN 1
ELSE 0
END
) Wickets
FROM deliveries
GROUP BY bowler
)

SELECT
bowler,
ROUND(Runs/Wickets,2) Bowling_Average
FROM Bowling
WHERE Wickets>=20
ORDER BY Bowling_Average
LIMIT 10;

-- Top 10 Strike Rate:
WITH Bowling AS
(
SELECT
bowler,
SUM(
CASE
WHEN extras_type IN ('wides','noballs')
THEN 0
ELSE 1
END
) Balls,
SUM(
CASE
WHEN is_wicket=1
AND dismissal_kind NOT IN
('run out','retired hurt','retired out','obstructing the field')
THEN 1
ELSE 0
END
) Wickets
FROM deliveries
GROUP BY bowler
)

SELECT
bowler,
ROUND(Balls/Wickets,2) Strike_Rate
FROM Bowling
WHERE Wickets>=20
ORDER BY Strike_Rate
LIMIT 10;

-- Wickets by Each Team:
SELECT
bowling_team,
COUNT(*) AS Wickets
FROM deliveries
WHERE is_wicket=1
AND dismissal_kind NOT IN
('run out','retired hurt','retired out','obstructing the field')
GROUP BY bowling_team
ORDER BY Wickets DESC;

-- Most Dot Balls by a Bowler:
SELECT
    bowler AS Most_Dot_Ball_Bowler,
    COUNT(*) AS Dot_Balls
FROM deliveries
WHERE total_runs = 0
AND (extras_type IS NULL OR extras_type NOT IN ('wides','noballs'))
GROUP BY bowler
ORDER BY Dot_Balls DESC
LIMIT 1;

-- Top 10 Dot Balls By a Player:
SELECT
bowler,
COUNT(*) AS Dot_Balls
FROM deliveries
WHERE total_runs = 0
GROUP BY bowler
ORDER BY Dot_Balls DESC
LIMIT 10;

-- Team Analysis Page:-

-- Total Wins:
SELECT
winner AS Team,
COUNT(*) AS Total_Wins
FROM matches
WHERE winner IS NOT NULL
GROUP BY winner;

-- Total Losses:
SELECT
Team,
COUNT(*) AS Total_Losses
FROM
(
SELECT
team1 AS Team
FROM matches
WHERE winner<>team1
AND winner IS NOT NULL

UNION ALL

SELECT
team2
FROM matches
WHERE winner<>team2
AND winner IS NOT NULL
)t

GROUP BY Team;

-- Matches Played:
SELECT
Team,
COUNT(*) AS Matches_Played
FROM
(
SELECT team1 AS Team
FROM matches

UNION ALL

SELECT team2
FROM matches
)t

GROUP BY Team;

-- Win Percentage:
WITH MP AS
(
SELECT
Team,
COUNT(*) Matches_Played
FROM
(
SELECT team1 Team FROM matches
UNION ALL
SELECT team2 FROM matches
)t
GROUP BY Team
),
TW AS
(
SELECT
winner Team,
COUNT(*) Wins
FROM matches
WHERE winner IS NOT NULL
GROUP BY winner
)

SELECT
MP.Team,
Matches_Played,
COALESCE(Wins,0) Wins,
ROUND(COALESCE(Wins,0)*100.0/Matches_Played,2) Win_Percentage
FROM MP
LEFT JOIN TW
ON MP.Team=TW.Team;

-- Chasing Win Percentage:
SELECT
winner AS Team,
COUNT(*) Chasing_Wins
FROM matches
WHERE result='wickets'
GROUP BY winner;

-- Batting First Win Percentage:
SELECT
winner AS Team,
COUNT(*) Batting_First_Wins
FROM matches
WHERE result='runs'
GROUP BY winner;


-- Top 10 Runs Scorer for a team:
SELECT
batting_team AS Team,
batter,
SUM(batsman_runs) AS Runs
FROM deliveries
GROUP BY
batting_team,
batter
ORDER BY
batting_team,
Runs DESC;

SELECT
bowling_team AS Team,
bowler,
COUNT(*) AS Wickets
FROM deliveries
WHERE player_dismissed IS NOT NULL
AND dismissal_kind NOT IN
(
'run out',
'retired hurt',
'obstructing the field',
'retired out'
)
GROUP BY
bowling_team,
bowler
ORDER BY
bowling_team,
Wickets DESC;

-- Venue Analysis Page:-

-- Most wins on a venue:
SELECT
    venue,
    winner AS Team,
    COUNT(*) AS Wins
FROM matches
WHERE winner IS NOT NULL
GROUP BY venue, winner;

-- Wins while chasing:
SELECT
    venue,
    winner AS Team,
    COUNT(*) AS Chasing_Wins
FROM matches
WHERE result = 'wickets'
GROUP BY venue, winner;


-- Wins in Batting First:
SELECT
    venue,
    winner AS Team,
    COUNT(*) AS Batting_First_Wins
FROM matches
WHERE result = 'runs'
GROUP BY venue, winner;

-- Total Sixes Hit on the venue:
SELECT
    m.venue,
    COUNT(*) AS Total_Sixes
FROM deliveries d
JOIN matches m
ON d.match_id = m.match_id
WHERE batsman_runs = 6
GROUP BY m.venue;

-- Highes Team total on the venue:
WITH InningsScore AS
(
SELECT

m.venue,

d.match_id,

d.inning,

d.batting_team,

SUM(d.total_runs) Score

FROM deliveries d

JOIN matches m
ON d.match_id = m.match_id

GROUP BY
m.venue,
d.match_id,
d.inning,
d.batting_team
)

SELECT

venue,

batting_team,

Score

FROM
(
SELECT
*,
ROW_NUMBER() OVER
(
PARTITION BY venue
ORDER BY Score DESC
) rn

FROM InningsScore
)t

WHERE rn=1;

-- Top 10 run scorers:
SELECT

m.venue,

d.batter,

SUM(d.batsman_runs) Runs

FROM deliveries d

JOIN matches m
ON d.match_id=m.match_id

GROUP BY
m.venue,
d.batter;

-- Top 10 Wicket takers:
SELECT

m.venue,

d.bowler,

COUNT(*) Wickets

FROM deliveries d

JOIN matches m
ON d.match_id=m.match_id

WHERE player_dismissed IS NOT NULL

AND dismissal_kind NOT IN
(
'run out',
'retired hurt',
'obstructing the field',
'retired out'
)

GROUP BY

m.venue,
d.bowler;



SELECT COUNT(*) FROM deliveries;

SELECT COUNT(*) FROM matches;

SELECT
batter,
SUM(batsman_runs)
FROM deliveries
GROUP BY batter
ORDER BY SUM(batsman_runs) DESC
LIMIT 10;


SELECT
bowler,
COUNT(*) AS Wickets
FROM deliveries
WHERE is_wicket = 1
AND dismissal_kind NOT IN
(
'run out',
'retired hurt',
'retired out',
'obstructing the field'
)
GROUP BY bowler
ORDER BY Wickets DESC
LIMIT 10;

SELECT
    bowler,
    COUNT(*) AS Balls
FROM deliveries
WHERE extras_type <> 'wides'
GROUP BY bowler
ORDER BY Balls DESC
LIMIT 10;


SELECT
    bowler,
    SUM(total_runs) AS RunsConceded
FROM deliveries
GROUP BY bowler
ORDER BY RunsConceded DESC
LIMIT 10;

SELECT DISTINCT extras_type
FROM deliveries;

SELECT
COUNT(*) TotalRows,
COUNT(extras_type) FilledExtras
FROM deliveries;

SELECT
extras_type,
COUNT(*)
FROM deliveries
GROUP BY extras_type;


SELECT
    match_id,
    inning,
    bowler,
    SUM(is_wicket) AS wickets,
    SUM(total_runs) AS runs
FROM deliveries
GROUP BY match_id, inning, bowler
ORDER BY wickets DESC, runs ASC
LIMIT 20;

SELECT
    dismissal_kind,
    COUNT(*)
FROM deliveries
WHERE match_id = 1370351
AND inning = 2
AND bowler = 'Akash Madhwal'
AND is_wicket = 1
GROUP BY dismissal_kind;


SELECT COUNT(*)
FROM players
WHERE player_image IS NULL
   OR player_image=''
   OR player_image LIKE '%notfound%';
   
   
UPDATE players
SET player_image = 'https://raw.githubusercontent.com/KLass-1/IPL-Assets/main/default_player.png'
WHERE player_image IS NULL
   OR TRIM(player_image) = '';
   
   SELECT player_name, player_image
FROM players
WHERE player_image IS NOT NULL
LIMIT 10;

SELECT COUNT(*)
FROM players
WHERE player_image='https://raw.githubusercontent.com/KLass-1/IPL-Assets/main/default_player.png';


UPDATE players
SET player_image = 'https://raw.githubusercontent.com/KLass-1/IPL-Assets/main/default_player_v2.png'
WHERE player_image LIKE 'https://raw.githubusercontent.com/KLass-1/IPL-Assets/main/default_player.png';