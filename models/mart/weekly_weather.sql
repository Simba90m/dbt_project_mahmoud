WITH daily AS (
    SELECT * FROM {{ ref('prep_weather_daily') }}
)

SELECT
    airport_code,
    station_id,
    date_year,
    cw AS week_number,
    AVG(avg_temp_c) AS avg_temp_c,
    MAX(max_temp_c) AS max_temp_c,
    MIN(min_temp_c) AS min_temp_c,
    SUM(precipitation_mm) AS total_precipitation_mm,
    SUM(max_snow_mm) AS total_snow_mm,
    AVG(avg_wind_direction) AS avg_wind_direction,
    AVG(avg_wind_speed_kmh) AS avg_wind_speed_kmh,
    MAX(wind_peakgust_kmh) AS max_wind_peakgust_kmh,
    AVG(avg_pressure_hpa) AS avg_pressure_hpa,
    SUM(sun_minutes) AS total_sun_minutes
FROM daily
GROUP BY airport_code, station_id, date_year, cw
ORDER BY date_year, week_number