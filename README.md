# 🏏 IPL Data Analytics Project

An end-to-end data analytics project on Indian Premier League (IPL) cricket data — covering data cleaning, SQL-based transformation, and an interactive Power BI dashboard for season, batting, bowling, team, venue, and player analysis.

## 📌 Project Overview

This project analyzes ball-by-ball and match-level IPL data (2008–2024) to uncover insights on team performance, player records, and venue trends. Raw CSV data is loaded into a MySQL database, cleaned and transformed using SQL, enriched with a custom `player_stats` table, and finally visualized in a multi-page Power BI dashboard.

**Workflow:**

```
Raw CSV Data → MySQL (via Python/SQLAlchemy) → SQL Cleaning & Transformation → Player Stats Aggregation → Power BI Dashboard
```

## 🗂️ Repository Structure

```
IPL Data_Analytics Project/
│
├── Raw Data/                      # Original, unprocessed source files
│   ├── matches.csv
│   ├── deliveries.csv
│   ├── players-data-updated.csv
│   └── teams_data.csv
│
├── Cleaned Data/                  # Cleaned, analysis-ready datasets
│   ├── matches.csv
│   ├── deliveries.csv
│   ├── players.csv
│   ├── teams.csv
│   └── player_stats.csv
│
├── Images Used/                   # Logos, caps, and player images for the dashboard
│
├── IPL_Project.ipynb              # Loads raw CSVs into MySQL using pandas + SQLAlchemy
├── Project Creation.sql           # Database & table schema creation
├── Data Cleaning.sql              # Null/duplicate/blank checks and data standardization
├── Player_stats table.sql         # Builds the aggregated player_stats table
├── Data Queries.sql               # Analytical queries powering each dashboard page
└── IPL_Project.pbix               # Power BI dashboard
```

## 📊 Dataset

| Table          | Description                                                                    | Rows     |
| -------------- | ------------------------------------------------------------------------------ | -------- |
| `matches`      | One row per match — teams, venue, toss, result, umpires                        | ~1,095   |
| `deliveries`   | Ball-by-ball data — batter, bowler, runs, extras, wickets                      | ~260,920 |
| `players`      | Player bio info — batting/bowling style, images                                | ~772     |
| `teams`        | IPL team reference data                                                        | 16       |
| `player_stats` | Aggregated career stats per player (runs, wickets, average, strike rate, etc.) | ~1,310   |

## 🛠️ Tech Stack

- **Python** (pandas, SQLAlchemy, PyMySQL) — data ingestion into MySQL
- **MySQL** — data storage, cleaning, and aggregation
- **Power BI** — interactive dashboard and visualization
- **Jupyter Notebook** — ETL scripting

## 🧹 Data Cleaning

`Data Cleaning.sql` handles:

- Null, blank, and duplicate value checks across all tables
- Standardizing inconsistent team names (e.g., historic franchise name changes)
- Validating referential integrity between `matches` and `deliveries`

## 📈 Dashboard Pages

The Power BI report (`IPL_Project.pbix`) includes the following pages, each backed by dedicated queries in `Data Queries.sql`:

1. **Season Analysis** — season winners, runners-up, total matches/runs/sixes/fours/wickets, Orange & Purple Cap winners, best strike rate & economy



3. **Batting Analysis** — top run scorers, strike rates, sixes/fours, centuries/half-centuries, batting averages, runs distribution by team
4. **Bowling Analysis** — top wicket takers, best economy/average/strike rate, dot ball leaders
5. **Team Analysis** — wins/losses, win %, chasing vs. batting-first win %, top run scorers per team
6. **Venue Analysis** — most wins per venue, chasing vs. defending success, highest team totals, sixes hit per venue

## 🚀 Getting Started

### Prerequisites

- MySQL Server
- Python 3.x with `pandas`, `sqlalchemy`, `pymysql`
- Power BI Desktop (to open `IPL_Project.pbix`)

### Setup

1. **Create the database and tables**

   ```sql
   SOURCE Project Creation.sql;
   ```

2. **Load the raw data into MySQL**
   Open `IPL_Project.ipynb` and update the database connection details (host, user, password, database name) — store these as environment variables rather than hardcoding them — then run the notebook to import `matches`, `deliveries`, `teams`, and `players` into MySQL.

3. **Clean the data**

   ```sql
   SOURCE Data Cleaning.sql;
   ```

4. **Build the player stats table**

   ```sql
   SOURCE Player_stats table.sql;
   ```

5. **Run the analytical queries**

   ```sql
   SOURCE Data Queries.sql;
   ```

6. **Explore the dashboard**
   Open `IPL_Project.pbix` in Power BI Desktop and point the data source to your MySQL database (or the CSVs in `Cleaned Data/`).

## 📌 Key Insights Enabled

- Season-by-season IPL winners and runners-up
- Orange Cap (top run scorer) and Purple Cap (top wicket taker) per season
- Batting and bowling leaderboards across IPL history
- Team performance trends, including chasing vs. defending success rates
- Venue-specific scoring and winning patterns

## 📄 License

This project is intended for educational and portfolio purposes. IPL data is sourced from publicly available datasets.

## 🙋 Author

Feel free to reach out with questions, feedback, or suggestions for improving this project.
