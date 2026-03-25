COMPOSE = docker-compose
SERVICES = mssql postgres sqlite

.PHONY: help up down restart clean status logs-mssql logs-pg

help:
	@echo "Database in data science"
	@echo "--------------------------"
	@echo "make up             - Start all database services"
	@echo "make down           - Stop all services"
	@echo "make restart        - Restart all services"
	@echo "make clean          - FULL RESET: Deletes containers and ALL database volumes"
	@echo "make status         - Show running containers"
	@echo "make mssql-shell    - Open SQLCMD inside MS SQL container"
	@echo "make pg-shell       - Open PSQL inside Postgres container"

up:
	$(COMPOSE) up -d

down:
	$(COMPOSE) stop

restart:
	$(COMPOSE) restart

clean:
	$(COMPOSE) down -v
	@echo "All volumes deleted. Run 'make up' for a fresh start."

status:
	$(COMPOSE) ps

pg-transaction:
	cat $(FILE) | docker exec -i postgres_server psql -U admin -d postgres

mssql-transaction:
	cat $(FILE) | docker exec -i mssql_server /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "Admin!1234" -C

sqlite-transaction:
	cat $(FILE) | docker exec -i sqlite_server sqlite3 /data/db/northwind.db