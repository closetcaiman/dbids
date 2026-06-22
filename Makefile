COMPOSE = docker-compose

REPO_ROOT := $(shell git rev-parse --show-toplevel)
SCRIPTS_DIR := $(REPO_ROOT)/common/scripts
LABS_DIR := $(REPO_ROOT)/labs

export UID := $(shell id -u)
export GID := $(shell id -g)

COMPOSE_FLAGS := --project-directory $(REPO_ROOT)
COMPOSE := $(COMPOSE) $(COMPOSE_FLAGS)

ifeq ($(LAB),$(filter $(LAB),lab7 lab8))
    PROFILE_FLAGS := --profile init
else
    PROFILE_FLAGS :=
endif

.PHONY: help up down restart clean status pdf check fmt setup

help:
	@echo "Databases in data science"
	@echo "Usage: make [target] [LAB=lab-name]"
	@echo ""
	@echo "Lab targets (require LAB=):"
	@echo "  up       - Pre-create data/db dirs, then start lab services in the background"
	@echo "  down     - Stop lab services (keeps volumes and generated data)"
	@echo "  restart  - Restart running lab services"
	@echo "  clean    - Stop services, remove volumes, and delete generated data/db dirs"
	@echo "  status   - Show running status of lab services"
	@echo "  pdf      - Render report.md to PDF (TARGET=solution [default] or template)"
	@echo ""
	@echo "Repo targets:"
	@echo "  check    - Lint Markdown and Python/notebook files (ruff check + format check + ty type check)"
	@echo "  fmt      - Auto-fix Markdown, format Python/notebooks, and apply ruff fixes"
	@echo "  setup    - Install uv dependencies and register git hooks via lefthook"


up:
	@if [ -z "$(LAB)" ]; then \
		echo "Usage: make up LAB=lab-name"; \
	else \
		echo "Creating local data directories safely as $(shell whoami)..."; \
		mkdir -p $(LABS_DIR)/$(LAB)/data $(LABS_DIR)/$(LAB)/db; \
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

clean:
	@if [ -z "$(LAB)" ]; then \
		echo "Usage: make clean LAB=lab-name"; \
	else \
		echo "Stopping services and deleting volumes for $(LAB)..."; \
		$(COMPOSE) -f $(LABS_DIR)/$(LAB)/docker-compose.yml $(PROFILE_FLAGS) down -v; \
		echo "Cleaning generated data and database directories..."; \
		$(SCRIPTS_DIR)/clean-lab.sh $(LAB); \
	fi
	@echo "All volumes and generated datasets deleted. Run 'make up LAB=$(LAB)' for a fresh start."

restart:
	@if [ -z "$(LAB)" ]; then \
		echo "Usage: make restart LAB=lab-name"; \
	else \
		echo "Restarting $(LAB) services..."; \
		$(COMPOSE) -f $(LABS_DIR)/$(LAB)/docker-compose.yml $(PROFILE_FLAGS) restart; \
	fi

status:
	@if [ -z "$(LAB)" ]; then \
		echo "Usage: make status LAB=lab-name"; \
		$(COMPOSE) ps; \
	else \
		echo "Showing status for $(LAB) services..."; \
		$(COMPOSE) -f $(LABS_DIR)/$(LAB)/docker-compose.yml $(PROFILE_FLAGS) ps; \
	fi

TARGET ?= template

pdf:
	@if [ -z "$(LAB)" ]; then \
		echo "Usage: make pdf LAB=lab-name [TARGET=solution|template]"; \
	else \
		$(SCRIPTS_DIR)/convert-md-to-pdf.sh $(LABS_DIR)/$(LAB)/$(TARGET)/report.md; \
	fi

check:
	@rc=0; \
	$(SCRIPTS_DIR)/markdown-lint.sh "**/*.md" || rc=$$?; \
	uv run ruff check . || rc=$$?; \
	uv run ruff format --check . || rc=$$?; \
	uv run ty check || rc=$$?; \
	exit $$rc

fmt:
	@rc=0; \
	$(SCRIPTS_DIR)/markdown-lint.sh --fix "**/*.md" || rc=$$?; \
	uv run ruff format . || rc=$$?; \
	uv run ruff check --fix . || rc=$$?; \
	exit $$rc

setup:
	@command -v uv >/dev/null 2>&1 || curl -LsSf https://astral.sh/uv/install.sh | sh
	uv sync --group dev
	uv run lefthook install