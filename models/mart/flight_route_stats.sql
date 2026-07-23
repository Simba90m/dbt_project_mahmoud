WITH flights AS (
    SELECT * FROM {{ ref('prep_flights') }}
),
airports AS (
    SELECT * FROM {{ ref('prep_airports') }}
),

route_stats AS (
    SELECT
        origin,
        dest,
        COUNT(*) AS total_flights,
        COUNT(DISTINCT tail_number) AS unique_airplanes,
        COUNT(DISTINCT airline) AS unique_airlines,
        AVG(actual_elapsed_time) AS avg_actual_elapsed_time,
        AVG(arr_delay) AS avg_arrival_delay,
        MAX(arr_delay) AS max_arrival_delay,
        MIN(arr_delay) AS min_arrival_delay,
        SUM(CASE WHEN cancelled = 1 THEN 1 ELSE 0 END) AS total_cancelled,
        SUM(CASE WHEN diverted = 1 THEN 1 ELSE 0 END) AS total_diverted
    FROM flights
    GROUP BY origin, dest
)

SELECT
    rs.origin,
    origin_ap.name AS origin_name,
    origin_ap.city AS origin_city,
    origin_ap.country AS origin_country,
    rs.dest,
    dest_ap.name AS dest_name,
    dest_ap.city AS dest_city,
    dest_ap.country AS dest_country,
    rs.total_flights,
    rs.unique_airplanes,
    rs.unique_airlines,
    rs.avg_actual_elapsed_time,
    rs.avg_arrival_delay,
    rs.max_arrival_delay,
    rs.min_arrival_delay,
    rs.total_cancelled,
    rs.total_diverted
FROM route_stats rs
LEFT JOIN airports origin_ap ON rs.origin = origin_ap.faa
LEFT JOIN airports dest_ap ON rs.dest = dest_ap.faa