# omnipowers — developer Makefile
#
# Installs this repo's skills into Claude Code and Codex by SYMLINK, so edits
# auto-apply without reinstalling. Run `make help` for targets.

SHELL := /bin/bash
INSTALLER := scripts/install-skills.sh
FORCE ?=

.DEFAULT_GOAL := help
.PHONY: help dev status install uninstall

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	  | awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'

dev: ## Analyze Claude/Codex status, then install this repo's skills for both
	@bash $(INSTALLER) status
	@echo
	@FORCE='$(FORCE)' bash $(INSTALLER) install

status: ## Show Claude/Codex install state and which skills are linked
	@bash $(INSTALLER) status

install: ## Symlink skills into Claude + Codex (idempotent; FORCE=1 to relink)
	@FORCE='$(FORCE)' bash $(INSTALLER) install

uninstall: ## Remove omnipowers skill symlinks from Claude + Codex
	@bash $(INSTALLER) uninstall
