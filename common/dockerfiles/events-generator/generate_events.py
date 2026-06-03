"""
Generate the synthetic events dataset shared by lab5 and lab6.

Writes a single events.csv (header common to ClickHouse and Postgres) into the
output directory. Generation is seeded, so the output is deterministic.

Example:
    python generate_events.py --output /data
"""

from __future__ import annotations

import argparse
import csv
import datetime as dt
import random
from pathlib import Path

SEED = 42

COUNTRIES = ["PL", "DE", "FR", "IT", "ES", "US", "GB", "SE", "NO", "NL"]
DEVICES = ["mobile", "desktop", "tablet"]
START_TIME = dt.datetime(2025, 1, 1)
TIME_SPAN_SECONDS = 180 * 24 * 3600

HEADER = [
    "event_time",
    "user_id",
    "session_id",
    "product_id",
    "price",
    "quantity",
    "country",
    "device",
    "event_type",
]


def generate(output_file: Path, n_rows: int) -> None:
    random.seed(SEED)
    output_file.parent.mkdir(parents=True, exist_ok=True)

    with open(output_file, "w", newline="", encoding="utf-8") as f:
        # LF line endings (csv default is CRLF) to match the repo's eol=lf policy.
        writer = csv.writer(f, lineterminator="\n")
        writer.writerow(HEADER)

        for _ in range(n_rows):
            event_time = START_TIME + dt.timedelta(
                seconds=random.randint(0, TIME_SPAN_SECONDS)
            )
            user_id = random.randint(1, 50_000)
            session_id = random.randint(1, 200_000)
            product_id = random.randint(1, 10_000)
            price = round(random.uniform(5, 500), 2)
            quantity = 1 if random.random() < 0.85 else random.randint(2, 5)
            country = random.choice(COUNTRIES)
            device = random.choice(DEVICES)

            r = random.random()
            event_type = (
                "purchase" if r < 0.05 else "add_to_cart" if r < 0.20 else "view"
            )

            writer.writerow(
                [
                    event_time.strftime("%Y-%m-%d %H:%M:%S"),
                    user_id,
                    session_id,
                    product_id,
                    price,
                    quantity,
                    country,
                    device,
                    event_type,
                ]
            )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--output",
        type=Path,
        default=Path("events"),
        help="Output directory; events.csv is written inside it.",
    )
    parser.add_argument("--rows", type=int, default=100_000)
    args = parser.parse_args()

    output_file = args.output / "events.csv"
    generate(output_file, args.rows)
    print(f"Generated {args.rows} rows -> {output_file}")


if __name__ == "__main__":
    main()
