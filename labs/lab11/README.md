# Lab 11 — Graph databases: Neo4j

Introduction to Neo4j and the Cypher query language. The exercise builds a
graph from the Northwind dataset (loaded manually via `LOAD CSV` from the Neo4j
public data URL) and explores graph traversals, path queries, and the PROFILE
command.

Dataset: **Northwind** (loaded from neo4j.com CSV URLs inside Cypher — no local
data files needed).

## Services

| Container     | Image        | Port                        | Credentials            |
| ------------- | ------------ | --------------------------- | ---------------------- |
| `neo4j_lab11` | `neo4j:2026` | 7474 (browser), 7687 (Bolt) | `neo4j` / `Admin!1234` |

Open the Neo4j Browser at <http://localhost:7474>.

## Start / stop

```bash
make up LAB=lab11
make down LAB=lab11
make clean LAB=lab11
```

## Directory layout

```text
lab11/
├── docker-compose.yml
├── exercises/
│   └── neo4j-exercise-1.pdf   # exercise sheet
├── template/
│   ├── report.md              # blank exercise sheet (Markdown version)
│   └── _img/                  # diagrams embedded in the template
└── solution/
    └── (empty — lab not submitted)
```

> **Note:** This lab has no submitted solution.
