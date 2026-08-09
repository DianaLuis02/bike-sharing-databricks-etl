-- ============================================================
-- BRONZE LAYER
-- Raw data ingestion using Lakeflow Streaming Tables
-- ============================================================


-- ============================================================
-- RIDES
-- Source: CSV files
-- ============================================================

CREATE OR REFRESH STREAMING TABLE main.diana_bike_proyects.rides_raw
COMMENT 'Raw rides data ingested from CSV files'
AS
SELECT *
FROM STREAM read_files(
    '/Volumes/main/diana_bike_proyects/raw_data/rides/',
    format => 'csv',
    inferSchema => true,
    header => true
);


-- ============================================================
-- WEATHER
-- Source: JSON files
-- ============================================================

CREATE OR REFRESH STREAMING TABLE main.diana_bike_proyects.weather_raw
COMMENT 'Raw weather data ingested from JSON files'
AS
SELECT *
FROM STREAM read_files(
    '/Volumes/main/diana_bike_proyects/raw_data/weather/',
    format => 'json',
    inferSchema => true
);


-- ============================================================
-- MAINTENANCE LOGS
-- Source: CSV files
-- ============================================================

CREATE OR REFRESH STREAMING TABLE main.diana_bike_proyects.maintenance_logs_raw
COMMENT 'Raw maintenance log data ingested from CSV files'
AS
SELECT *
FROM STREAM read_files(
    '/Volumes/main/diana_bike_proyects/raw_data/maintenance_logs/',
    format => 'csv',
    inferSchema => true,
    header => true
);


-- ============================================================
-- CUSTOMERS CDC
-- Source: Parquet files
-- ============================================================

CREATE OR REFRESH STREAMING TABLE main.diana_bike_proyects.customers_cdc_raw
COMMENT 'Raw customer CDC data ingested from Parquet files'
AS
SELECT *
FROM STREAM read_files(
    '/Volumes/main/diana_bike_proyects/raw_data/customers_cdc/',
    format => 'parquet',
    inferSchema => true
);