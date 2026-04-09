# ✈️ Flight Delays & Weather — ETL Pipeline and Dashboard

**Course:** ISTA 322 — Final Project  
**Author:** Vivian Huynh  
**Language:** Python 3 · MySQL · Streamlit

---

## Overview

This project builds an end-to-end ETL (Extract, Transform, Load) data pipeline to explore how weather conditions relate to flight delays at four major U.S. airports during **January 2025**:

| Airport | Code |
|---|---|
| John F. Kennedy International | JFK |
| San Francisco International | SFO |
| Phoenix Sky Harbor International | PHX |
| Denver International | DEN |

Flight records are sourced from the **BTS On-Time Performance** dataset, weather data is pulled from the **Open-Meteo Historical Weather API**, and everything is joined and loaded into a **MySQL** relational database. The final deliverable is a **Streamlit dashboard** for interactive exploration of the combined dataset.

---

## Pipeline Summary

```
BTS Flight CSV  ──┐
                  ├──► Clean & Normalize ──► MySQL Star Schema ──► SQL Analysis ──► Streamlit App
Open-Meteo API ──┘
```

### Extract
- Flight records from BTS On-Time Performance (one row per flight leg)
- Daily weather (temperature, precipitation, wind speed) from the Open-Meteo `/v1/archive` endpoint for each airport's latitude/longitude
- Airport metadata (IATA code, name, coordinates) constructed manually

### Transform
- Filter to flights originating from the four target airports
- Drop cancelled and diverted flights
- Create clean delay fields (`dep_delay_minutes`, `arr_delay_minutes`) using `*_NEW` columns with fallback to raw delay fields
- Add binary `is_delayed_15` flag (arrival delay > 15 minutes)
- Assign surrogate `airport_id` keys to both flights and weather records
- Aggregate to weekly metrics per airport (Monday week start)

### Load
- Create and populate four MySQL tables using `executemany` with proper type conversion (numpy → Python scalars, NaN/NaT → None)

---

## Database Schema

Four tables in the `flights_weather` MySQL database:

```
airports ──< flights
airports ──< daily_weather
airports ──< weekly_flight_weather_metrics
```

| Table | Grain | Key Measures |
|---|---|---|
| `airports` | One row per airport | `iata_code`, `latitude`, `longitude` |
| `flights` | One row per flight leg | `dep_delay_minutes`, `arr_delay_minutes`, `is_delayed_15` |
| `daily_weather` | One day per airport | `temp_avg_c`, `precip_mm`, `wind_speed_ms` |
| `weekly_flight_weather_metrics` | One week per airport | `avg_dep_delay_minutes`, `percent_delayed_15`, `weekly_precip_mm`, `weekly_wind_speed_ms` |

The SQL DDL for all tables is in `final_project_sql_file_JUST_IN_CASE.sql`.

---

## Key SQL Queries

Five analytical queries are included in the notebook:

1. **Average weekly departure delay by airport** — ranks JFK, SFO, PHX, DEN by worst delays (DEN led at ~15 min avg)
2. **% of flights delayed > 15 min by airport** — DEN: 23.8%, JFK: 19.3%, SFO: 13.0%, PHX: 11.8%
3. **Weekly delay trends per airport** — tracks how delays evolved week-by-week through January
4. **Precipitation vs departure delay** — pairs weekly precip totals with average delay per airport and week
5. **Windiest weeks vs delays** — ranks weeks by wind speed and checks for corresponding delay spikes

---

## Visualizations

Three main plots are generated in the notebook:

**Plot 1 — Weekly departure delays vs precipitation (2×2 subplot grid)**  
One panel per airport showing delay trends alongside weekly precipitation bars. Precipitation spikes visibly align with higher delays at JFK and DEN.

**Plot 2 — Wind speed vs departure delay (scatter + regression)**  
All airports and weeks combined. Regression line has a modest upward slope (R² = 0.082), suggesting wind contributes to delays but is not the dominant factor.

**Plot 3 — Weekly delays by airport with temperature shading (lollipop chart)**  
Panels by week; point color encodes weekly mean temperature. Colder airports (JFK, DEN) show higher delays in cold weeks, consistent with de-icing and winter operations.

---

## Streamlit Dashboard

A four-page interactive app for exploring the full dataset:

| Page | Description |
|---|---|
| **Welcome** | Project summary, pipeline overview, quick stats (59,004 flights, 31 days) |
| **January 2025 Weather** | Select airport + date range → live Open-Meteo API call → daily temp/precip/wind table and Plotly chart |
| **January 2025 Flight Report** | Filter by origin airport → KPI cards, delay donut charts, day-of-month delay bar charts, detailed flight table |
| **Daily Weather vs Delays** | Select airports, date range, and weather variable → scatter plot with trendline + daily delay time series |

### Run the app

```bash
pip install streamlit plotly pandas requests mysql-connector-python
streamlit run app.py
```

---

## Data Sources

| Source | Description | Link |
|---|---|---|
| BTS On-Time Performance | U.S. DOT flight-level delay records | https://www.transtats.bts.gov |
| Open-Meteo Historical API | Free daily weather archive (no API key required) | https://open-meteo.com |

---

## Files

| File | Description |
|---|---|
| `ISTA322_Project.ipynb` | Main ETL notebook — full pipeline from raw data to MySQL |
| `compressed_data_csv.gz` | Compressed BTS flight data (January 2025) |
| `Documentation.csv` | BTS column documentation/data dictionary |
| `final_project_sql_file_JUST_IN_CASE.sql` | SQL DDL for all four database tables |
| `vivian_huynh_final_project_report.pdf` | Full written project report |

---

## Setup

### MySQL
1. Create a database (e.g., `flights_weather`) in MySQL Workbench
2. Update the connection credentials in the notebook:
   ```python
   mysql_address  = '127.0.0.1'
   mysql_username = 'your_username'
   mysql_password = 'your_password'
   mysql_database = 'flights_weather'
   ```
3. Run all notebook cells in order — tables are created and populated automatically
4. If MySQL loading fails, use the provided `.sql` file to create tables manually

### Python dependencies
```bash
pip install pandas numpy requests matplotlib plotly mysql-connector-python streamlit
```
