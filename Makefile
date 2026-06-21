# omnipowers — developer Makefile
#
# Installs this repo's skills into Claude Code and Codex by SYMLINK, so edits
# auto-apply without reinstalling. Run `make help` for targets.

SHELL := /bin/bash
INSTALLER := scripts/install-skills.sh
FORCE ?=
SKILL ?=
TASKS ?=
BACKEND ?= mock
DRY ?=
TEST_ARGS ?=

.DEFAULT_GOAL := help
.PHONY: help dev status uninstall test optimize optimize-status optimize-adopt

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	  | awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'

dev: ## Analyze status, then symlink this repo's skills into Claude + Codex (FORCE=1 to re-link)
	@FORCE='$(FORCE)' bash $(INSTALLER) dev

status: ## Show Claude/Codex install state and which skills are linked
	@bash $(INSTALLER) status

uninstall: ## Remove omnipowers skill symlinks from Claude + Codex
	@bash $(INSTALLER) uninstall

test: ## Run skill tests (free content checks; TEST_ARGS="--integration" also runs agent tests, costs API)
	@bash tests/run-skill-tests.sh $(TEST_ARGS)

optimize: ## SkillOpt: optimize a skill → staged proposal (DRY=1 = report only) — SKILL= TASKS= [BACKEND=mock] (claude/codex cost API)
	@bash harness/optimize.sh run $(SKILL) $(TASKS) $(BACKEND) $(if $(DRY),--dry,)

optimize-status: ## Show the latest staged optimization proposal — SKILL=
	@bash harness/optimize.sh status $(SKILL)

optimize-adopt: ## Apply the latest staged optimization proposal, with backup — SKILL=
	@bash harness/optimize.sh adopt $(SKILL)
