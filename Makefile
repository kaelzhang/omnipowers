# omnipowers — developer Makefile
#
# Installs this repo's skills into Claude Code and Codex by SYMLINK, so edits
# auto-apply without reinstalling. Run `make help` for targets.

SHELL := /bin/bash
INSTALLER := scripts/install-skills.sh
OPTIMIZE := $(if $(OMNIPOWERS_PY),$(OMNIPOWERS_PY),python3) scripts/optimize.py
FORCE ?=
SKILL ?=
BACKEND ?=
MODEL ?=
DRY ?=
PROGRESS ?=
EVAL_ROOT ?=
TEST_ARGS ?=

.DEFAULT_GOAL := help
.PHONY: help dev status uninstall test optimize optimize-status optimize-adopt optimize-list

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

optimize: ## SkillOpt: optimize skills → staged proposals. SKILL=a,b,c (empty=all) BACKEND=claude|codex [MODEL=] [DRY=1] [PROGRESS=1]
	@$(OPTIMIZE) run $(if $(SKILL),--skill $(SKILL),) $(if $(BACKEND),--backend $(BACKEND),) $(if $(MODEL),--model $(MODEL),) $(if $(DRY),--dry,) $(if $(PROGRESS),--progress,) $(if $(EVAL_ROOT),--eval-root $(EVAL_ROOT),)

optimize-status: ## Show staged optimization proposals — SKILL=a,b,c (empty=all staged)
	@$(OPTIMIZE) status $(if $(SKILL),--skill $(SKILL),)

optimize-adopt: ## Apply one skill's staged proposal, with backup — SKILL=name
	@$(OPTIMIZE) adopt --skill $(SKILL)

optimize-list: ## List skills + whether each has an eval set / config / staged proposal
	@$(OPTIMIZE) list $(if $(EVAL_ROOT),--eval-root $(EVAL_ROOT),)
