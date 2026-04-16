#!/bin/bash

set -e

ROOT="$(git rev-parse --show-toplevel)"

RECOMMENDATIONS_SQL_FILE="${ROOT}/common/sql/adventure-works/recommendations.sql"

echo "Aplying recommendations in SQL Server..."
bash ${ROOT}/common/scripts/mssql-transaction.sh mssql_server_lab3 "$RECOMMENDATIONS_SQL_FILE"
echo "Recommendations applied successfully."