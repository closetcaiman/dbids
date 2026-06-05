# SQLite-loader image for lab9/lab10: loads the common synthetic CSVs into a
# SQLite database (the SQLite engine's counterpart to the Postgres/ClickHouse
# init SQL). Dedicated, uv-locked image; pandas handles NaN -> NULL natively.
FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim

WORKDIR /app
ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    PATH="/app/.venv/bin:$PATH"

COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev

COPY create_sqlite_db.py ./
