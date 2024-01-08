
USERNAME ?= djimenezc
DOCKER_REGISTRY ?= ghcr.io/djimenezc
DOCKER_PATH ?= $(DOCKER_REGISTRY)/devops-automation/simple-app-go
VERSION ?= 1.0.1

docker-build:
	docker build -f Dockerfile -t $(DOCKER_PATH):$(VERSION) --build-arg APP_VERSION=${VERSION} .

docker-push:
	docker push $(DOCKER_PATH):$(VERSION)

docker-login:
	@echo ${GITHUB_TOKEN} | docker login --username $(USERNAME) --password-stdin $(DOCKER_REGISTRY)

docker-run-remote:
	docker run -it --rm  --name simple-app-go -p 8080:8080 $(DOCKER_REGISTRY)simple-app-go:$(VERSION)
