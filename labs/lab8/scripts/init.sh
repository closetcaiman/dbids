#!/bin/sh
set -e

CB_HOST="http://couchbase:8091"
ADMIN_USER="admin"
ADMIN_PASS="Admin!1234"
BUCKET="northwind"
BUCKET_RAM_MB="256"
APP_USER="admin"
APP_PASS="admin"

echo "[init] Waiting for Couchbase REST API..."
until curl -s "$CB_HOST/pools" >/dev/null; do
  sleep 2
done

# Jeśli klaster już zainicjalizowany (np. po restarcie), to kończymy
if curl -s "$CB_HOST/pools/default" | grep -q '"nodes"'; then
  echo "[init] Couchbase seems initialized already. Exiting."
  exit 0
fi

echo "[init] Initializing cluster..."
curl -s -X POST "$CB_HOST/pools/default" \
  -d "memoryQuota=1024" \
  -d "indexMemoryQuota=256" >/dev/null

curl -s -X POST "$CB_HOST/node/controller/setupServices" \
  -d "services=kv,n1ql,index" >/dev/null

curl -s -X POST "$CB_HOST/settings/web" \
  -d "port=8091" \
  -d "username=$ADMIN_USER" \
  -d "password=$ADMIN_PASS" >/dev/null

echo "[init] Setting index storage mode (Community -> forestdb)..."
curl -s -u "$ADMIN_USER:$ADMIN_PASS" -X POST "$CB_HOST/settings/indexes" \
  -d "storageMode=forestdb" >/dev/null

echo "[init] Creating bucket $BUCKET..."
curl -s -u "$ADMIN_USER:$ADMIN_PASS" -X POST "$CB_HOST/pools/default/buckets" \
  -d "name=$BUCKET" \
  -d "bucketType=couchbase" \
  -d "ramQuotaMB=$BUCKET_RAM_MB" \
  -d "flushEnabled=1" >/dev/null

echo "[init] Creating collections in $BUCKET._default ..."
for c in categories customers employees orders orderdetails products shippers suppliers orders_nested; do
  curl -s -u "$ADMIN_USER:$ADMIN_PASS" -X POST \
    "$CB_HOST/pools/default/buckets/$BUCKET/scopes/_default/collections" \
    -d "name=$c" >/dev/null || true
done

echo "[init] Creating user $APP_USER..."
curl -s -u "$ADMIN_USER:$ADMIN_PASS" -X PUT "$CB_HOST/settings/rbac/users/local/$APP_USER" \
  -d "name=$APP_USER" \
  -d "password=$APP_PASS" \
  -d "roles=admin" >/dev/null

echo "[init] Done."
