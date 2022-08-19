ANSIBLE_PLAYBOOK_NAME=security-scanner.yml
ENABLE_DEBUG ?= 0
export ANSIBLE_DEBUG = $(shell [ ${ENABLE_DEBUG} -eq '1' ] && echo 'True' || echo 'False')

SELF_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
INVENTORY_FILE ?= ${SELF_DIR}inventory/aws_ec2.yml
INVENTORY_PARAM = $(shell test -f ${INVENTORY_FILE} && echo '-i ${INVENTORY_FILE}' || echo '')
# Ansible filter to limit the hosts in the inventory to the ones in the current region
ANSIBLE_HOSTS_SUBSET ?= -l ${AWS_DEFAULT_REGION}
ANSIBLE_SSH_PRIVATE_KEY_FILE ?=~/.ssh/david-key.pem

ansible-inventory:
	@cd ${SELF_DIR}
	ansible-inventory --graph $(INVENTORY_PARAM)

ansible-inventory-list:
	@cd ${SELF_DIR}
	ansible-inventory --list $(INVENTORY_PARAM)

ansible-galaxy:
	@echo "Installing galaxy requirements"
	@!(test -f ${SELF_DIR}requirements.yml) && echo "No requirements found" || \
	ansible-galaxy install -r ${SELF_DIR}requirements.yml -f

ansible-ping:
	cd ${SELF_DIR}
	ansible tag_Name_david_security_scanner $(INVENTORY_PARAM) ${ANSIBLE_HOSTS_SUBSET} -m ping

ansible-playbook:
	@echo "Executing playbook:${ANSIBLE_PLAYBOOK_NAME} & \
	region:${AWS_DEFAULT_REGION} && inventory_param $(INVENTORY_PARAM)"
	!(test -f ${SELF_DIR}${ANSIBLE_PLAYBOOK_NAME}.yml) && echo "No ${SELF_DIR}${ANSIBLE_PLAYBOOK_NAME} playbook found" \
	 || ansible-playbook ${SELF_DIR}${ANSIBLE_PLAYBOOK_NAME}.yml ${INVENTORY_PARAM} ${ANSIBLE_HOSTS_SUBSET}

ansible-playbook-debug:
	${MAKE} ansible-playbook ANSIBLE_PLAYBOOK_NAME=debug

ansible-playbook-security-scanner:
	${MAKE} ansible-playbook ANSIBLE_PLAYBOOK_NAME=configure_security_scanner

ansible-playbook-ubuntu:
	${MAKE} ansible-playbook ANSIBLE_PLAYBOOK_NAME=configure_ubuntu
