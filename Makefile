COMPOSE = docker-compose

REPO_ROOT := $(shell git rev-parse --show-toplevel)
SCRIPTS_DIR := $(REPO_ROOT)/common/scripts
LABS_DIR := $(REPO_ROOT)/labs

COMPOSE_FLAGS := --project-directory $(REPO_ROOT)
COMPOSE := $(COMPOSE) $(COMPOSE_FLAGS)

ifeq ($(LAB),lab8)
    PROFILE_FLAGS := --profile init
else
    PROFILE_FLAGS :=
endif

.PHONY: help up down restart clean status pdf check fmt setup

help:
	@echo "Databases in data science"
	@echo "Usage: make [target] [LAB=lab-name]"
	@echo "Targets:"
	@echo "  up       - Start the services for the specified lab"
	@echo "  down     - Stop the services for the specified lab"
	@echo "  restart  - Restart the services for the specified lab"
	@echo "  clean    - Stop the services and remove volumes for the specified lab"
	@echo "  status   - Show the status of the services for the specified lab"
	@echo "  pdf      - Convert a markdown file to PDF (usage: make pdf LAB=lab-name)"
	@echo "  check    - Lint all markdown files"
	@echo "  fmt      - Auto-fix markdown lint violations"
	@echo "  setup    - Install uv dependencies and register git hooks via lefthook"


up:
	@if [ -z "$(LAB)" ]; then \
		echo "Usage: make up LAB=lab-name"; \
	else \
		echo "Starting $(LAB) services..."; \
		$(COMPOSE) -f $(LABS_DIR)/$(LAB)/docker-compose.yml $(PROFILE_FLAGS) up -d; \
	fi

down:
	@if [ -z "$(LAB)" ]; then \
		echo "Usage: make down LAB=lab-name"; \
	else \
		echo "Stopping $(LAB) services..."; \
		$(COMPOSE) -f $(LABS_DIR)/$(LAB)/docker-compose.yml $(PROFILE_FLAGS) down; \
	fi

restart:
	@if [ -z "$(LAB)" ]; then \
		echo "Usage: make restart LAB=lab-name"; \
	else \
		echo "Restarting $(LAB) services..."; \
		$(COMPOSE) -f $(LABS_DIR)/$(LAB)/docker-compose.yml $(PROFILE_FLAGS) restart; \
	fi

clean:
	@if [ -z "$(LAB)" ]; then \
		echo "Usage: make clean LAB=lab-name"; \
	else \
		echo "Deleting volumes for $(LAB) services..."; \
		$(COMPOSE) -f $(LABS_DIR)/$(LAB)/docker-compose.yml $(PROFILE_FLAGS) down -v; \
	fi
	@echo "All volumes deleted. Run 'make up' for a fresh start."

status:
	@if [ -z "$(LAB)" ]; then \
		echo "Usage: make status LAB=lab-name"; \
		$(COMPOSE) ps; \
	else \
		echo "Showing status for $(LAB) services..."; \
		$(COMPOSE) -f $(LABS_DIR)/$(LAB)/docker-compose.yml $(PROFILE_FLAGS) ps; \
	fi

pdf:
	@$(SCRIPTS_DIR)/convert-md-to-pdf.sh $(LABS_DIR)/$(LAB)/report.md

check:
	$(SCRIPTS_DIR)/markdown-lint.sh "**/*.md"

fmt:
	$(SCRIPTS_DIR)/markdown-lint.sh --fix "**/*.md"

setup:
	@command -v uv >/dev/null 2>&1 || curl -LsSf https://astral.sh/uv/install.sh | sh
	uv sync --group dev
	uv run lefthook install