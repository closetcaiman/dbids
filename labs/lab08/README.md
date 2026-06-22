# Lab 8 — Document databases: Couchbase

Couchbase Community with the Northwind dataset. Covers the bucket/scope/collection
model, primary and secondary indexes, SQL++ (N1QL) queries, JOIN between
collections, UNNEST for nested arrays, and EXPLAIN plan reading.

Dataset: **Northwind** (JSON) — see [`docs/datasets.md`](../../docs/datasets.md).

## Services

| Container         | Image                       | Port                    | Credentials            |
| ----------------- | --------------------------- | ----------------------- | ---------------------- |
| `couchbase_lab08` | `couchbase:community-7.2.4` | 8091 (UI), 8093 (Query) | `admin` / `Admin!1234` |

Two init containers run automatically:

- `couchbase_init_lab08` — waits for the Couchbase REST API, then creates the
  `northwind` bucket, sets memory quotas, and creates a local `student` user
- `couchbase_import_lab08` — waits for the cluster to be ready, then imports
  all Northwind JSON files via `cbimport`, including the pre-nested
  `orders_nested` collection

Lab 8 uses the `init` Makefile profile, so `make up LAB=lab08` automatically
includes both init containers.

## Start / stop

```bash
make up LAB=lab08       # starts Couchbase + runs both init containers
make down LAB=lab08
make clean LAB=lab08
```

Open the Couchbase UI at <http://localhost:8091> and log in as `admin` /
`Admin!1234`.

## Render report

```bash
make pdf LAB=lab08
make pdf LAB=lab08 TARGET=solution
```

## Directory layout

```text
lab08/
├── docker-compose.yml
├── materials/
│   ├── Couchbase prezentacja.pdf   # lecture slides
│   └── Couchbase_sciaga.pdf        # N1QL / SQL++ cheat sheet
├── scripts/
│   ├── init.sh     # run by couchbase_init_lab08: creates bucket, memory settings,
│   │               # indexes, and the student user via the REST API
│   └── import.sh   # run by couchbase_import_lab08: calls cbimport for each
│                   # Northwind collection (orders, orderdetails, customers,
│                   # products, orders_nested)
├── template/
│   └── report.md
└── solution/
    ├── report.md
    ├── report.pdf
    └── media/
```
