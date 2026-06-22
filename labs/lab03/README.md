# Lab 3 — Indexes and query optimizer (part 1)

Execution plans, index design, and the Database Engine Tuning Advisor (DTA) in
MS SQL Server, using the AdventureWorks2017 sample database.

Dataset: **AdventureWorks 2017** — see [`docs/datasets.md`](../../docs/datasets.md).

## Services

| Container            | Image                      | Port | Credentials         |
| -------------------- | -------------------------- | ---- | ------------------- |
| `mssql_server_lab03` | `mssql/server:2022-latest` | 1433 | `sa` / `Admin!1234` |

AdventureWorks2017 is restored from `common/backups/AdventureWorks2017.bak`
automatically on first start. The restore takes 30–60 seconds before the
database is queryable.

## Start / stop

```bash
make up LAB=lab03
make down LAB=lab03
make clean LAB=lab03
```

## Render report

```bash
make pdf LAB=lab03
make pdf LAB=lab03 TARGET=solution
```

## Directory layout

```text
lab03/
├── docker-compose.yml
├── scripts/
│   ├── setup-mssql.sh              # entrypoint: mounts the .bak and runs RESTORE DATABASE
│   ├── mssql_advworks_ddl_data.sql # additional DDL applied after the restore (extra tables/data)
│   ├── add-recommendations.sh      # apply DTA-generated index recommendations via
│   │                               # common/sql/adventure-works/recommendations.sql
│   ├── fix-dta-reports-error.sh    # workaround for a DTA schema bug (alters a column nullability
│   │                               # in msdb so the DTA report INSERT stops failing)
│   ├── alter-mssql-dta-index.sql   # the specific ALTER INDEX statement produced by DTA
│   └── recommendations.sql         # full set of CREATE INDEX statements from DTA output
├── template/
│   ├── report.md
│   └── _img/    # diagrams provided with the exercise
└── solution/
    ├── report.md
    ├── report.pdf
    └── media/
```

### Script execution order

`make up` starts the container and triggers `setup-mssql.sh`, which restores
the database. After that, run scripts manually in the following order if
working through the DTA exercise:

1. `scripts/fix-dta-reports-error.sh` — only needed once, before running DTA
2. Run DTA from SSMS against AdventureWorks2017
3. `scripts/add-recommendations.sh` — applies the DTA recommendations
