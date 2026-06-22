# Generator image for lab09/lab10: produces the common synthetic CSV dataset
# (shared by every engine — Postgres, ClickHouse, SQLite). Dependencies are
# uv-locked (pyproject.toml + uv.lock) and the generator script is baked in,
# since only this container runs it. Rebuilds only when deps or script change.
FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim

WORKDIR /app
ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    PATH="/app/.venv/bin:$PATH"

COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev

COPY generate_data.py ./
