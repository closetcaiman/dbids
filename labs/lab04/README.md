# Lab 4 — Indexes and query optimizer (part 2)

Continuation of lab 3. Focus on index types, covering indexes, and transaction
locking behavior. Uses a custom `lab04db` database built on top of both
AdventureWorks2017 and Northwind data.

Datasets: **AdventureWorks 2017** and **Northwind** — see [`docs/datasets.md`](../../docs/datasets.md).

## Services

| Container | Image | Port | Credentials |
| --------- | ----- | ---- | ----------- |
| `mssql_server_lab04` | `mssql/server:2022-latest` | 1433 | `sa` / `Admin!1234` |

On first start, `setup-mssql.sh` restores AdventureWorks2017 from the `.bak`
file, loads Northwind (including `product_history`), and then runs
`setup-database.sql` to create `lab04db` with tables pulled from both. Allow
60–90 seconds before connecting.

## Start / stop

```bash
make up LAB=lab04
make down LAB=lab04
make clean LAB=lab04
```

## Render report

```bash
make pdf LAB=lab04
make pdf LAB=lab04 TARGET=solution
```

## Directory layout

```text
lab04/
├── docker-compose.yml
├── scripts/
│   ├── setup-mssql.sh        # entrypoint: restores AdventureWorks, loads Northwind,
│   │                         # then runs setup-database.sql
│   └── setup-database.sql    # creates lab04db by copying tables from northwind and
│                             # adventureworks; also creates saleshistory for exercises
├── template/
│   └── report.md
└── solution/
    ├── report.md
    ├── report.pdf
    └── media/
```
