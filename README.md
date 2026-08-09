# 🚲 Bike Sharing Databricks ETL

End-to-end data engineering project built with Databricks to ingest, transform, and prepare bike-sharing data for analytics using the Medallion Architecture.

## 📌 Project Overview

This project implements an ETL pipeline for a bike-sharing platform using Databricks.

The pipeline processes data from multiple sources and formats, applies transformations and data cleaning, and creates business-ready datasets for analytics.

The project follows the Medallion Architecture:

Raw Data → Bronze → Silver → Gold

## 🏗️ Architecture

```text
                    RAW DATA
                       │
        ┌──────────────┼──────────────┐
        │              │              │
       CSV            JSON          Parquet
        │              │              │
        └──────────────┼──────────────┘
                       │
                       ▼
                 🥉 BRONZE
              Raw Data Ingestion
                       │
                       ▼
                 🥈 SILVER
            Cleaning & Transformation
                       │
                       ▼
                  🥇 GOLD
             Business-ready Data
                       │
                       ▼
                  Analytics


<img width="1255" height="780" alt="image" src="https://github.com/user-attachments/assets/050f5308-8a04-492d-b80a-58b1f2fb020c" />
