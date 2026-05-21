SHELL := /bin/bash
ENV ?= dev
ENV_DIR := environments/$(ENV)
BACKEND_CONFIG ?=

.PHONY: fmt init validate lint plan apply destroy-plan docs test

fmt:
	terraform fmt -recursive

init:
	cd $(ENV_DIR) && terraform init $(BACKEND_CONFIG)

validate:
	cd $(ENV_DIR) && terraform validate

lint:
	tflint --init
	tflint --chdir=$(ENV_DIR)

plan:
	cd $(ENV_DIR) && terraform plan -out=tfplan

apply:
	cd $(ENV_DIR) && terraform apply tfplan

destroy-plan:
	cd $(ENV_DIR) && terraform plan -destroy -out=tfdestroy.plan

docs:
	terraform-docs markdown table --output-file README.md --output-mode inject modules/vnet
	terraform-docs markdown table --output-file README.md --output-mode inject modules/vm
	terraform-docs markdown table --output-file README.md --output-mode inject modules/storage
	terraform-docs markdown table --output-file README.md --output-mode inject modules/governance

test:
	cd tests && go test ./... -timeout 45m
