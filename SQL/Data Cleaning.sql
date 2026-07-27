-- Matches Table Cleaning:-

DESCRIBE matches;

SELECT COUNT(*) FROM matches;

-- NUll Values Count:-
SELECT
SUM(match_id IS NULL) AS match_id,
SUM(season IS NULL) AS season,
SUM(city IS NULL) AS city,
SUM(date IS NULL) AS match_date,
SUM(match_type IS NULL) AS match_type,
SUM(player_of_match IS NULL) AS player_of_match,
SUM(venue IS NULL) AS venue,
SUM(team1 IS NULL) AS team1,
SUM(team2 IS NULL) AS team2,
SUM(toss_winner IS NULL) AS toss_winner,
SUM(toss_decision IS NULL) AS toss_decision,
SUM(winner IS NULL) AS winner,
SUM(result IS NULL) AS result,
SUM(result_margin IS NULL) AS result_margin,
SUM(target_runs IS NULL) AS target_runs,
SUM(target_overs IS NULL) AS target_overs,
SUM(super_over IS NULL) AS super_over,
SUM(method IS NULL) AS method,
SUM(umpire1 IS NULL) AS umpire1,
SUM(umpire2 IS NULL) AS umpire2
FROM matches;

-- Duplicate Values Count:-
SELECT match_id, COUNT(*)
FROM matches
GROUP BY match_id
HAVING COUNT(*) > 1;

-- Blank Values Check:- 
SELECT COUNT(*)
FROM matches
WHERE city='';

SELECT COUNT(*)
FROM matches
WHERE winner='';

SELECT COUNT(*)
FROM matches
WHERE venue='';

SELECT DISTINCT team1
FROM matches
ORDER BY team1;

SELECT DISTINCT team2
FROM matches
ORDER BY team2;

-- Updating team names in the table
SET SQL_SAFE_UPDATES = 0;

UPDATE matches SET team1 = 'Punjab Kings' WHERE team1 = 'Kings XI Punjab';
UPDATE matches SET team2 = 'Punjab Kings' WHERE team2 = 'Kings XI Punjab';
UPDATE matches SET winner = 'Punjab Kings' WHERE winner = 'Kings XI Punjab';
UPDATE matches SET toss_winner = 'Punjab Kings' WHERE toss_winner = 'Kings XI Punjab';


UPDATE matches SET team1 = 'Delhi Capitals' WHERE team1 = 'Delhi Daredevils';
UPDATE matches SET team2 = 'Delhi Capitals' WHERE team2 = 'Delhi Daredevils';
UPDATE matches SET winner = 'Delhi Capitals' WHERE winner = 'Delhi Daredevils';
UPDATE matches SET toss_winner = 'Delhi Capitals' WHERE toss_winner = 'Delhi Daredevils';


UPDATE matches SET team1 = 'Rising Pune Supergiant' WHERE team1 = 'Rising Pune Supergiants';
UPDATE matches SET team2 = 'Rising Pune Supergiant' WHERE team2 = 'Rising Pune Supergiants';
UPDATE matches SET winner = 'Rising Pune Supergiant' WHERE winner = 'Rising Pune Supergiants';
UPDATE matches SET toss_winner = 'Rising Pune Supergiant' WHERE toss_winner = 'Rising Pune Supergiants';


UPDATE matches SET team1 = 'Royal Challengers Bengaluru' WHERE team1 = 'Royal Challengers Bangalore';
UPDATE matches SET team2 = 'Royal Challengers Bengaluru' WHERE team2 = 'Royal Challengers Bangalore';
UPDATE matches SET winner = 'Royal Challengers Bengaluru' WHERE winner = 'Royal Challengers Bangalore';
UPDATE matches SET toss_winner = 'Royal Challengers Bengaluru' WHERE toss_winner = 'Royal Challengers Bangalore';


SET SQL_SAFE_UPDATES = 1;

-- Filling blank values in the city column
UPDATE matches SET city = 'Dubai' WHERE venue LIKE '%Dubai%' AND city IS NULL;
UPDATE matches SET city = 'Sharjah' WHERE venue LIKE '%Sharjah%' AND city IS NULL;
UPDATE matches SET city = 'Abu Dhabi' WHERE venue LIKE '%Abu Dhabi%' AND city IS NULL;

SELECT match_id, team1, team2, result, winner FROM matches WHERE winner IS NULL;

