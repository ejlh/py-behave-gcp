.ONESHELL:
SHELL := /bin/bash
.DEFAULT_GOAL := help

# Variables
VENV_DIR := .venv
PYTHON := $(VENV_DIR)/bin/python
PIP := $(VENV_DIR)/bin/pip
UVICORN := $(VENV_DIR)/bin/uvicorn
APP_MODULE := app.runner:app
ALLURE_RESULTS_DIR := ./reports/allure/report_allure-results
CURL := curl
ALLURE := allure

# Colors
GREEN := \033[0;32m
NC := \033[0m

# Help
.PHONY: help
help:
	@echo "Usage of the Makefile:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-20s$(NC) %s\n", $$1, $$2}'

.PHONY: venv
venv: ## Create a virtual environment
	@echo "Creating virtualenv ..."
	@rm -rf $(VENV_DIR)
	@python3 -m venv $(VENV_DIR)
	@$(PIP) install -U pip
	@echo
	@echo "Run 'source $(VENV_DIR)/bin/activate' to enable the environment"

.PHONY: env
env: ## Create environment variables file
	@echo "Creating environment variables file..."
	@cp -n .env.example .env || true
	@echo "Environment file created (if it didn't exist already)"

.PHONY: install
install: ## Install dependencies
	@echo "Installing dependencies..."
	@$(PIP) install -r requirements.txt
	@$(PIP) install -r requirements-dev.txt
	@$(PIP) install -r requirements-test.txt

.PHONY: coverage
coverage: ## Run coverage tests with behave
	@echo "Running coverage tests with behave..."
	@mkdir -p reports
	@$(PYTHON) -m coverage run -m behave test/features
	@$(PYTHON) -m coverage report
	@$(PYTHON) -m coverage html -d reports/html
	@$(PYTHON) -m coverage xml -o reports/coverage.xml

.PHONY: security
security: ## Run security check on dependencies
	@echo "Running security check on dependencies..."
	@mkdir -p reports
	@$(PYTHON) -m safety check -r requirements.txt --output screen

.PHONY: run
run: ## Run the application with Uvicorn
	@echo "Running the application with Uvicorn..."
	@$(UVICORN) $(APP_MODULE) --host=0.0.0.0 --port=8080 --lifespan=on --reload --log-level=debug

.PHONY: test-api
test-api: ## Test the API endpoint
	@echo "Testing the API endpoint..."
	@$(CURL) -X GET http://0.0.0.0:8080/features_path/runner_test -H "Accept: application/json"

.PHONY: clean
clean: ## Remove specific files and directories
	@echo "Removing specific files and directories..."
	@rm -rf ./reports/ app_output.log .coverage rerun.txt *.log
	@echo "Cleanup complete"

.PHONY: behave
behave: ## Run tests with behave
	@echo "Running tests with behave..."
	@mkdir -p reports
	@$(PYTHON) -m behave -s

.PHONY: allure
allure: ## Generate test report with Allure
	@echo "Generating test report with Allure..."
#	@$(PYTHON) -m allure generate $(ALLURE_RESULTS_DIR) --clean --output $(ALLURE_RESULTS_DIR)
	@$(PYTHON) -m allure serve ./reports/allure/report-allure-results


.PHONY: all
all: venv env install ## Set up everything
