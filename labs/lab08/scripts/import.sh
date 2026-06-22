#!/bin/sh
set -e

CB_HOST="couchbase"
CB_UI="http://$CB_HOST:8091"
ADMIN_USER="admin"
ADMIN_PASS="Admin!1234"

BUCKET="northwind"
SCOPE="_default"

DATA_DIR="/data/northwind"

echo "[cb-import] Waiting for Couchbase REST API..."
until curl -s "$CB_UI/pools" >/dev/null; do
  sleep 2
done

echo "[cb-import] Waiting for Couchbase cluster initialization..."
until curl -s -u "$ADMIN_USER:$ADMIN_PASS" "$CB_UI/pools/default" | grep -q '"nodes"'; do
  sleep 2
done

echo "[cb-import] Waiting for Query service (8093)..."
until curl -s -u "$ADMIN_USER:$ADMIN_PASS" "http://$CB_HOST:8093/admin/ping" | grep -q "OK"; do
  sleep 2
done

# 1) Bucket musi istnieć
if ! curl -s -u "$ADMIN_USER:$ADMIN_PASS" "$CB_UI/pools/default/buckets/$BUCKET" >/dev/null; then
  echo "[cb-import] ERROR: Bucket '$BUCKET' not found. Run couchbase_init first."
  exit 1
fi

import_collection () {
  COLL="$1"
  FILE="$DATA_DIR/$1.json"

  if [ ! -f "$FILE" ]; then
    echo "[cb-import] WARNING: missing $FILE (skip)"
    return 0
  fi

  echo "[cb-import] Importing $FILE into $BUCKET.$SCOPE.$COLL ..."

  # kolekcja powinna już istnieć z init.sh, ale zostawiamy idempotentnie
  curl -s -u "$ADMIN_USER:$ADMIN_PASS" -X POST \
    "$CB_UI/pools/default/buckets/$BUCKET/scopes/$SCOPE/collections" \
    -d "name=$COLL" >/dev/null || true

  /opt/couchbase/bin/cbimport json \
    -c "$CB_UI" \
    -u "$ADMIN_USER" -p "$ADMIN_PASS" \
    -b "$BUCKET" \
    --scope-collection-exp "$SCOPE.$COLL" \
    -d "file://$FILE" \
    --format list \
    --generate-key "#UUID#"
}

run_query () {
  STMT="$1"

  echo "[cb-import] Running SQL++ query..."
  curl -s -u "$ADMIN_USER:$ADMIN_PASS" \
    "http://$CB_HOST:8093/query/service" \
    --data-urlencode "statement=$STMT" \
    -d "scan_consistency=request_plus"
  echo
}

for c in categories customers employees orders orderdetails products shippers suppliers; do
  import_collection "$c"
done

echo "[cb-import] Creating indexes for nested orders demo..."

run_query "CREATE INDEX idx_orders_orderid ON \`northwind\`._default.orders(OrderID);"

run_query "CREATE INDEX idx_orderdetails_orderid ON \`northwind\`._default.orderdetails(OrderID);"

echo "[cb-import] Building orders_nested collection..."

run_query "
UPSERT INTO \`northwind\`._default.orders_nested (KEY k, VALUE v)
SELECT
  'order::' || TO_STRING(o.OrderID) AS k,
  {
    'type': 'order_nested',
    'OrderID': o.OrderID,
    'CustomerID': o.CustomerID,
    'EmployeeID': o.EmployeeID,
    'OrderDate': o.OrderDate,
    'ShipName': o.ShipName,
    'ShipCity': o.ShipCity,
    'ShipCountry': o.ShipCountry,
    'items': ARRAY_AGG({
      'ProductID': od.ProductID,
      'UnitPrice': od.UnitPrice,
      'Quantity': od.Quantity,
      'Discount': IFMISSINGORNULL(od.Discount, 0),
      'LineValue': od.UnitPrice * od.Quantity * (1 - IFMISSINGORNULL(od.Discount, 0))
    })
  } AS v
FROM \`northwind\`._default.orders AS o
JOIN \`northwind\`._default.orderdetails AS od
  ON od.OrderID = o.OrderID
WHERE o.OrderID IS NOT MISSING
  AND od.OrderID IS NOT MISSING
GROUP BY
  o.OrderID,
  o.CustomerID,
  o.EmployeeID,
  o.OrderDate,
  o.ShipName,
  o.ShipCity,
  o.ShipCountry;
"

run_query "CREATE INDEX idx_orders_nested_orderid ON \`northwind\`._default.orders_nested(OrderID);"


echo "[cb-import] Done."