SELECT DISTINCT venue FROM matches WHERE city IS NULL;

SELECT DISTINCT season
FROM matches
ORDER BY season;
ORDER BY season;

SET SQL_SAFE_UPDATES = 0;

UPDATE matches
SET season = '2008'
WHERE season = '2007/08';

UPDATE matches
SET season = '2010'
WHERE season = '2009/10';

UPDATE matches
SET season = '2020'
WHERE season = '2020/21';

SET SQL_SAFE_UPDATES = 1;

-- Deliveries Table Cleaning:-

Describe deliveries;

SELECT COUNT(*) FROM deliveries;


-- Null Values Check:-
SELECT
SUM(match_id IS NULL) AS match_id,
SUM(inning IS NULL) AS inning,
SUM(batting_team IS NULL) AS batting_team,
SUM(bowling_team IS NULL) AS bowling_team,
SUM(over_no IS NULL) AS over_no,
SUM(ball_no IS NULL) AS ball_no,
SUM(batter IS NULL) AS batter,
SUM(bowler IS NULL) AS bowler,
SUM(non_striker IS NULL) AS non_striker,
SUM(batsman_runs IS NULL) AS batsman_runs,
SUM(extra_runs IS NULL) AS extra_runs,
SUM(total_runs IS NULL) AS total_runs,
SUM(extras_type IS NULL) AS extras_type,
SUM(is_wicket IS NULL) AS is_wicket,
SUM(player_dismissed IS NULL) AS player_dismissed,
SUM(dismissal_kind IS NULL) AS dismissal_kind,
SUM(fielder IS NULL) AS fielder
FROM deliveries;


-- Duplicate rows check:-
SELECT
match_id,
inning,
over_no,
ball_no,
COUNT(*)
FROM deliveries
GROUP BY
match_id,
inning,
over_no,
ball_no
HAVING COUNT(*)>1;

-- Distinct Team names check:-
SELECT DISTINCT batting_team
FROM deliveries
ORDER BY batting_team;

SELECT DISTINCT bowling_team
FROM deliveries
ORDER BY bowling_team;

-- Updating Team names Distinct:- 
SET SQL_SAFE_UPDATES=0;

UPDATE deliveries
SET batting_team='Punjab Kings'
WHERE batting_team='Kings XI Punjab';

UPDATE deliveries
SET bowling_team='Punjab Kings'
WHERE bowling_team='Kings XI Punjab';



UPDATE deliveries
SET batting_team='Delhi Capitals'
WHERE batting_team='Delhi Daredevils';

UPDATE deliveries
SET bowling_team='Delhi Capitals'
WHERE bowling_team='Delhi Daredevils';



UPDATE deliveries
SET batting_team='Royal Challengers Bengaluru'
WHERE batting_team='Royal Challengers Bangalore';

UPDATE deliveries
SET bowling_team='Royal Challengers Bengaluru'
WHERE bowling_team='Royal Challengers Bangalore';



UPDATE deliveries
SET batting_team='Rising Pune Supergiant'
WHERE batting_team='Rising Pune Supergiants';

UPDATE deliveries
SET bowling_team='Rising Pune Supergiant'
WHERE bowling_team='Rising Pune Supergiants';

SET SQL_SAFE_UPDATES=1;

-- Invalid runs check:-
SELECT *
FROM deliveries
WHERE batsman_runs<0
OR extra_runs<0
OR total_runs<0;


-- Invalid Over numbers check:-
SELECT *
FROM deliveries
WHERE over_no<1
OR over_no>20;


-- Invalid ball numbers check:- 
SELECT *
FROM deliveries
WHERE ball_no<1
OR ball_no>10;


SELECT DISTINCT batting_team FROM deliveries ORDER BY batting_team;

SELECT COUNT(*) AS remaining_old_names_deliveries
FROM deliveries
WHERE batting_team IN ('Kings XI Punjab', 'Delhi Daredevils', 'Rising Pune Supergiants', 'Royal Challengers Bangalore')
   OR bowling_team IN ('Kings XI Punjab', 'Delhi Daredevils', 'Rising Pune Supergiants', 'Royal Challengers Bangalore');


