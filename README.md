# Databases in data science

Lab solutions and environment for a databases course at AGH UST. Twelve labs
covering SQL, columnar stores, document databases, graph databases, spatial
data, and Python integration. Each lab is containerized and starts with a
single `make up` command.

## Labs

| #   | Topic                                | Technologies                   | Status  | Grade  |
| --- | ------------------------------------ | ------------------------------ | ------- | ------ |
| 1   | SQL window functions - part 1        | MSSQL, PostgreSQL, SQLite      | solved  | 6/7    |
| 2   | SQL window functions - part 2        | MSSQL, PostgreSQL, SQLite      | solved  | 11/11  |
| 3   | Indexes and query optimizer - part 1 | MSSQL (AdventureWorks)         | solved  | 10/10  |
| 4   | Indexes and query optimizer - part 2 | MSSQL                          | solved  | 13/13  |
| 5   | Columnar databases - part 1          | PostgreSQL, ClickHouse         | solved  | 8/10   |
| 6   | Columnar databases - part 2          | PostgreSQL, ClickHouse         | solved  | 7.5/10 |
| 7   | Document databases: MongoDB          | MongoDB                        | skipped | -      |
| 8   | Document databases: Couchbase        | Couchbase                      | solved  | 9.5/10 |
| 9   | Python and databases - part 1        | PostgreSQL, ClickHouse, SQLite | solved  | 9.5/10 |
| 10  | Python and databases - part 2        | PostgreSQL, ClickHouse, SQLite | solved  | 9.5/10 |
| 11  | Graph databases: Neo4j               | Neo4j                          | skipped | -      |
| 12  | Spatial databases: Oracle Spatial    | Oracle                         | solved  | 10/10  |

Each lab directory has its own README with connection details, a description of
every file, and exact start/stop commands.

## Prerequisites

- Docker ≥ 24 with Compose v2 (`docker compose`, not `docker-compose`)
- `make`
- `uv` (Python package manager, installed automatically by `make setup`)
- A SQL client for the relational labs (DataGrip, DBeaver, SSMS, or CLI tools)
- Jupyter for labs 9, 10, 12

## Setup

```bash
make setup    # installs uv, syncs Python deps, registers git hooks
```

## Running a lab

```bash
make up LAB=lab01      # start containers (downloads images on first run)
make status LAB=lab01  # check what's running
make down LAB=lab01    # stop, keep volumes
make clean LAB=lab01   # stop and remove everything including generated data
```

For labs 5 and 6 the event generator runs automatically. Labs 7 and 8 run
their data import containers automatically via the `init` profile, so plain
`make up LAB=lab07` and `make up LAB=lab08` are enough.

## Rendering reports to PDF

Labs 1–8 and 12 use Markdown reports rendered via Pandoc + Typst (runs in
Docker, no local install needed):

```bash
make pdf LAB=lab01              # renders template/report.md (default)
make pdf LAB=lab01 TARGET=solution  # renders solution/report.md
```

Labs 9, 10, and 12 also include Jupyter notebooks. Open them after `make up`
with `jupyter lab` from the lab directory.

## Repository layout

```text
.
├── common/
│   ├── backups/          # AdventureWorks2017.bak
│   ├── data/             # Northwind JSON files (used by MongoDB, Couchbase)
│   ├── dockerfiles/      # shared images (events generator, retail generator, SQLite loader)
│   ├── scripts/          # shared shell scripts (transaction helpers, PDF converter, linter)
│   ├── sql/              # DDL and data for all datasets, organized by engine
│   └── templates/        # Typst report template
├── docs/
│   ├── datasets.md       # descriptions of all four datasets used across labs
│   └── plans/            # schema diagrams and data dictionaries (northwind/, retail/)
├── labs/
│   └── lab{1..12}/       # one directory per lab (see each lab's README)
├── Makefile
└── pyproject.toml        # Python dependencies for labs 9, 10, 12
```

## Datasets

- Northwind - classic trading company sample (labs 1–4, 7, 8)
- AdventureWorks 2017 - Microsoft bicycle manufacturer sample (labs 3–4)
- Events - synthetic e-commerce clickstream (labs 5–6)
- Retail - synthetic transactional dataset with dirty tables (labs 9–10)

Full descriptions in [`docs/datasets.md`](docs/datasets.md).

## Development

```bash
make check    # markdown lint + ruff + ty type check
make fmt      # auto-fix formatting issues
```

Pre-commit hooks run automatically via lefthook after `make setup`.
