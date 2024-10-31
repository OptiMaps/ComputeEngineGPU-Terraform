RED = $(shell tput -Txterm setab 1 && tput -Txterm setaf 0)
GREEN = $(shell tput -Txterm setab 2 && tput -Txterm setaf 0)
PURPLE = $(shell tput -Txterm setab 5 && tput -Txterm setaf 7)
RESET = $(shell tput -Txterm sgr0)

VAR_FILE = terraform.prod.tfvars

all: create

create: create-compute-engine

init: create-s3 create-compute-engine

create-s3:
	@echo ""
	@echo "$(GREEN) Terraform s3 init $(RESET)"
	@cd src/s3_init && terraform init
	@cd src/s3_init && terraform apply -auto-approve

create-compute-engine:
	@echo ""
	@echo "$(GREEN) Terraform compute engine init $(RESET)"
	@cd src && terraform init
	@cd src && terraform apply -auto-approve -var-file=$(VAR_FILE)

destroy-s3:
	@echo ""
	@echo "$(PURPLE) Terraform s3 destroy $(RESET)"
	@cd src/s3_init && terraform destroy -auto-approve

destroy-compute-engine:
	@echo ""
	@echo "$(PURPLE) Terraform compute engine destroy $(RESET)"
	@cd src && terraform destroy -auto-approve

clean: destroy-compute-engine

fclean: destroy-compute-engine destroy-s3

.PHONY: all create init clean fclean