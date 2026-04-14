#!/bin/bash

/opt/mssql/bin/sqlservr &

echo "Waiting for SQL Server to boot..."

for i in {1..60}; do
    /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "Admin!1234" -C -Q "SELECT 1" > /dev/null 2>&1

    if [ $? -eq 0 ]; then
        echo "SQL Server is READY!"
        
        echo "Setting up Northwind database schema..."
        /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "Admin!1234" -C -i /data/sql/mssql_north_ddl.sql

        echo "Inserting data into Northwind database..."
        /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "Admin!1234" -C -i /data/sql/mssql_north_data.sql
        
        echo "Import complete."
        break
    else
        echo "Still waiting... (Attempt $i)"
        sleep 2
    fi
done

wait