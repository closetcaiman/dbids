# Generator image for lab10: builds synthetic CSVs and the SQLite database.
# Dependencies are baked in at build time so `make up` does not reinstall them
# on every cold start. Scripts are mounted at runtime, so editing a script does
# not require rebuilding this image (only changing requirements does).
FROM python:3.12-slim

WORKDIR /lab

COPY requirements.txt /lab/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt
