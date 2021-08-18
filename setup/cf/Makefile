.PHONY: update
update:
	aws-vault exec techtest.scalefactory.net -- sh  ./update.sh

.PHONY: rotate_password
rotate_password:
	aws-vault exec techtest.scalefactory.net -- sh  ./rotate_password.sh | tee -a ../../INSTRUCTIONS.md

.PHONY: add_keys
add_keys:
	aws-vault exec techtest.scalefactory.net -- sh  ./add_keys.sh | tee -a ../../INSTRUCTIONS.md
	@sleep 10

.PHONY: rotate_keys
rotate_keys:
	aws-vault exec techtest.scalefactory.net -- sh  ./delete_keys.sh
	$(MAKE) add_keys

.PHONY: create_cf
create_cf:
	aws-vault exec techtest.scalefactory.net -- sh  ./create.sh
	@echo "Sleepy time... Waiting for CloudFormation stack"
	@aws-vault exec techtest.scalefactory.net -- sh  ./wait.sh
	$(MAKE) add_keys

.PHONY: create
create:
	@-sh ./check_stack.sh && ([ $$? -eq 0 ] && $(MAKE) update) || $(MAKE) create_cf
	$(MAKE) rotate_password


.PHONY: delete
delete:
	aws-vault exec techtest.scalefactory.net -- sh  ./delete.sh
