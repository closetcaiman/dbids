#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_ROOT="$(dirname "$SCRIPT_DIR")"
ROOT="$(git rev-parse --show-toplevel)"

POSTGRES_SQL_FILE="${ROOT}/common/sql/northwind/postgres/pg_north_ph.sql"
MSSQL_SQL_FILE="${ROOT}/common/sql/northwind/mssql/mssql_north_ph.sql"
SQLITE_SQL_FILE="${ROOT}/common/sql/northwind/sqlite/sqlite_north_ph.sql"

echo "Setting up Product History in PostgreSQL..."
bash ${ROOT}/common/scripts/postgres-transaction.sh postgres_server_lab1 "$POSTGRES_SQL_FILE"
echo "Product History setup in PostgreSQL completed successfully."

echo "Setting up Product History in SQL Server..."
bash ${ROOT}/common/scripts/mssql-transaction.sh mssql_server_lab1 "$MSSQL_SQL_FILE"
echo "Product History setup in SQL Server completed successfully."

echo "Setting up Product History in SQLite..."
bash ${ROOT}/common/scripts/sqlite-transaction.sh sqlite_server_lab1 db/northwind-lab1.db "$SQLITE_SQL_FILE"
echo "Product History setup in SQLite completed successfully."

echo "All Product History setups completed successfully."