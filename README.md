# MySQL-project - cleansing layoffs data

This is a simple data cleansing project using MySQL and Python.
It based on https://www.youtube.com/watch?v=4UltKCnnnTA&t=168s.

The goal is to load raw layoffs data into a database, apply SQL-based transformations, and produce a cleaned dataset.

## Setup Instructions

1. **Start the environment/database**
   ```bash
   docker compose up -d
   ```
This will start a MySQL container and run init.sql to create DB schema.
You can connect to the database using your local MySQL Workbench or through Docker’s Admirer UI (on [localhost](http://localhost:8080)).

2. **Load raw data**
   ```bash
   python3 src/app.py
   ```
This script uses pandas to load the raw data in batches into the MySQL database.

2. **Clean the data**
   ```bash
   src/data-cleaning.sql
   ```
These queries demonstrate the cleansing process.


## Project Structure

```bash
.
├── data                  # raw data
│   └── layoffs.csv
├── db-scripts            # initialization SQL scripts (executed on container startup)
│   └── init.sql
├── docker-compose.yml    # Docker setup for MySQL
├── README.md
└── src
    ├── app.py             # Python script to load raw data into MySQL
    ├── data_cleansing.sql # SQL transformations for data cleansing
    └── utils              # Python helpers
        └── path.py
```

## Solution Approach

**Data Ingestion:** Python + pandas loads CSV/raw files into MySQL.
**Data Cleansing:** SQL queries apply transformations, handle duplicates, and standardize values.
**Outcome:** A clean dataset ready for further analysis or reporting.