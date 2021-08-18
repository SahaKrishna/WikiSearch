SHELL := /bin/bash

AWS_NUKE_VERSION := 2.15.0
UNAME := $(shell uname)

AWS_ACCOUND_ID := "133002017424"

mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfile_dir := $(dir $(mkfile_path))
export PATH := ${mkfile_dir}/../vendor/bin:$(PATH)
export AWS_PAGER := ""

DATA_URL := "http://dumps.wikimedia.org/other/pageviews/$(shell date +'%Y/%Y-%m/pageviews-%Y%m%d')-010000.gz"

KEY_FILE := .KEYIDS
ifneq ("$(wildcard $(KEY_FILE))","")
include $(KEY_FILE)
endif

# build help
PHONY: help
help:
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' Makefile | \
	sort | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


# Deploying containers and building the database

.PHONY: ecr_login
ecr_login:
	aws-vault exec techtest.scalefactory.net -- sh ../ecr.sh
	#$(shell aws-vault exec techtest.scalefactory.net -- aws ecr get-login-password --region eu-west-1)
	#$(shell aws-vault exec techtest.scalefactory.net -- aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin $(AWS_ACCOUND_ID).dkr.ecr.eu-west-1.amazonaws.com)

.PHONY: app_push
app_push: ## Build and push application
	cd ../; $(MAKE) app_push

.PHONY: build_db
build_db: ## Database container build
	cd db_import; docker build --network host -t wiki-check-sf-tech-test-db .

.PHONY: db_import_push
db_import_push: ecr_login build_db ## Build and push db conatiner to ECR repo
	cd db_import; docker tag wiki-check-sf-tech-test-db:latest ${AWS_ACCOUND_ID}.dkr.ecr.eu-west-1.amazonaws.com/wiki-check-sf-tech-test-db:latest
	cd db_import; docker push ${AWS_ACCOUND_ID}.dkr.ecr.eu-west-1.amazonaws.com/wiki-check-sf-tech-test-db:latest

.PHONY: db_import_run
db_import_run: ## Run the database import in AWS
	cd db_import; aws-vault exec techtest.scalefactory.net -- sh ./run_task.sh
	sleep 360

.PHONY: seed
seed: app_push db_import_push db_import_run # Push containers and seed AWS database
	@echo "Database populated"

.PHONY: load
load: # Run load against the app in AWS
	@echo "Applying sample load"
	cd db_import; aws-vault exec techtest.scalefactory.net -- sh ./load.sh

.PHONY: sustainedload
sustainedload: # Run load against the app in AWS sustained
	@echo "Applying sample load"
	cd db_import; aws-vault exec techtest.scalefactory.net -- sh ./sustained_load.sh

.PHONY: instructions
instructions:
	cp .INSTRUCTIONS.md ../INSTRUCTIONS.md

.PHONY: boilerplate
boilerplate:
	@echo "## Website Access" | tee -a ../INSTRUCTIONS.md ../.creds > /dev/null
	@echo "The website is accessible at:" | tee -a ../INSTRUCTIONS.md ../.creds > /dev/null
	@echo "" | tee -a ../INSTRUCTIONS.md ../.creds > /dev/null

.PHONY: website
website: boilerplate
	@$(shell aws-vault exec techtest.scalefactory.net -- aws elbv2 describe-load-balancers --region eu-west-1 --names wiki-check-alb --query 'LoadBalancers[*].DNSName' --output text | awk '{print "http://" $$1}' | tee -a ../INSTRUCTIONS.md ../.creds > /dev/null)

.PHONY: cf_setup
cf_setup: ## Create initial CloudFormation
	cd cf; $(MAKE) create

.PHONY: cf_rotate_creds
cf_rotate_creds: ## Rotate CF credentials
	cd cf; $(MAKE) rotate_password
	cd cf; $(MAKE) rotate_keys

.PHONY: cf_delete
cf_delete: ## Delete CloudFormation stack
	cd cf; $(MAKE) delete

.PHONY: tf-apply
tf-apply: ## Terraform apply
	cd ../; $(MAKE) tf-apply

.PHONY: tf-destroy
tf-destroy: ## Terraform destroy
	cd ../; $(MAKE) tf-destroy

.PHONY: website_setup
website_setup: tf-apply seed website load ## Setup website if nothing exists

.PHONY: initial_setup
initial_setup: instructions cf_setup ## Setup CloudFormation if nothing exists

# reset account
# does not remove cloudformation stack and user
# use this to ensure that the test account has all elements removed
../vendor/bin/aws-nuke: ../vendor/bin
	$(info => Installing AWS-NUKE)
ifeq ($(UNAME), Linux)
	curl -sS -qL -o ../vendor/bin/aws-nuke https://github.com/rebuy-de/aws-nuke/releases/download/v${AWS_NUKE_VERSION}/aws-nuke-v${AWS_NUKE_VERSION}-linux-amd64
else ifeq ($(UNAME), Darwin)
	curl -sS -qL -o ../vendor/bin/aws-nuke https://github.com/rebuy-de/aws-nuke/releases/download/v${AWS_NUKE_VERSION}/aws-nuke-v${AWS_NUKE_VERSION}-darwin-amd64
else
	$(error Unknown system)
endif
	@chmod 0755 ../vendor/bin/aws-nuke

.nuke.yaml:
	cp nuke.yaml .nuke.yaml
	sed -i "s/AWS_ACCOUNT_ID/${AWS_ACCOUND_ID}/g" .nuke.yaml
	sed -i "s/TF_AWS_ACCESS_KEY_ID/${TF_AWS_ACCESS_KEY_ID}/g" .nuke.yaml
	sed -i "s/CAN_AWS_ACCESS_KEY_ID/${CAN_AWS_ACCESS_KEY_ID}/g" .nuke.yaml

../vendor/bin:
	mkdir -p ../vendor/bin

# Uses AWS Nuke to tidy up other resources
.PHONY: aws_clean
aws_clean: ../vendor/bin/aws-nuke .nuke.yaml
	aws-vault exec techtest.scalefactory.net -- sh ./nuke.sh
	# Restore original local Docker config
	-mv ~/.docker/config.json.org ~/.docker/config.json

.PHONY: remove_files
remove_files:
	-rm -rf ../.env .nuke.yaml ../INSTRUCTIONS.md .KEYIDS ../.creds
	-rm -rf ../vendor/bin ../deployments/environments/prod/.terragrunt-cache

# Reset credentials after a test
.PHONY: reset_creds ## Reset the user credentials after test
reset_creds: remove_files instructions cf_rotate_creds website

# nuke account:
# cleans up mostly everything
.PHONY: nuke ## Cleans up mostly everything
nuke: tf-destroy remove_files cf_delete
	# Restore original local Docker config
	-mv ~/.docker/config.json.org ~/.docker/config.json

.PHONY: setup
setup: initial_setup ## Setup everything, if nothing exists
	# Backup Docker local config
	-mv ~/.docker/config.json ~/.docker/config.json.org
	$(MAKE) website_setup

# remove all stopped containers and dangling images
.PHONY: remove_containers
remove_containers:
	docker system prune -f
