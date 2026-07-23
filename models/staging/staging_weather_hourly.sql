WITH hourly_raw AS (
        SELECT
                airport_code,
                station_id,
                JSON_ARRAY_ELEMENTS(extracted_data -> 'data') AS json_data
        FROM {{source('weather_data', 'weather_hourly_raw')}}
    ),
    hourly_flattened AS (
					SELECT airport_code
							,station_id
							,(json_data ->> 'time')::TIMESTAMP AS time
							,(json_data ->> 'temp')::NUMERIC AS temp_c
							,(json_data ->> 'dwpt')::NUMERIC AS dew_point_c
							,(json_data ->> 'rhum')::NUMERIC AS relative_humidity_pct
							,(json_data ->> 'prcp')::NUMERIC AS precipitation_mm
							,(json_data ->> 'snow')::NUMERIC::INTEGER AS snow_mm
							,(json_data ->> 'wdir')::NUMERIC::INTEGER AS wind_direction
							,(json_data ->> 'wspd')::NUMERIC AS wind_speed
							,(json_data ->> 'wpgt')::NUMERIC AS peak_gust
							,(json_data ->> 'pres')::NUMERIC AS pressure_hpa
							,(json_data ->> 'tsun')::NUMERIC::INTEGER AS sun_minutes
							,(json_data ->> 'coco')::NUMERIC::INTEGER AS condition_code
						FROM hourly_raw
)
SELECT * FROM hourly_flattened;