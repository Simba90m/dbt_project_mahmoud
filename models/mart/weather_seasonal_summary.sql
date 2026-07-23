WITH daily AS (
    SELECT * FROM {{ ref('prep_weather_daily') }}
)

SELECT
    airport_code,
    date_year,
    season,
    COUNT(*) AS days_in_season,
    AVG(avg_temp_c) AS avg_temp_c,
    MAX(max_temp_c) AS highest_temp_c,
    MIN(min_temp_c) AS lowest_temp_c,
    SUM(precipitation_mm) AS total_precipitation_mm,
    SUM(CASE WHEN precipitation_mm > 0 THEN 1 ELSE 0 END) AS rainy_days,
    SUM(max_snow_mm) AS total_snow_mm,
    SUM(CASE WHEN max_snow_mm > 0 THEN 1 ELSE 0 END) AS snowy_days,
    AVG(avg_wind_speed_kmh) AS avg_wind_speed_kmh,
    MAX(wind_peakgust_kmh) AS max_wind_peakgust_kmh
FROM daily
GROUP BY airport_code, date_year, season
ORDER BY date_year,
    CASE season
        WHEN 'winter' THEN 1
        WHEN 'spring' THEN 2
        WHEN 'summer' THEN 3
        WHEN 'autumn' THEN 4
    END