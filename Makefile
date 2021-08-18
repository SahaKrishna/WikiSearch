SHELL := /bin/bash
ENV_FILE := .env
ifneq ("$(wildcard $(ENV_FILE))","")
include .env
export AWS_ACCOUND_ID := $(shell AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} aws iam get-user --region eu-west-1  --query 'User.Arn'|awk -F\: '{print $$5}')
export TERRAGRUNT_IAM_ROLE := arn:aws:iam::${AWS_ACCOUND_ID}:role/Terraform
endif

TF_VERSION := 0.12.31
UNAME := $(shell uname)
mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfile_dir := $(dir $(mkfile_path))
export PATH := ${mkfile_dir}/vendor/bin:$(PATH)
export TF_INPUT := 0
export AWS_PAGER: = ""

DATA_URL := "http://dumps.wikimedia.org/other/pageviews/$(shell date +'%Y/%Y-%m/pageviews-%Y%m%d')-010000.gz"


# build help
PHONY: help
help:
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' Makefile | \
	sort | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


vendor/bin:
	mkdir -p vendor/bin

vendor/bin/terraform: vendor/bin
	$(info => Installing Terraform)
ifeq ($(UNAME), Linux)
	curl -sS -qL -o terraform.zip https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip
else ifeq ($(UNAME), Darwin)
	curl -sS -qL -o terraform.zip https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_darwin_amd64.zip
else
	$(error Unknown system)
endif
	@unzip -o terraform.zip -d vendor/bin/
	@rm terraform.zip
	@chmod 0755 vendor/bin/terraform

vendor/bin/terragrunt: vendor/bin
	$(info => Installing Terragrunt)
ifeq ($(UNAME), Linux)
	curl -sS -qL -o vendor/bin/terragrunt https://github.com/gruntwork-io/terragrunt/releases/latest/download/terragrunt_linux_amd64
else ifeq ($(UNAME), Darwin)
	curl -sS -qL -o vendor/bin/terragrunt https://github.com/gruntwork-io/terragrunt/releases/latest/download/terragrunt_darwin_amd64
else
	$(error Unknown system)
endif
	@chmod 0755 vendor/bin/terragrunt

.PHONY: install
install: vendor/bin vendor/bin/terragrunt vendor/bin/terraform ## Install deps

# Terraform/ terragrunt
.PHONY:  tf-plan
tf-plan: install ## Terraform Plan
	cd ./deployments/environments/prod; terragrunt plan --terragrunt-non-interactive

.PHONY: tf-apply
tf-apply: install ## Terraform Apply
	cd ./deployments/environments/prod; terragrunt run-all apply --terragrunt-non-interactive

.PHONY: tf-destroy
tf-destroy: install ## Terraform Destroy
	cd ./deployments/environments/prod; terragrunt run-all destroy --terragrunt-non-interactive


# Docker/container commands
.PHONY: docker_clean
docker_clean: ## Remove running containers and data
	docker-compose down
	docker-compose rm -v -f -s
	docker volume rm technical-test_db_data

.PHONY: docker_purge
docker_purge: docker_clean ## Purge all docekr containers and images
	docker rm $(shell docker-compose ps -a -q)
	docker rmi $(shell docker-compose images -q)
	docker rmi $(shell docker images -q -f dangling=true)

.PHONY: build
build: ## Build a docker image
	docker build --network host -t wiki-check-sf-tech-test .
	docker system prune -f

.PHONY: docker_insertdata
docker_insertdata: up ## Insert data into dockercompose local version
	docker-compose exec db apt-get update
	docker-compose exec db apt-get install -y wget
	docker-compose exec db wget --quiet ${DATA_URL} -O /tmp/page_views.data.gz
	docker-compose exec db gunzip /tmp/page_views.data.gz
	docker-compose exec db mysqlimport --local --default-character-set=utf8 --columns=project_code,page_name,page_views,bytes --fields-terminated-by=' ' -pnotgod wikicheckdb /tmp/page_views.data

.PHONY: up
up: ## Bring up local Docker version
	docker-compose up -d

.PHONY: redeploy
redeploy: stop build up ## Redeploy local docker version

.PHONY: stop
stop: ## Stop local docker version
	docker-compose stop

.PHONY: logs
logs: up ## Get local docker logs
	docker-compose logs

# Deploying containers to AWS

.PHONY: ecr_login
ecr_login:
	#sh ./ecr.sh
	AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} ./ecr.sh

.PHONY: app_push
app_push: ecr_login build ## Push container build to ECR
	docker tag wiki-check-sf-tech-test:latest ${AWS_ACCOUND_ID}.dkr.ecr.eu-west-1.amazonaws.com/wiki-check-sf-tech-test:latest
	docker push ${AWS_ACCOUND_ID}.dkr.ecr.eu-west-1.amazonaws.com/wiki-check-sf-tech-test:latest
	AWS_PAGER="" aws ecs update-service --region eu-west-1 --cluster wiki-check-cluster --service tf-ecs-service --force-new-deployment
