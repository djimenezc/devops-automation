
GITOPS_FOLDER ?= environments/promotion-helm

-include ../Makefile
-include ../../Makefile.argocd


.PHONY: create-apps
create-apps:
	$(MAKE) argocd-app-deploy APP_NAME=qa \
	REPO_URL=${REPO_URL} PATH=$(GITOPS_FOLDER)/envs/qa DEST_NAMESPACE=qa

envs-port-forwarding:
	kubectl port-forward svc/qa-simple-app-go-helm-simple-go-app -n qa 31000:8080 &

kill-port-forwarding:
	../kill-port-forwarding-process.sh

