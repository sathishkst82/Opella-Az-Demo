SHELL := /bin/bash

fmt:
	terraform fmt -recursive

validate:
	terraform -chdir=environments/dev init -backend=false && terraform -chdir=environments/dev validate

tflint:
	tflint --init && tflint --recursive

test:
	cd tests && go test -v ./...
