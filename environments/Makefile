
-include ../Makefile.argocd

APP_BRANCH = feature/environment-promotion

.PHONY: create-apps
create-apps:
	$(MAKE) argocd-app-deploy APP_NAME=prod REPO_URL=https://github.com/djimenezc/devops-automation.git PATH=environments/envs/prod DEST_NAMESPACE=prod
	$(MAKE) argocd-app-deploy APP_NAME=qa REPO_URL=https://github.com/djimenezc/devops-automation.git PATH=environments/envs/qa DEST_NAMESPACE=qa
	$(MAKE) argocd-app-deploy APP_NAME=staging REPO_URL=https://github.com/djimenezc/devops-automation.git PATH=environments/envs/staging DEST_NAMESPACE=staging

envs-port-forwarding:
	kubectl port-forward svc/prod-simple-service -n prod 31002:8080 &
	kubectl port-forward svc/staging-simple-service -n staging 31001:8080 &
	kubectl port-forward svc/qa-simple-service -n qa 31000:8080 &

kill-port-forwarding:
	kill $(ps aux | grep "kubectl port-forward*" | awk '{print $2}')
