# Lab 9 — Python and databases (part 1)

Using Python to query relational databases: pandas with SQLAlchemy, SQLite via
`sqlite3`, and ClickHouse for comparison. Covers data loading, transformation,
and the decision of when to do work in SQL versus Python.

Dataset: **Retail** (synthetic transactional dataset) — see [`docs/datasets.md`](../../docs/datasets.md).

## Services

| Container                     | Image                    | Port                        | Credentials                                             |
| ----------------------------- | ------------------------ | --------------------------- | ------------------------------------------------------- |
| `retail_lab_postgres_lab09`   | `postgres:16`            | 15432                       | `student` / `student`, db `retail_lab`, schema `retail` |
| `retail_lab_clickhouse_lab09` | `clickhouse-server:25.3` | 8123 (HTTP), 19000 (native) | `student` / `student`, db `retail`                      |

`retail_lab_generator_lab09` runs once to generate the CSV dataset into
`labs/lab09/data/`. `retail_lab_sqlite_lab09` then converts that into
`labs/lab09/db/northwind_plus.db`. Both one-shot containers exit after
completing. The SQLite file is gitignored and recreated each time.

## Start / stop

```bash
make up LAB=lab09
make down LAB=lab09
make clean LAB=lab09   # removes labs/lab09/data/ and labs/lab09/db/
```

## Opening the notebook

```bash
cd labs/lab09
jupyter lab
```

Open `template/notebook.ipynb` to work through the exercises, or
`solution/notebook.ipynb` to see the completed version. Run
`verify-environment.ipynb` first to confirm all services are reachable.

## Directory layout

```text
lab09/
├── docker-compose.yml
├── verify-environment.ipynb   # run this first to confirm the environment works
├── template/
│   └── notebook.ipynb         # student notebook with ___ fill-in-the-blank cells
└── solution/
    └── notebook.ipynb         # completed solution
```
