
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
	kubectl create namespace argocd-image-updater || true
	kubectl -n argocd-image-updater delete secret git-creds || true
	@echo 'Create secret'
	@kubectl -n argocd-image-updater create secret generic git-creds \
	--from-file=sshPrivateKey=$(SSH_KEY_FILE)