-- Blank Values Check:-
SELECT COUNT(*) FROM deliveries WHERE batter='';
SELECT COUNT(*) FROM deliveries WHERE bowler='';
SELECT COUNT(*) FROM deliveries WHERE batting_team='';
SELECT COUNT(*) FROM deliveries WHERE bowling_team='';
SELECT COUNT(*) FROM deliveries WHERE extras_type='';
SELECT COUNT(*) FROM deliveries WHERE dismissal_kind='';
SELECT COUNT(*) FROM deliveries WHERE fielder='';
SELECT COUNT(*) FROM deliveries WHERE player_dismissed='';

-- Foreign Key Validation:-
SELECT COUNT(*)
FROM deliveries d
LEFT JOIN matches m
ON d.match_id=m.match_id
WHERE m.match_id IS NULL;

-- Checking types of extras:-
SELECT DISTINCT extras_type
FROM deliveries;


-- Checking types of dismissals:-
SELECT DISTINCT dismissal_kind
FROM deliveries;

-- Players Table Cleaning:-

DESCRIBE deliveries;

SELECT COUNT(*) FROM deliveries;

-- Null Values Check:-
SELECT 
SUM(player_id IS NULL) AS player_id,
SUM(player_name IS NULL) AS player_name,
SUM(bat_style IS NULL) AS bat_style,
SUM(bowl_style IS NULL) AS bowl_style,
SUM(field_pos IS NULL) AS field_pos,
SUM(player_full_name IS NULL) AS player_full_name,
SUM(player_name2 IS NULL) AS player_name2,
SUM(player_image IS NULL) AS player_image
FROM players;

-- Blank Values Check:-
SELECT COUNT(*) FROM players WHERE player_name='';
SELECT COUNT(*) FROM players WHERE bat_style='';
SELECT COUNT(*) FROM players WHERE bowl_style='';
SELECT COUNT(*) FROM players WHERE field_pos='';
SELECT COUNT(*) FROM players WHERE player_full_name='';
SELECT COUNT(*) FROM players WHERE player_name2='';
SELECT COUNT(*) FROM players WHERE player_image='';


UPDATE players 
SET bowl_style = NULL 
WHERE bowl_style = '';

UPDATE players 
SET field_pos = NULL 
WHERE field_pos = '';

-- Duplicate Player ID's:-
SELECT player_id, COUNT(*)
FROM players
GROUP BY player_id
HAVING COUNT(*) > 1;

-- Duplicate Player Names:-
SELECT player_name, COUNT(*)
FROM players
GROUP BY player_name
HAVING COUNT(*) > 1;

-- Bat Style Check:-
SELECT DISTINCT bat_style
FROM players
ORDER BY bat_style;

-- Bowl Style Check:- 
SELECT DISTINCT bowl_style
FROM players
ORDER BY bowl_style;

-- Field Position check:-
SELECT DISTINCT field_pos
FROM players
ORDER BY field_pos;

-- Player_id check:-
SELECT COUNT(*)
FROM players
WHERE player_id IS NULL;


SELECT player_id, player_name, bowl_style, field_pos
FROM players
WHERE field_pos IN (
'Right arm Fast',
'Right arm Medium',
'Slow Left arm Orthodox'
);


-- Updating bowl style:-
UPDATE players
SET bowl_style = field_pos,
    field_pos = NULL
WHERE field_pos IN (
'Right arm Fast',
'Right arm Medium',
'Slow Left arm Orthodox'
);

-- Duplicate names check:- 
SELECT player_full_name, COUNT(*)
FROM players
GROUP BY player_full_name
HAVING COUNT(*) > 1;

SELECT *,
COUNT(*) AS cnt
FROM players
GROUP BY
player_id,
player_name,
bat_style,
bowl_style,
field_pos,
player_full_name,
player_name2,
player_image
HAVING COUNT(*) > 1;

SELECT COUNT(*) FROM players;

SELECT COUNT(*)
FROM players
WHERE player_name2 <> player_full_name;


-- Teams Table Cleaning:-

DESCRIBE teams;

SELECT COUNT(*) FROM teams;

-- Null Values Check:- 
SELECT
SUM(team_id IS NULL) AS team_id,
SUM(team_name IS NULL) AS team_name,
SUM(team_name_short IS NULL) AS team_name_short,
SUM(image_url IS NULL) AS image_url
FROM teams;

-- Blank Values Check:- 
SELECT COUNT(*) FROM teams WHERE team_name = '';
SELECT COUNT(*) FROM teams WHERE team_name_short = '';
SELECT COUNT(*) FROM teams WHERE image_url = '';

