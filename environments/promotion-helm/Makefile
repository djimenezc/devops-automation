
GITOPS_FOLDER ?= environments/promotion-helm

-include ../Makefile
-include ../../Makefile.argocd


.PHONY: create-apps
create-apps:
	$(MAKE) argocd-app-deploy APP_NAME=prod \
	REPO_URL=https://github.com/djimenezc/devops-automation.git PATH=$(GITOPS_FOLDER)/envs/prod DEST_NAMESPACE=prod

.PHONY: delete-apps
delete-apps:
	$(MAKE) argocd-app-delete APP_NAME=prod

.PHONY: sync-apps
sync-apps:
	$(MAKE) argocd-app-sync APP_NAME=prod

envs-port-forwarding:
	kubectl port-forward svc/prod-simple-service -n prod 31002:8080 &
	kubectl port-forward svc/staging-simple-service -n staging 31001:8080 &
	kubectl port-forward svc/qa-simple-service -n qa 31000:8080 &


kustomize:
	kustomize build envs/prod
