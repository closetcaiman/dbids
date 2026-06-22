# Lab 10 — Python and databases (part 2)

Deeper Python + database work: writing reports as functions, Polars and DuckDB
as alternatives to pandas, feature engineering, and anomaly detection on time
series. Picks up where lab 9 left off with the same Retail dataset.

Dataset: **Retail** (synthetic transactional dataset) — see [`docs/datasets.md`](../../docs/datasets.md).

## Services

| Container                     | Image                    | Port                        | Credentials                                             |
| ----------------------------- | ------------------------ | --------------------------- | ------------------------------------------------------- |
| `retail_lab_postgres_lab10`   | `postgres:16`            | 15432                       | `student` / `student`, db `retail_lab`, schema `retail` |
| `retail_lab_clickhouse_lab10` | `clickhouse-server:25.3` | 8123 (HTTP), 19000 (native) | `student` / `student`, db `retail`                      |

Same startup flow as lab 9: the generator and SQLite loader run once and exit.

## Start / stop

```bash
make up LAB=lab10
make down LAB=lab10
make clean LAB=lab10
```

## Opening the notebook

```bash
cd labs/lab10
jupyter lab
```

`verify-environment.ipynb` checks that all services and input files are in place
before you start. `template/notebook.ipynb` has the student version with
placeholders; `solution/notebook.ipynb` has the completed work.

## Directory layout

```text
lab10/
├── docker-compose.yml
├── verify-environment.ipynb    # environment check — run before opening the main notebook
├── template/
│   └── notebook.ipynb          # student notebook with ... fill-in-the-blank cells
└── solution/
    └── notebook.ipynb          # completed solution
```
