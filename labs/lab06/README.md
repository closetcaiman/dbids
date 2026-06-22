# Lab 6 — Columnar databases (part 2)

Advanced analytics on ClickHouse: conversion funnels, window functions, RFM
segmentation, and a full benchmark with EXPLAIN plan analysis. PostgreSQL is
used as the comparison baseline.

Dataset: **Events** (synthetic e-commerce clickstream) — see [`docs/datasets.md`](../../docs/datasets.md).

## Services

| Container          | Image                     | Port                        | Credentials                      |
| ------------------ | ------------------------- | --------------------------- | -------------------------------- |
| `postgres_lab06`   | `postgres:16`             | 5432                        | `admin` / `admin`, db `postgres` |
| `clickhouse_lab06` | `clickhouse-server:25.12` | 8123 (HTTP), 19000 (native) | `admin` / `admin`, db `ds_lab`   |

Same startup flow as lab 5: the generator runs once, then both databases load
from the generated files.

## Start / stop

```bash
make up LAB=lab06
make down LAB=lab06
make clean LAB=lab06
```

## Render report

```bash
make pdf LAB=lab06
make pdf LAB=lab06 TARGET=solution
```

## Directory layout

```text
lab06/
├── docker-compose.yml
├── materials/
│   ├── 02_Kolumnowe bazy danych.pdf         # lecture slides (part 2)
│   └── sql_postgresql_clickhouse_sciaga.pdf # SQL cheat sheet
├── template/
│   └── report.md
└── solution/
    ├── report.md
    ├── report.pdf
    └── media/
```
