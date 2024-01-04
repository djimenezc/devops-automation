#MYSQL_CONTAINER_ID=$(shell podman ps -a --filter name=mysql --format '{{.ID}}')
MYSQL_CONTAINER_ID=$(shell docker ps -a --filter name=mysql --format '{{.ID}}')
MERMAID_DIAGRAM_FORMAT ?= pdf
MERMAID_DIAGRAM_COMMAND ?= schema
ELK_SINGLE_NODE ?= true

ifeq ($(ELK_SINGLE_NODE), true)
	ELASTIC_COMPOSE_FILE = docker-compose.elk.single-node.yml
else
	ELASTIC_COMPOSE_FILE = docker-compose.elk.multiple-node.yml
endif

#podman-init:
#	-podman machine init -v ${HOME}:${HOME}
#	podman machine start
#	${MAKE} podman-networking-init
#	podman pull mysql:5.7 --platform linux/amd64
#	podman machine ssh sudo rpm-ostree install qemu-user-static
#	podman machine ssh sudo systemctl reboot
#
#podman-destroy:
#	podman system connection default podman-machine-default
#	podman machine stop
#	podman machine rm
#
#podman-run-mysql:
#	@if ! podman inspect mysql > /dev/null ;  then \
#        echo "podman run mysql-server"; \
#        podman run --detach --restart always --platform linux/amd64 --network=capi -p 3306:3306 --name mysql --env MYSQL_ALLOW_EMPTY_PASSWORD=true --volume resources:/etc/mysql/conf.d mysql:5.7; \
#    fi

#docker

docker-compose-up: docker-networking-init
	docker-compose -f docker-compose.mysql.yml -f docker-compose.redis.yml -f docker-compose.db-tools.yml \
	-f docker-compose.elk.yml -f $(ELASTIC_COMPOSE_FILE) up --remove-orphans

docker-compose-down: docker-networking-destroy
	docker-compose -f docker-compose.yml -f docker-compose.elk.yml -f $(ELASTIC_COMPOSE_FILE) down -v --remove-orphans
	${MAKE} elk-clean-data

docker-compose-servers-up: docker-networking-init
	docker-compose -f docker-compose.mysql.yml -f docker-compose.redis.yml -f $(ELASTIC_COMPOSE_FILE) up

docker-compose-servers-down:
	docker-compose -f docker-compose.mysql.yml -f docker-compose.redis.yml -f $(ELASTIC_COMPOSE_FILE) down -v
	${MAKE} elk-clean-data

docker-compose-mysql-up:
	docker-compose -f docker-compose.mysql.yml up

docker-compose-mysql-down:
	docker-compose -f docker-compose.mysql.yml down -v

docker-compose-redis-up:
	docker-compose -f docker-compose.redis.yml up

docker-compose-redis-down:
	docker-compose -f docker-compose.redis.yml down -v

docker-compose-elastic-up:
	docker-compose -f $(ELASTIC_COMPOSE_FILE) up

docker-compose-elastic-down:
	docker-compose -f $(ELASTIC_COMPOSE_FILE) down -v

docker-compose-logs:
	docker-compose logs

docker-kill-mysql:
	-docker stop $(MYSQL_CONTAINER_ID)
	docker rm $(MYSQL_CONTAINER_ID)

docker-networking-init:
	-docker network create capi
	docker network inspect capi

docker-networking-destroy:
	-docker network rm capi

docker-monitor-processes:
	watch docker ps

# Watchers
get-elk-status:
	@echo Elasticsearch cluster status:
	@curl --silent http://localhost:9200/_cluster/health | jq -r .status

get-kibana-status:
	@echo Kibana status:
	@curl -s http://127.0.0.1:5601/api/status | jq -r .status.overall.state

get-logstash-status:
	@echo Logstash status:
	@curl -s 'localhost:9600/?pretty' | jq -r .status

watch-elk-processes:
	watch "${MAKE} get-elk-status && ${MAKE} get-logstash-status && ${MAKE} get-kibana-status"

# elK
elk-ingest-logs-example:
	cat logstash/testing/Linux_2k.log | nc localhost 5000

elk-clean-data:
	rm -rf **/{logs,data}/*

-include ./Makefile.mysql

#k8s

k8s-kind-create-cluster:
	kind create cluster --name savi

k8s-kind-destroy-cluster:
	kind delete cluster --name savi

# Ansible

ansible-install:
	python -m pip install --user ansible
