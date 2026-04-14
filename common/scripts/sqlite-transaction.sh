#! /bin/bash

set -e

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    echo "Usage: ./sqlite-transaction.sh <container_name> <database_file> <path/to/transaction.sql>"
    exit 1
fi

CONTAINER_NAME="$1"
DATABASE_FILE="$2"
SQL_FILE="$3"
    
if [ ! -f "$SQL_FILE" ]; then
    echo "Error: SQL file '$SQL_FILE' not found."
    exit 1
fi

echo "Executing transaction script '$SQL_FILE' on container '$CONTAINER_NAME'..."

cat "$SQL_FILE" | docker exec -i "$CONTAINER_NAME" sqlite3 "$DATABASE_FILE"

echo "Transaction script executed successfully."