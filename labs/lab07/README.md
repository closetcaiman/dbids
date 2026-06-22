# Lab 7 — Document databases: MongoDB

Introduction to MongoDB. The exercise builds complex document aggregations over
the Northwind dataset (customers, orders, products imported as JSON collections).

Dataset: **Northwind** (JSON) — see [`docs/datasets.md`](../../docs/datasets.md).

## Services

| Container | Image | Port | Credentials |
| --------- | ----- | ---- | ----------- |
| `mongo_lab07` | `mongo:7` | 27017 | no auth (dev mode) |

`mongo_import_lab07` is a one-shot init container defined under the `init`
profile. It imports all Northwind collections into the `north0` database using
`mongoimport`. Regular `make up` skips it — run with `COMPOSE_PROFILES=init`
the first time, or just run it once manually after the main container is up.

```bash
# First-time setup (imports data)
COMPOSE_PROFILES=init make up LAB=lab07

# Subsequent starts (data is in the volume already)
make up LAB=lab07
```

## Stop / clean

```bash
make down LAB=lab07
make clean LAB=lab07
```

## Directory layout

```text
lab07/
├── docker-compose.yml
├── exercises/
│   ├── mongodb-exericse-1.pdf   # exercise sheet part 1
│   └── mongodb-exercise-2.pdf   # exercise sheet part 2
├── scripts/
│   └── import.sh   # run by mongo_import_lab07: loops over common/data/northwind/*.json
│                   # and calls mongoimport for each collection into north0
├── template/
│   └── report.md   # blank exercise (this lab has no submitted solution)
└── solution/
    └── (empty — lab not submitted)
```

> **Note:** This lab has no completed solution. `template/report.md` is the
> original exercise sheet only.
