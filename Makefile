.PHONY: help init plan apply destroy configure validate

help:
	@echo "Available commands:"
	@echo "  make init ENV=dev      - Initialize Terraform"
	@echo "  make plan ENV=dev      - Plan infrastructure"
	@echo "  make apply ENV=dev     - Deploy infrastructure"
	@echo "  make configure ENV=dev - Configure with Ansible"
	@echo "  make destroy ENV=dev   - Destroy infrastructure"

init:
	cd terraform/environments/$(ENV) && terraform init

plan:
	cd terraform/environments/$(ENV) && terraform plan

apply:
	cd terraform/environments/$(ENV) && terraform apply -auto-approve

configure:
	ansible-playbook -i ansible/inventories/$(ENV) ansible/playbooks/site.yml

destroy:
	cd terraform/environments/$(ENV) && terraform destroy -auto-approve

validate:
	./tests/terraform/validate.sh
	ansible-lint ansible/playbooks/*.yml
