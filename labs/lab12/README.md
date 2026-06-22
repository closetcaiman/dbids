# Lab 12 — Spatial databases: Oracle Spatial

Storing, querying, and visualizing geographic data with Oracle Spatial (SDO
geometry types, spatial indexes, and SDO_INSIDE / SDO_UTIL functions). The
report is in Markdown; the notebooks use `oracledb` and `folium` for maps.

> **No Docker compose.** This lab requires an Oracle database instance with
> the Spatial option enabled. It was run against a university-provided Oracle
> server — there is no local containerized alternative included here.

## Directory layout

```text
lab12/
├── exercises/
│   └── spatial-exericse-1.pdf   # exercise sheet
├── template/
│   ├── report.md                # blank exercise sheet
│   ├── 1-oracle.ipynb           # notebook template for the general Oracle part
│   ├── 1-oracle.py              # same content as a plain Python script
│   ├── 2-oracle-spatial.ipynb   # notebook template for the spatial queries
│   └── 2-oracle-spatial.py      # same content as a plain Python script
└── solution/
    ├── oracle-spatial.ipynb     # completed Jupyter notebook (spatial part)
    ├── report.md                # completed written report
    ├── report.pdf
    └── media/                   # screenshots used in report.md
```

## Render report

```bash
make pdf LAB=lab12              # renders template/report.md (default)
make pdf LAB=lab12 TARGET=solution  # renders solution/report.md
```

## Prerequisites

- Access to an Oracle database with Spatial option (schemas `us_states`,
  `us_interstates`, `us_parks`)
- Python packages: `oracledb`, `folium`, `geojson` (already in `pyproject.toml`)
- Oracle Instant Client (required by `oracledb` in thick mode)
