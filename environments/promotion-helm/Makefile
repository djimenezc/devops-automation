
GITOPS_FOLDER ?= environments/promotion-helm/gitops

-include ../Makefile
-include ../../Makefile.argocd


.PHONY: create-apps
create-apps:
	$(MAKE) argocd-app-deploy APP_NAME=prod \
	REPO_URL=${REPO_URL} PATH=$(GITOPS_FOLDER)/envs/prod DEST_NAMESPACE=prod
	$(MAKE) argocd-app-deploy APP_NAME=qa \
	REPO_URL=${REPO_URL} PATH=$(GITOPS_FOLDER)/envs/qa DEST_NAMESPACE=qa
	$(MAKE) argocd-app-deploy APP_NAME=staging \
	REPO_URL=${REPO_URL} PATH=$(GITOPS_FOLDER)/envs/staging DEST_NAMESPACE=staging

envs-port-forwarding:
	kubectl port-forward svc/prod-simple-app-go-helm-simple-go-app -n prod 31002:8080 &
	kubectl port-forward svc/staging-simple-app-go-helm-simple-go-app -n staging 31001:8080 &
	kubectl port-forward svc/qa-simple-app-go-helm-simple-go-app -n qa 31000:8080 &

kill-port-forwarding:
	../kill-port-forwarding-process.sh

