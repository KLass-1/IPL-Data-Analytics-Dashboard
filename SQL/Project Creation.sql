create database ipl_analysis;

use ipl_analysis;

-- Matches Data:-
CREATE TABLE matches (
    match_id INT PRIMARY KEY,
    season VARCHAR(20),
    city VARCHAR(100),
    date DATE,
    match_type VARCHAR(50),
    player_of_match VARCHAR(100),
    venue VARCHAR(255),
    team1 VARCHAR(100),
    team2 VARCHAR(100),
    toss_winner VARCHAR(100),
    toss_decision VARCHAR(20),
    winner VARCHAR(100),
    result VARCHAR(50),
    result_margin DECIMAL(10,2),
    target_runs DECIMAL(10,2),
    target_overs DECIMAL(5,2),
    super_over VARCHAR(10),
    method VARCHAR(50),
    umpire1 VARCHAR(100),
    umpire2 VARCHAR(100)
);

-- Each Ball Data:-
CREATE TABLE deliveries (
    match_id INT,
    inning INT,
    over_no INT,
    ball_no INT,
    batting_team VARCHAR(100),
    bowling_team VARCHAR(100),
    batter VARCHAR(100),
    bowler VARCHAR(100),
    non_striker VARCHAR(100),
    batsman_runs INT,
    extra_runs INT,
    total_runs INT,
    extras_type VARCHAR(50),
    is_wicket INT,
    player_dismissed VARCHAR(100),
    dismissal_kind VARCHAR(100),
    fielder VARCHAR(100)
);

-- Players Info Data:-
CREATE TABLE players (
    player_id INT PRIMARY KEY,
    player_name VARCHAR(100),
    bat_style VARCHAR(100),
    bowl_style VARCHAR(100),
    field_pos VARCHAR(100),
    player_full_name VARCHAR(150),
    player_name2 VARCHAR(100),
    player_image TEXT
);


-- Teams Info Data:-
CREATE TABLE teams (
    team_id INT PRIMARY KEY,
    team_name VARCHAR(100),
    team_name_short VARCHAR(20),
    image_url TEXT
);

SELECT COUNT(*) FROM matches;
SELECT COUNT(*) FROM deliveries;
SELECT COUNT(*) FROM teams;
SELECT COUNT(*) FROM players;

SELECT COUNT(DISTINCT match_id, inning, over_no, ball_no) 
FROM deliveries;

TRUNCATE TABLE deliveries;

select * from matches;

DESCRIBE matches;

select * from teams;
