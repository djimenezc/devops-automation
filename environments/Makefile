
-include ../Makefile.argocd

APP_BRANCH = feature/environment-promotion
REPO_URL = git@github.com:djimenezc/devops-automation.git
SSH_KEY_FILE = /Users/david/.ssh/github_djimenez

kill-port-forwarding:
	./kill-port-forwarding-process.sh

argocd-add-repo-creds:
	argocd repo add $(REPO_URL) --ssh-private-key-path $(SSH_KEY_FILE)

argocd-add-repo:
	argocd repo add ghcr.io/djimenezc/helm --type helm --name stable --enable-oci --username djimenezc --password ${GITHUB_TOKEN}

create-image-updater-secret:
	kubectl create namespace argocd || true
	kubectl -n argocd delete secret git-creds || true
	@echo 'Create secret'
	@kubectl -n argocd create secret generic git-creds \
	--from-file=sshPrivateKey=$(SSH_KEY_FILE)

apps-install:
	$(MAKE) argocd-app-deploy APP_NAME=apps \
	REPO_URL=${REPO_URL} PATH=environments/apps DEST_NAMESPACE=argocd

apps-delete:
	$(MAKE) argocd-app-delete APP_NAME=prod

.PHONY: delete-apps
delete-apps:
	$(MAKE) argocd-app-delete APP_NAME=prod
	$(MAKE) argocd-app-delete APP_NAME=qa
	$(MAKE) argocd-app-delete APP_NAME=staging

.PHONY: sync-apps
sync-apps:
	$(MAKE) argocd-app-sync APP_NAME=prod
	$(MAKE) argocd-app-sync APP_NAME=qa
	$(MAKE) argocd-app-sync APP_NAME=staging
