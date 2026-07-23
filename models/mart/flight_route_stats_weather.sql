WITH flights AS (
    SELECT * FROM {{ ref('prep_flights') }}
),
weather AS (
    SELECT * FROM {{ ref('prep_weather_daily') }}
),
airports AS (
    SELECT * FROM {{ ref('prep_airports') }}
),

departures AS (
    SELECT
        origin AS airport_code,
        flight_date,
        COUNT(DISTINCT dest) AS unique_departure_connections,
        COUNT(*) AS total_departures_planned,
        SUM(CASE WHEN cancelled = 1 THEN 1 ELSE 0 END) AS total_departures_cancelled,
        SUM(CASE WHEN diverted = 1 THEN 1 ELSE 0 END) AS total_departures_diverted,
        SUM(CASE WHEN cancelled = 0 AND diverted = 0 THEN 1 ELSE 0 END) AS total_departures_occurred,
        COUNT(DISTINCT tail_number) AS unique_airplanes_departing,
        COUNT(DISTINCT airline) AS unique_airlines_departing
    FROM flights
    GROUP BY origin, flight_date
),

arrivals AS (
    SELECT
        dest AS airport_code,
        flight_date,
        COUNT(DISTINCT origin) AS unique_arrival_connections,
        COUNT(*) AS total_arrivals_planned,
        SUM(CASE WHEN cancelled = 1 THEN 1 ELSE 0 END) AS total_arrivals_cancelled,
        SUM(CASE WHEN diverted = 1 THEN 1 ELSE 0 END) AS total_arrivals_diverted,
        SUM(CASE WHEN cancelled = 0 AND diverted = 0 THEN 1 ELSE 0 END) AS total_arrivals_occurred,
        COUNT(DISTINCT tail_number) AS unique_airplanes_arriving,
        COUNT(DISTINCT airline) AS unique_airlines_arriving
    FROM flights
    GROUP BY dest, flight_date
),

combined AS (
    SELECT
        COALESCE(d.airport_code, a.airport_code) AS airport_code,
        COALESCE(d.flight_date, a.flight_date) AS flight_date,
        COALESCE(d.unique_departure_connections, 0) AS unique_departure_connections,
        COALESCE(a.unique_arrival_connections, 0) AS unique_arrival_connections,
        COALESCE(d.total_departures_planned, 0) + COALESCE(a.total_arrivals_planned, 0) AS total_flights_planned,
        COALESCE(d.total_departures_cancelled, 0) + COALESCE(a.total_arrivals_cancelled, 0) AS total_flights_cancelled,
        COALESCE(d.total_departures_diverted, 0) + COALESCE(a.total_arrivals_diverted, 0) AS total_flights_diverted,
        COALESCE(d.total_departures_occurred, 0) + COALESCE(a.total_arrivals_occurred, 0) AS total_flights_occurred,
        (COALESCE(d.unique_airplanes_departing, 0) + COALESCE(a.unique_airplanes_arriving, 0)) / 2.0 AS avg_unique_airplanes,
        (COALESCE(d.unique_airlines_departing, 0) + COALESCE(a.unique_airlines_arriving, 0)) / 2.0 AS avg_unique_airlines
    FROM departures d
    FULL OUTER JOIN arrivals a
        ON d.airport_code = a.airport_code AND d.flight_date = a.flight_date
)

SELECT
    w.airport_code,
    w.date,
    ap.name,
    ap.city,
    ap.country,
    c.unique_departure_connections,
    c.unique_arrival_connections,
    c.total_flights_planned,
    c.total_flights_cancelled,
    c.total_flights_diverted,
    c.total_flights_occurred,
    c.avg_unique_airplanes,
    c.avg_unique_airlines,
    w.min_temp_c,
    w.max_temp_c,
    w.precipitation_mm,
    w.max_snow_mm,
    w.avg_wind_direction,
    w.avg_wind_speed_kmh,
    w.wind_peakgust_kmh
FROM weather w
INNER JOIN combined c
    ON w.airport_code = c.airport_code AND w.date = c.flight_date
LEFT JOIN airports ap ON w.airport_code = ap.faa