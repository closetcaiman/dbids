# Contributing

Pull requests are welcome. The most useful contributions right now are
solutions to the two skipped labs (7 and 11), but upgrades to existing
solutions, environment fixes, and documentation corrections are all fair game.

## What you can contribute

**Solutions to skipped labs.** Labs 7 (MongoDB) and 11 (Neo4j) have a
`template/report.md` and a working Docker environment but no submitted solution.
If you work through the exercises, a PR with your `solution/report.md` (and
screenshots in `solution/media/`) is very welcome.

**Upgrades to existing solutions.** If you have a better approach to a query,
a more thorough benchmark, or a clearer explanation than what's in
`solution/report.md`, submit an improvement. The goal is the best possible
solution for each lab, not preserving the original submission.

**Fixes.** Wrong queries, broken Docker environments, startup timing issues,
missing indexes, stale image versions — open a PR.

**Template improvements.** Better starter queries, clearer exercise
instructions, missing hints.

## Submitting a solution or upgrade

1. Fork the repo and create a branch named after what you're doing:
   `feat(lab7): add MongoDB solution` or `fix(lab5): correct task 4 query`.
2. Start the lab environment: `make up LAB=labN`. For labs 7 and 8 this
   automatically runs the data import step.
3. Work through `labs/labN/template/report.md` and put your completed report
   at `labs/labN/solution/report.md`. Screenshots go in
   `labs/labN/solution/media/`.
4. Remove your name from the report header — solution files in this repo don't
   include author information.
5. Run `make check` and fix any issues, then open a PR.

For lab 11 (Neo4j): the environment connects at `localhost:7474`, credentials
`neo4j` / `Admin!1234`.

## Running checks

```bash
make setup    # install uv, Python deps, and git hooks (do this once)
make check    # markdown lint + ruff + ty type check
make fmt      # auto-fix what can be auto-fixed
```

Pre-commit hooks run `check` on staged files automatically.

## Commit style

Commits must follow [Conventional Commits](https://www.conventionalcommits.org/):

```text
<type>(optional scope): <description>
```

Valid types: `feat` `fix` `docs` `style` `refactor` `test` `chore` `ci`
`build` `perf` `revert`

```text
feat(lab7): add MongoDB solution
fix(lab5): correct task 4 revenue query
docs: update lab3 README with DTA script order
```

The `commit-msg` hook validates this automatically after `make setup`.

## Adding a new lab

1. Create `labs/labN/docker-compose.yml` with `--project-directory` at the
   repo root. The Makefile passes `--project-directory $(REPO_ROOT)`, so
   volume mounts work relative to root. Any existing lab is a good reference.
2. Add `template/report.md` and `solution/report.md` (or notebook equivalents).
3. Write `labs/labN/README.md` describing what each file does, connection
   credentials, and start/stop commands.
4. Put any one-shot init container under a named profile so it doesn't block
   normal `make up` restarts. Add the lab name to the `PROFILE_FLAGS` block
   in the Makefile so `make up` triggers it automatically.
5. Verify with `make up LAB=labN`, confirm data is loaded, then
   `make clean LAB=labN`.

## Datasets and documentation

Dataset files live in `common/` and are shared across labs. Schema diagrams
and data dictionaries are in `docs/plans/`. If you add a new dataset, document
it in `docs/datasets.md`.

## PDF rendering

The `make pdf` target uses `pandoc/typst` via Docker, so no local Typst
install is needed. The template is at `common/templates/report.typ`.
Typst-specific page break markers (`{=typst} #pagebreak()`) are fine in
solution reports but should be removed from templates.
