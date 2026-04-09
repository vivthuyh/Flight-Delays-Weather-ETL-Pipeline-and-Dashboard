DROP TABLE IF EXISTS weekly_flight_weather_metrics;
DROP TABLE IF EXISTS daily_weather;
DROP TABLE IF EXISTS flights;
DROP TABLE IF EXISTS airports;

CREATE TABLE airports (
    airport_id INT PRIMARY KEY,
    iata_code VARCHAR(5) NOT NULL,
    airport_name VARCHAR(100),
    latitude DOUBLE,
    longitude DOUBLE
);

CREATE TABLE flights (
    flight_id INT AUTO_INCREMENT PRIMARY KEY,
    flight_date DATE NOT NULL,
    carrier VARCHAR(10),
    op_unique_carrier VARCHAR(10),
    flight_number VARCHAR(10),
    origin_airport_id INT,
    dest_airport_id INT,
    dep_time VARCHAR(10),
    arr_time VARCHAR(10),
    dep_delay_minutes INT,
    arr_delay_minutes INT,
    is_delayed_15 BOOLEAN,
    FOREIGN KEY (origin_airport_id) REFERENCES airports(airport_id),
    FOREIGN KEY (dest_airport_id) REFERENCES airports(airport_id)
);

CREATE TABLE daily_weather (
    weather_id INT AUTO_INCREMENT PRIMARY KEY,
    airport_id INT NOT NULL,
    date DATE NOT NULL,
    temp_avg_c DOUBLE,
    precip_mm DOUBLE,
    wind_speed_ms DOUBLE,
    FOREIGN KEY (airport_id) REFERENCES airports(airport_id)
);

CREATE TABLE weekly_flight_weather_metrics (
    airport_id INT NOT NULL,
    week_start_date DATE NOT NULL,
    avg_dep_delay_minutes DOUBLE,
    avg_arr_delay_minutes DOUBLE,
    percent_delayed_15 DOUBLE,
    weekly_temp_avg_c DOUBLE,
    weekly_precip_mm DOUBLE,
    weekly_wind_speed_ms DOUBLE,
    PRIMARY KEY (airport_id, week_start_date),
    FOREIGN KEY (airport_id) REFERENCES airports(airport_id)
);
