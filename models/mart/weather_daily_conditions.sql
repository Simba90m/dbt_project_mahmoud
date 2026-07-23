WITH daily AS (
    SELECT * FROM {{ ref('prep_weather_daily') }}
)

SELECT
    airport_code,
    date,
    date_year,
    month_name,
    season,
    avg_temp_c,
    min_temp_c,
    max_temp_c,
    (max_temp_c - min_temp_c) AS daily_temp_spread_c,
    avg_wind_speed_kmh,
    CASE
        WHEN avg_wind_speed_kmh < 1   THEN 'Calm'
        WHEN avg_wind_speed_kmh < 6   THEN 'Light air'
        WHEN avg_wind_speed_kmh < 12  THEN 'Light breeze'
        WHEN avg_wind_speed_kmh < 20  THEN 'Gentle breeze'
        WHEN avg_wind_speed_kmh < 29  THEN 'Moderate breeze'
        WHEN avg_wind_speed_kmh < 39  THEN 'Fresh breeze'
        WHEN avg_wind_speed_kmh < 50  THEN 'Strong breeze'
        WHEN avg_wind_speed_kmh < 62  THEN 'Near gale'
        ELSE 'Gale or stronger'
    END AS wind_strength_beaufort,
    precipitation_mm,
    CASE WHEN precipitation_mm > 0 THEN TRUE ELSE FALSE END AS is_rainy,
    max_snow_mm,
    CASE WHEN max_snow_mm > 0 THEN TRUE ELSE FALSE END AS is_snowy
FROM daily