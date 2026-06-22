# Lab 5 — Columnar databases (part 1)

First look at ClickHouse alongside PostgreSQL. The lab covers basic aggregations,
KPI queries, and a simple benchmark — the same queries run on both engines so
you can compare timing directly.

Dataset: **Events** (synthetic e-commerce clickstream) — see [`docs/datasets.md`](../../docs/datasets.md).

## Services

| Container | Image | Port | Credentials |
| --------- | ----- | ---- | ----------- |
| `postgres_lab5` | `postgres:16` | 5432 | `admin` / `admin`, db `postgres` |
| `clickhouse_lab5` | `clickhouse-server:25.12` | 8123 (HTTP), 19000 (native) | `admin` / `admin`, db `ds_lab` |

`events_generator_lab5` runs once on startup to produce the CSV data, then
exits. PostgreSQL and ClickHouse both pick up the generated files and load the
`events` table automatically.

## Start / stop

```bash
make up LAB=lab5
make down LAB=lab5
make clean LAB=lab5   # also removes labs/lab5/data/
```

## Render report

```bash
make pdf LAB=lab5
make pdf LAB=lab5 TARGET=solution
```

## Directory layout

```text
lab5/
├── docker-compose.yml
├── materials/
│   ├── 01_kolumnowe_bazy_prezentacja.pdf   # lecture slides
│   └── sql_postgresql_clickhouse_sciaga.pdf # SQL cheat sheet (PostgreSQL vs ClickHouse syntax)
├── scripts/
│   └── plots.ipynb   # notebook for generating the event-distribution chart
│                     # used in the solution (not required to run the lab)
├── template/
│   └── report.md
└── solution/
    ├── report.md
    ├── report.pdf
    └── media/
```
