
docker-build:
	docker build -f Dockerfile -t simple-app-go --build-arg APP_VERSION=${appVersion} .

docker-run:
	docker run -it --rm  --name simple-app-go -p 8080:8080 simple-app-go
