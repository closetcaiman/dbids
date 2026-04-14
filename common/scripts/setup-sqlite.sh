#!/bin/bash
apk add --no-cache sqlite

DB_FILE="/data/db/northwind.db"
DDL_FILE="/data/sql/sqlite_north_ddl.sql"
DATA_FILE="/data/sql/sqlite_north_data.sql"

if [ ! -f "$DB_FILE" ]; then
    echo "Initializing SQLite Northwind..."

    mkdir -p /data/db
    
    echo "Setting up SQLite database schema..."
    sqlite3 "$DB_FILE" < "$DDL_FILE"
    
    echo "Inserting data into SQLite database..."
    sqlite3 "$DB_FILE" < "$DATA_FILE"
else
    echo "Database already exists at $DB_FILE. Skipping initialization."
fi

echo "SQLite ready."