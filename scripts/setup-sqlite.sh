#!bin/bash

echo "Installing SQLite..."
apk add sqlite

echo "Setting up SQLite database with Northwind schema and data..."
sqlite3 database.db < northwind/sqlite_north_ddl.sql

echo "Inserting data into SQLite database..."
sqlite3 database.db < northwind/sqlite_north_data.sql

echo "SQLite setup complete. Database file: database.db"
