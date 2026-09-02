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
MAXTASKS ?=
LOOKBACK ?=
SOURCE ?=
POOL ?=
SCENARIOS ?=
RUNS ?=
JOBS ?=
TEST_ARGS ?=

.DEFAULT_GOAL := help
.PHONY: help dev status uninstall test optimize optimize-pool optimize-status optimize-adopt optimize-list

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	  | awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'

dev: ## Symlink this repo's skills into the target hosts (TARGETS="claude codex", FORCE=1 to re-link)
	@FORCE='$(FORCE)' $(if $(TARGETS),OMNIPOWERS_TARGETS='$(TARGETS)',) bash $(INSTALLER) dev

status: ## Show Claude/Codex install state and which skills are linked
	@$(if $(TARGETS),OMNIPOWERS_TARGETS='$(TARGETS)',) bash $(INSTALLER) status

uninstall: ## Remove omnipowers skill symlinks (TARGETS="codex" for one host; default: the configured targets)
	@bash $(INSTALLER) uninstall $(TARGETS)

test: ## Run skill tests (free content checks; TEST_ARGS="--integration" also runs agent tests, costs API)
	@bash tests/run-skill-tests.sh $(TEST_ARGS)

optimize: ## SkillOpt: optimize skills → staged proposals. SKILL=a,b,c (empty=all) BACKEND=claude|codex [MODEL=] [DRY=1] [PROGRESS=1]
	@$(OPTIMIZE) run $(if $(SKILL),--skill $(SKILL),) $(if $(BACKEND),--backend $(BACKEND),) $(if $(MODEL),--model $(MODEL),) $(if $(DRY),--dry,) $(if $(PROGRESS),--progress,) $(if $(EVAL_ROOT),--eval-root $(EVAL_ROOT),) $(if $(MAXTASKS),--max-tasks $(MAXTASKS),) $(if $(LOOKBACK),--lookback-hours $(LOOKBACK),) $(if $(SOURCE),--source $(SOURCE),) $(if $(JOBS),--jobs $(JOBS),) $(if $(POOL),--pool $(POOL),)

optimize-pool: ## Harvest+mine the shared task pool ONCE and persist it (mine cheap+parallel, e.g. BACKEND=claude MODEL=haiku JOBS=8) [MAXTASKS=][LOOKBACK=][SOURCE=][POOL=out]
	@$(OPTIMIZE) pool $(if $(BACKEND),--backend $(BACKEND),) $(if $(MODEL),--model $(MODEL),) $(if $(MAXTASKS),--max-tasks $(MAXTASKS),) $(if $(LOOKBACK),--lookback-hours $(LOOKBACK),) $(if $(SOURCE),--source $(SOURCE),) $(if $(JOBS),--jobs $(JOBS),) $(if $(POOL),--out $(POOL),) $(if $(PROGRESS),--progress,)

optimize-status: ## Show staged optimization proposals — SKILL=a,b,c (empty=all staged)
	@$(OPTIMIZE) status $(if $(SKILL),--skill $(SKILL),)

optimize-adopt: ## Apply one skill's staged proposal, with backup — SKILL=name
	@$(OPTIMIZE) adopt --skill $(SKILL)

optimize-list: ## List skills + whether each has an eval set / config / staged proposal
	@$(OPTIMIZE) list $(if $(EVAL_ROOT),--eval-root $(EVAL_ROOT),)

fitness-triggers: ## Trigger precision/recall for one skill via the skill-creator harness — SKILL= EVALSET= [MODEL=]
	@$(if $(OMNIPOWERS_PY),$(OMNIPOWERS_PY),python3) scripts/fitness.py triggers --skill $(SKILL) $(if $(EVALSET),--eval-set $(EVALSET),) $(if $(MODEL),--model $(MODEL),)

fitness-validate: ## Structural validation of every skill via the skill-creator harness
	@$(if $(OMNIPOWERS_PY),$(OMNIPOWERS_PY),python3) scripts/fitness.py validate

fitness-round: ## A whole fitness review — preflight + triggers + A/B over every skill [SKILLS=] [PHASE=] [RUNS=]
	@$(if $(OMNIPOWERS_PY),$(OMNIPOWERS_PY),python3) scripts/fitness.py round $(if $(SKILLS),--skills $(SKILLS),) $(if $(PHASE),--phase $(PHASE),) $(if $(RUNS),--runs $(RUNS),) $(if $(MODEL),--model $(MODEL),)

fitness-compliance: ## Behavioral A/B (skill vs no-skill control) for one skill — SKILL= [SCENARIOS=] [RUNS=]
	@$(if $(OMNIPOWERS_PY),$(OMNIPOWERS_PY),python3) scripts/compliance.py run --skill $(SKILL) $(if $(SCENARIOS),--scenarios $(SCENARIOS),) $(if $(RUNS),--runs $(RUNS),) $(if $(MODEL),--model $(MODEL),)
