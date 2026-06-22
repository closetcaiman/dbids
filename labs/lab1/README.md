# Lab 1 — SQL window functions (part 1)

Introduction to window functions in SQL. The exercise runs the same queries
against three engines (MSSQL, PostgreSQL, SQLite) so you can compare syntax
and query plan differences side by side.

Dataset: **Northwind** — see [`docs/datasets.md`](../../docs/datasets.md).

## Services

| Container | Image | Port | Credentials |
| --------- | ----- | ---- | ----------- |
| `mssql_server_lab1` | `mssql/server:2022-latest` | 1433 | `sa` / `Admin!1234` |
| `postgres_server_lab1` | `postgres:16` | 5432 | `admin` / `admin`, db `postgres` |
| `sqlite_server_lab1` | `alpine` | — | file-based |

## Start / stop

```bash
make up LAB=lab1      # start all three containers
make down LAB=lab1    # stop, keep volumes
make clean LAB=lab1   # stop, remove volumes and generated db/ files
```

## Render report

```bash
make pdf LAB=lab1              # render template/report.md → template/report.pdf
make pdf LAB=lab1 TARGET=solution  # render solution
```

## Directory layout

```text
lab1/
├── docker-compose.yml
├── scripts/
│   ├── setup-mssql-container.sh     # entrypoint: restores Northwind into MSSQL on first start
│   ├── setup-sqlite-container.sh    # copies northwind.db and runs the DDL+data SQL on first start
│   └── create-product-history.sh    # run manually after `make up` to create the product_history
│                                    # table in all three engines (used in later exercises)
├── template/
│   ├── report.md    # blank exercise sheet
│   └── _img/        # diagrams embedded in the template
└── solution/
    ├── report.md    # completed solution
    ├── report.pdf
    └── media/       # screenshots referenced by solution/report.md
```

### About `create-product-history.sh`

Run this after `make up` when the exercise asks for the `product_history` table.
It pipes `common/sql/northwind/*/northwind_*_ph.sql` into each running container
using the shared transaction helpers in `common/scripts/`.
