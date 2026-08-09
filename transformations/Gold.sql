
-- ============================================================
-- GOLD LAYER
-- Business-ready tables for analytics
-- ============================================================


-- ============================================================
-- RIDES + LAST MAINTENANCE LOG
--
-- Combines ride information with the latest maintenance
-- record for each bike.
-- ============================================================

CREATE OR REFRESH MATERIALIZED VIEW
main.diana_bike_proyects.rides_and_maintenance_logs_gold AS

WITH unique_maintenance_logs AS (

    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY bike_id
            ORDER BY reported_date DESC
        ) AS row_number

    FROM main.diana_bike_proyects.maintenance_logs
)

SELECT
    r.ride_id,
    r.date_start,
    r.date_end,
    r.start_time_sec,
    r.end_time_sec,
    r.start_station_id,
    r.end_station_id,
    r.ride_duration_seconds,
    r.bike_id,
    r.user_type,
    r.customer_id,

    m.maintenance_id,
    m.reported_date,
    m.resolved_date,

    CASE
        WHEN m.issue_description IS NULL
            THEN 'There are no reported problems'
        ELSE m.issue_description
    END AS issue_description

FROM main.diana_bike_proyects.rides r

LEFT JOIN unique_maintenance_logs m
    ON r.bike_id = m.bike_id
    AND m.row_number = 1

WHERE r.date_start >= ADD_MONTHS(CURRENT_DATE(), -1);


-- ============================================================
-- STATIONS
--
-- Calculates daily ride activity and bike inventory
-- for each station.
-- ============================================================

CREATE OR REFRESH MATERIALIZED VIEW
main.diana_bike_proyects.stations_gold AS


-- Count rides starting at each station
WITH start_stations AS (

    SELECT
        COUNT(DISTINCT ride_id) AS count_start_stations,
        date_start,
        start_station_id

    FROM main.diana_bike_proyects.rides

    GROUP BY
        start_station_id,
        date_start
),


-- Count rides ending at each station
end_stations AS (

    SELECT
        COUNT(DISTINCT ride_id) AS count_end_stations,
        date_end,
        end_station_id

    FROM main.diana_bike_proyects.rides

    GROUP BY
        end_station_id,
        date_end
),


-- Identify the last ride of each bike for each day
inventory AS (

    SELECT
        date_end,
        bike_id,
        ride_id,
        end_station_id,
        end_time_sec,

        ROW_NUMBER() OVER (
            PARTITION BY bike_id, date_end
            ORDER BY end_time_sec DESC
        ) AS row_number

    FROM main.diana_bike_proyects.rides
),


-- Keep only the last ride of each bike per day
last_rides AS (

    SELECT *

    FROM inventory

    WHERE row_number = 1
),


-- Calculate daily bike inventory by station
end_inventory AS (

    SELECT
        date_end,
        end_station_id,
        COUNT(DISTINCT bike_id) AS end_inventory_day

    FROM last_rides

    GROUP BY
        date_end,
        end_station_id
)


-- ============================================================
-- FINAL STATION METRICS
-- ============================================================

SELECT

    COALESCE(
        s.start_station_id,
        e.end_station_id
    ) AS station_id,

    COALESCE(
        s.count_start_stations,
        0
    ) AS count_start_stations,

    COALESCE(
        e.count_end_stations,
        0
    ) AS count_end_stations,

    COALESCE(
        s.date_start,
        e.date_end
    ) AS ride_date,

    i.end_station_id AS inventory_station,

    COALESCE(
        i.end_inventory_day,
        0
    ) AS inventory_day

FROM start_stations s

FULL JOIN end_stations e
    ON s.start_station_id = e.end_station_id
    AND s.date_start = e.date_end

LEFT JOIN end_inventory i
    ON COALESCE(
        s.start_station_id,
        e.end_station_id
    ) = i.end_station_id

    AND COALESCE(
        s.date_start,
        e.date_end
    ) = i.date_end;