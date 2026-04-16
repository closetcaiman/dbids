#!/bin/bash

set -e

ROOT="$(git rev-parse --show-toplevel)"

ALTER_DTA_INDEX="${ROOT}/common/sql/adventure-works/alter-mssql-dta-index.sql"

echo "Applying DTA index alterations in SQL Server..."
bash ${ROOT}/common/scripts/mssql-transaction.sh mssql_server_lab3 "$ALTER_DTA_INDEX"
echo "DTA index alterations applied successfully."