.ONESHELL: # Applies to every targets in the file!
SELF_DIR_K8S := $(dir $(lastword $(MAKEFILE_LIST)))

k8s-current-context:
	@kubectl config current-context

k8s-manifest-folder:
	@echo ${SELF_DIR_K8S}

dattree-install:
	curl https://get.datree.io | /bin/bash

-include ./${SELF_DIR_K8S}popeye/Makefile
