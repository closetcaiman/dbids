#! /bin/bash

/opt/mssql/bin/sqlservr &

echo "Waiting for SQL Server to boot..."

for i in {1..60}; do
    /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "Admin!1234" -C -Q "SELECT 1" > /dev/null 2>&1

    if [ $? -eq 0 ]; then
        echo "SQL Server is READY!"
        
        echo "Restoring AdventureWorks2017 database..."
        /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "Admin!1234" -C -i /data/sql/mssql_restore_db.sql

        echo "Setting up AdventureWorks2017 shallow copy..."
        /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "Admin!1234" -C -i /data/sql/mssql_advworks_ddl_data.sql

        echo "Setup complete."
        break
    else
        echo "Still waiting... (Attempt $i)"
        sleep 2
    fi
done

wait