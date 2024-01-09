
GITOPS_FOLDER ?= environments/promotion-helm

-include ../Makefile
-include ../../Makefile.argocd


.PHONY: create-apps
create-apps:
	$(MAKE) argocd-app-deploy APP_NAME=dev \
	REPO_URL=${REPO_URL} PATH=$(GITOPS_FOLDER)/gitops DEST_NAMESPACE=dev

.PHONY: delete-apps
delete-apps:
	$(MAKE) argocd-app-delete APP_NAME=dev

.PHONY: sync-apps
sync-apps:
	$(MAKE) argocd-app-sync APP_NAME=simple-app-go-prod
	$(MAKE) argocd-app-sync APP_NAME=simple-app-go-development
	$(MAKE) argocd-app-sync APP_NAME=simple-app-go-staging

