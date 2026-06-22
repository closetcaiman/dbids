# Lab 4 — Indexes and query optimizer (part 2)

Continuation of lab 3. Focus on index types, covering indexes, and transaction
locking behavior. Uses a custom `lab4db` database built on top of both
AdventureWorks2017 and Northwind data.

Datasets: **AdventureWorks 2017** and **Northwind** — see [`docs/datasets.md`](../../docs/datasets.md).

## Services

| Container | Image | Port | Credentials |
| --------- | ----- | ---- | ----------- |
| `mssql_server_lab4` | `mssql/server:2022-latest` | 1433 | `sa` / `Admin!1234` |

On first start, `setup-mssql.sh` restores AdventureWorks2017 from the `.bak`
file, loads Northwind (including `product_history`), and then runs
`setup-database.sql` to create `lab4db` with tables pulled from both. Allow
60–90 seconds before connecting.

## Start / stop

```bash
make up LAB=lab4
make down LAB=lab4
make clean LAB=lab4
```

## Render report

```bash
make pdf LAB=lab4
make pdf LAB=lab4 TARGET=solution
```

## Directory layout

```text
lab4/
├── docker-compose.yml
├── scripts/
│   ├── setup-mssql.sh        # entrypoint: restores AdventureWorks, loads Northwind,
│   │                         # then runs setup-database.sql
│   └── setup-database.sql    # creates lab4db by copying tables from northwind and
│                             # adventureworks; also creates saleshistory for exercises
├── template/
│   └── report.md
└── solution/
    ├── report.md
    ├── report.pdf
    └── media/
```
