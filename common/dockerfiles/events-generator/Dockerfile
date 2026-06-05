# Events generator image for lab5/lab6: produces the shared synthetic
# events.csv. The script is pure stdlib (no third-party deps), so a plain slim
# Python image with the script baked in is all that's needed.
FROM python:3.12-slim

WORKDIR /app
COPY generate_events.py ./
