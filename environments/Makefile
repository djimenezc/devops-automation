
-include ../Makefile.argocd

APP_BRANCH = feature/environment-promotion

.PHONY: create-apps
create-apps:
	$(MAKE) argocd-app-deploy APP_NAME=prod REPO_URL=https://github.com/djimenezc/devops-automation.git PATH=environments/envs/prod DEST_NAMESPACE=prod
