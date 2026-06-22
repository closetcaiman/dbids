# Datasets

## Northwind

A trading company database originally shipped with Microsoft Access and SQL
Server as a sample. It models customers, employees, orders, products,
suppliers, and shippers for a fictional food importer called Northwind Traders.

Used in labs 1, 2, 3 (alongside AdventureWorks), 4, 7, and 8. Schema diagrams
are in `docs/plans/northwind/`.

Main tables: categories, customers, employees, order_details, orders, products,
shippers, suppliers.

The dataset ships in three forms:

| Variant | Location | Format |
| ------- | -------- | ------ |
| SQL DDL + data | `common/sql/northwind/{mssql,postgres,sqlite}/` | `.sql` files |
| JSON collections | `common/data/northwind/*.json` | one file per collection, used by MongoDB and Couchbase |
| product\_history extension | `common/sql/northwind/*/northwind_*_ph.sql` | adds a `product_history` table for transaction exercises |

The `product_history` table is not loaded by default. Run
`labs/lab1/scripts/create-product-history.sh` after `make up LAB=lab1` to add
it to all three engines.

---

## AdventureWorks 2017

Microsoft's larger sample database for SQL Server, based on a fictional bicycle
manufacturer. Used in labs 3 and 4 for index tuning and query optimization
exercises. The larger data volume makes execution plan differences visible in a
way that Northwind doesn't.

`common/backups/AdventureWorks2017.bak` is restored automatically on container
start by `setup-mssql.sh`.

Official docs: <https://learn.microsoft.com/en-us/sql/samples/adventureworks-install-configure>

---

## Events (synthetic e-commerce clickstream)

A generated dataset of user activity on an online shop: page views,
add-to-cart events, and purchases. Each row has a timestamp, user, session,
country, device, product, price, and quantity. Used in labs 5 and 6.

`common/dockerfiles/events-generator/` runs once as a Docker service on
`make up`, writes CSV files to `labs/lab{5,6}/data/`, then exits. PostgreSQL
and ClickHouse load the files via init scripts in `common/sql/events/`.

Around 100 000 rows per lab run (configurable via generator parameters). The
table is named `events` in PostgreSQL (`public` schema) and ClickHouse
(`ds_lab` database).

---

## Retail (synthetic transactional dataset)

A retail business dataset with customers, products, orders, order items, and a
pre-aggregated `fact_sales` table. Also includes intentionally dirty tables
(`customers_dirty`, `orders_dirty`) for data-cleaning exercises. Used in labs
9 and 10.

`common/dockerfiles/retail-generator/` produces CSV files in
`labs/lab{9,10}/data/`. `common/dockerfiles/sqlite-loader/` then creates a
SQLite database at `labs/lab{9,10}/db/northwind_plus.db`.

Data dictionary: `docs/plans/retail/DATA_DICTIONARY.md`.

Available in PostgreSQL (`retail` schema), ClickHouse (`retail` database), and
SQLite (`northwind_plus.db`).
