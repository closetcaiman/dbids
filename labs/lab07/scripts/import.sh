#!/bin/sh
set -e

MONGO_HOST="localhost"
MONGO_PORT="27017"
DB="north0"
DATA_DIR="/data/northwind"

echo "[mongo-import] Starting import into $DB..."

for collection in categories customers employees orderdetails orders products shippers suppliers; do
  FILE="$DATA_DIR/$collection.json"
  if [ ! -f "$FILE" ]; then
    echo "[mongo-import] WARNING: $FILE not found (skip)"
    continue
  fi
  echo "[mongo-import] Importing $collection..."
  mongoimport \
    --host "$MONGO_HOST:$MONGO_PORT" \
    --db "$DB" \
    --collection "$collection" \
    --file "$FILE" \
    --jsonArray \
    --drop
done

echo "[mongo-import] Done."
