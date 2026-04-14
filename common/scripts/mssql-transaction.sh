#! /bin/bash

set -e

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: ./mssql-transaction.sh <container_name> <path/to/transaction.sql>"
    exit 1
fi

CONTAINER_NAME="$1"
SQL_FILE="$2"
    
if [ ! -f "$SQL_FILE" ]; then
    echo "Error: SQL file '$SQL_FILE' not found."
    exit 1
fi

echo "Executing transaction script '$SQL_FILE' on container '$CONTAINER_NAME'..."

cat "$SQL_FILE" | docker exec -i "$CONTAINER_NAME" /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "Admin!1234" -C

echo "Transaction script executed successfully."