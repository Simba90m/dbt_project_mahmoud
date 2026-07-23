WITH flights AS (
    SELECT * FROM {{ ref('prep_flights') }}
),
airports AS (
    SELECT * FROM {{ ref('prep_airports') }}
),

departures AS (
    SELECT
        origin AS faa,
        COUNT(DISTINCT dest) AS unique_departure_connections,
        COUNT(*) AS total_departures_planned,
        SUM(CASE WHEN cancelled = 1 THEN 1 ELSE 0 END) AS total_departures_cancelled,
        SUM(CASE WHEN diverted = 1 THEN 1 ELSE 0 END) AS total_departures_diverted,
        SUM(CASE WHEN cancelled = 0 AND diverted = 0 THEN 1 ELSE 0 END) AS total_departures_occurred,
        COUNT(DISTINCT tail_number) AS unique_airplanes_departing,
        COUNT(DISTINCT airline) AS unique_airlines_departing
    FROM flights
    GROUP BY origin
),

arrivals AS (
    SELECT
        dest AS faa,
        COUNT(DISTINCT origin) AS unique_arrival_connections,
        COUNT(*) AS total_arrivals_planned,
        SUM(CASE WHEN cancelled = 1 THEN 1 ELSE 0 END) AS total_arrivals_cancelled,
        SUM(CASE WHEN diverted = 1 THEN 1 ELSE 0 END) AS total_arrivals_diverted,
        SUM(CASE WHEN cancelled = 0 AND diverted = 0 THEN 1 ELSE 0 END) AS total_arrivals_occurred,
        COUNT(DISTINCT tail_number) AS unique_airplanes_arriving,
        COUNT(DISTINCT airline) AS unique_airlines_arriving
    FROM flights
    GROUP BY dest
),

combined AS (
    SELECT
        COALESCE(d.faa, a.faa) AS faa,
        COALESCE(d.unique_departure_connections, 0) AS unique_departure_connections,
        COALESCE(a.unique_arrival_connections, 0) AS unique_arrival_connections,
        COALESCE(d.total_departures_planned, 0) + COALESCE(a.total_arrivals_planned, 0) AS total_flights_planned,
        COALESCE(d.total_departures_cancelled, 0) + COALESCE(a.total_arrivals_cancelled, 0) AS total_flights_cancelled,
        COALESCE(d.total_departures_diverted, 0) + COALESCE(a.total_arrivals_diverted, 0) AS total_flights_diverted,
        COALESCE(d.total_departures_occurred, 0) + COALESCE(a.total_arrivals_occurred, 0) AS total_flights_occurred,
        (COALESCE(d.unique_airplanes_departing, 0) + COALESCE(a.unique_airplanes_arriving, 0)) / 2.0 AS avg_unique_airplanes,
        (COALESCE(d.unique_airlines_departing, 0) + COALESCE(a.unique_airlines_arriving, 0)) / 2.0 AS avg_unique_airlines
    FROM departures d
    FULL OUTER JOIN arrivals a ON d.faa = a.faa
)

SELECT
    c.faa,
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
    c.avg_unique_airlines
FROM combined c
LEFT JOIN airports ap ON c.faa = ap.faa