-- Duplicate Id's Check:-
SELECT team_id, COUNT(*)
FROM teams
GROUP BY team_id
HAVING COUNT(*) > 1;

SELECT DISTINCT team_name
FROM teams
ORDER BY team_name;

select * from teams;

-- Team Names Updation
SET SQL_SAFE_UPDATES = 0;

UPDATE teams
SET team_name = 'Royal Challengers Bengaluru'
WHERE team_name = 'Royal Challengers Bangalore';

UPDATE teams
SET team_name = 'Rising Pune Supergiant'
WHERE team_name = 'Rising Pune Supergiants';

SET SQL_SAFE_UPDATES = 1;

SELECT team_name, COUNT(*)
FROM teams
GROUP BY team_name
HAVING COUNT(*) > 1;

SELECT *
FROM teams
WHERE team_name = 'Rising Pune Supergiant';

DELETE FROM teams
WHERE team_id = 3604;


-- Venues Cleaning:
SELECT
venue,
COUNT(*) Matches
FROM matches
GROUP BY venue
ORDER BY venue;

SET SQL_SAFE_UPDATES = 0;

-- Arun Jaitley
UPDATE matches
SET venue = 'Arun Jaitley Stadium'
WHERE venue IN (
'Arun Jaitley Stadium, Delhi',
'Feroz Shah Kotla'
);

-- Brabourne
UPDATE matches
SET venue = 'Brabourne Stadium'
WHERE venue = 'Brabourne Stadium, Mumbai';

-- Dr DY Patil
UPDATE matches
SET venue = 'Dr DY Patil Sports Academy'
WHERE venue = 'Dr DY Patil Sports Academy, Mumbai';

-- Vizag
UPDATE matches
SET venue = 'Dr. Y.S. Rajasekhara Reddy ACA-VDCA Cricket Stadium'
WHERE venue = 'Dr. Y.S. Rajasekhara Reddy ACA-VDCA Cricket Stadium, Visakhapatnam';

-- Eden Gardens
UPDATE matches
SET venue = 'Eden Gardens'
WHERE venue = 'Eden Gardens, Kolkata';

-- Dharamsala
UPDATE matches
SET venue = 'Himachal Pradesh Cricket Association Stadium'
WHERE venue = 'Himachal Pradesh Cricket Association Stadium, Dharamsala';

-- Chinnaswamy
UPDATE matches
SET venue = 'M Chinnaswamy Stadium'
WHERE venue IN (
'M.Chinnaswamy Stadium',
'M Chinnaswamy Stadium, Bengaluru'
);

-- Chepauk
UPDATE matches
SET venue = 'MA Chidambaram Stadium'
WHERE venue IN (
'MA Chidambaram Stadium, Chepauk',
'MA Chidambaram Stadium, Chepauk, Chennai'
);

-- MCA Pune
UPDATE matches
SET venue = 'Maharashtra Cricket Association Stadium'
WHERE venue = 'Maharashtra Cricket Association Stadium, Pune';

-- Mohali
UPDATE matches
SET venue = 'Punjab Cricket Association IS Bindra Stadium'
WHERE venue IN (
'Punjab Cricket Association IS Bindra Stadium, Mohali',
'Punjab Cricket Association IS Bindra Stadium, Mohali, Chandigarh',
'Punjab Cricket Association Stadium, Mohali'
);

-- Hyderabad
UPDATE matches
SET venue = 'Rajiv Gandhi International Stadium'
WHERE venue IN (
'Rajiv Gandhi International Stadium, Uppal',
'Rajiv Gandhi International Stadium, Uppal, Hyderabad'
);

-- Jaipur
UPDATE matches
SET venue = 'Sawai Mansingh Stadium'
WHERE venue = 'Sawai Mansingh Stadium, Jaipur';

-- Wankhede
UPDATE matches
SET venue = 'Wankhede Stadium'
WHERE venue = 'Wankhede Stadium, Mumbai';

-- Abu Dhabi
UPDATE matches
SET venue = 'Sheikh Zayed Stadium'
WHERE venue = 'Zayed Cricket Stadium, Abu Dhabi';

SET SQL_SAFE_UPDATES = 1;

SELECT venue, COUNT(*)
FROM matches
GROUP BY venue
ORDER BY venue;

UPDATE matches
SET city = 'Bengaluru'
WHERE city = 'Bangalore';
