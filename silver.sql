-- ============================================================
-- SILVER LAYER
-- Data cleaning and transformation
-- ============================================================


-- ============================================================
-- RIDES
-- Calculate ride duration and extract date/time attributes
-- ============================================================

CREATE OR REFRESH STREAMING TABLE main.diana_bike_proyects.rides AS

WITH ride_durations AS (

    SELECT
        ride_id,

        DATE(start_time) AS date_start,
        DATE(end_time) AS date_end,

        HOUR(start_time) AS hour_start,
        HOUR(end_time) AS hour_end,

        MINUTE(start_time) AS minute_start,
        MINUTE(end_time) AS minute_end,

        SECOND(start_time) AS sec_start,
        SECOND(end_time) AS sec_end,

        HOUR(start_time) * 3600
            + MINUTE(start_time) * 60
            + SECOND(start_time) AS start_time_sec,

        HOUR(end_time) * 3600
            + MINUTE(end_time) * 60
            + SECOND(end_time) AS end_time_sec,

        DATEDIFF(end_time, start_time) AS diff_days,

        DATEDIFF(
            SECOND,
            start_time,
            end_time
        ) AS ride_duration_seconds,

        start_station_id,
        end_station_id,
        bike_id,
        user_type,
        customer_id

    FROM STREAM(
        main.diana_bike_proyects.rides_raw
    )
)

SELECT *
FROM STREAM ride_durations
WHERE ride_duration_seconds > 0;


-- ============================================================
-- WEATHER
-- Convert Unix timestamp and round weather metrics
-- ============================================================

CREATE OR REFRESH STREAMING TABLE main.diana_bike_proyects.weather AS

SELECT
    DATE(FROM_UNIXTIME(timestamp / 1000)) AS weather_date,
    ROUND(rainfall_in, 2) AS rainfall_in,
    ROUND(temperature_f, 2) AS temperature_f,
    ROUND(wind_speed_mph, 2) AS wind_speed_mph

FROM STREAM main.diana_bike_proyects.weather_raw;


-- ============================================================
-- MAINTENANCE LOGS
-- Clean maintenance records and normalize dates
-- ============================================================

CREATE OR REFRESH STREAMING TABLE main.diana_bike_proyects.maintenance_logs AS

SELECT
    maintenance_id,
    bike_id,
    DATE(reported_time) AS reported_date,
    DATE(resolved_time) AS resolved_date,
    issue_description

FROM STREAM main.diana_bike_proyects.maintenance_logs_raw

WHERE issue_description IS NOT NULL;


-- ============================================================
-- CUSTOMERS
-- Prepare CDC data and convert timestamp fields
-- ============================================================

CREATE OR REFRESH STREAMING TABLE main.diana_bike_proyects.customers AS

SELECT
    customer_id,
    user_type,

    TO_TIMESTAMP(
        registration_date,
        'MM-dd-yyyy HH:mm:ss'
    ) AS registration_timestamp,

    email,
    phone,
    age_group,
    membership_tier,
    preferred_payment,
    home_station_id,
    is_active,
    operation,

    TO_TIMESTAMP(
        event_timestamp,
        'MM-dd-yyyy HH:mm:ss'
    ) AS event_timestamp

FROM STREAM(
    main.diana_bike_proyects.customers_cdc_raw
);