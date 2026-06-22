# Lab 2 — SQL window functions (part 2)

Continuation of lab 1. More complex window function patterns, deeper query plan
analysis, and cross-engine comparison of execution strategies.

Dataset: **Northwind** — see [`docs/datasets.md`](../../docs/datasets.md).

## Services

| Container | Image | Port | Credentials |
| --------- | ----- | ---- | ----------- |
| `mssql_server_lab2` | `mssql/server:2022-latest` | 1433 | `sa` / `Admin!1234` |
| `postgres_server_lab2` | `postgres:16` | 5432 | `admin` / `admin`, db `postgres` |
| `sqlite_server_lab2` | `alpine` | — | file-based |

## Start / stop

```bash
make up LAB=lab2
make down LAB=lab2
make clean LAB=lab2
```

## Render report

```bash
make pdf LAB=lab2
make pdf LAB=lab2 TARGET=solution
```

## Directory layout

```text
lab2/
├── docker-compose.yml
├── scripts/
│   ├── setup-mssql-container.sh   # entrypoint: loads Northwind into MSSQL on first start
│   └── setup-sqlite-container.sh  # copies northwind.db and runs DDL+data on first start
├── template/
│   └── report.md    # blank exercise sheet
└── solution/
    ├── report.md
    ├── report.pdf
    └── media/
```
