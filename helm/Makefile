
CHART_NAME ?= simple-go-app
USERNAME ?= djimenezc
REGISTRY ?= ghcr.io/${USERNAME}
CHART_VERSION ?=$(shell helm show chart simple-go-app | awk -F ':' '/version: / {print $$2}' | xargs)

.PHONY: helm-version
helm-version:
	@echo $(CHART_VERSION)

.PHONY: helm-package
helm-package:
	helm package $(CHART_NAME)

.PHONY: helm-login
helm-login:
	@echo ${GITHUB_TOKEN} | helm registry login $(REGISTRY) --username $(USERNAME) --password-stdin

.PHONY: helm-push
helm-push:
	@echo Publishing version $(CHART_VERSION) of $(CHART_NAME) chart
	helm push ./$(CHART_NAME)-$(CHART_VERSION).tgz oci://$(REGISTRY)/helm
