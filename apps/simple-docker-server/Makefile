
DOCKER_REGISTRY ?= ghcr.io/djimenezc/devops-automation/
VERSION ?= 1.0

docker-build:
	docker build -f Dockerfile -t simple-app-go --build-arg APP_VERSION=${appVersion} .

docker-run:
	docker run -it --rm  --name simple-app-go -p 8080:8080 simple-app-go

docker-run-remote:
	docker run -it --rm  --name simple-app-go -p 8080:8080 $(DOCKER_REGISTRY)simple-app-go:$(VERSION)
