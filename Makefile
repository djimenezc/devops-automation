CLUSTER_NAME ?= dev-cluster
export INGRESS_HOST=127.0.0.1

KIND_CONFIG_FILE ?= kind/kind-config-multi-cluster.yml
KIND_RUNTIME ?= podman
#k8s
kind-cluster-create-docker:
	kind create cluster --name $(CLUSTER_NAME) --config $(KIND_CONFIG_FILE)

kind-cluster-create-podman:
	KIND_EXPERIMENTAL_PROVIDER=podman kind create cluster --name $(CLUSTER_NAME) --config $(KIND_CONFIG_FILE)

kind-cluster-destroy-podman:
	KIND_EXPERIMENTAL_PROVIDER=podman kind delete cluster --name $(CLUSTER_NAME)

kind-cluster-destroy:
	kind delete cluster --name $(CLUSTER_NAME)

kind-cluster-get-info:
	kubectl cluster-info --context kind-dev-cluster

kind-cluster-create-full:
	-${MAKE} podman-init
	${MAKE} kind-cluster-create-${KIND_RUNTIME}
	${MAKE} kind-cluster-get-info
	kubectl label nodes dev-cluster-control-plane nodePool=cluster
	${MAKE} ingress-kind-nginx-install
	${MAKE} argocd-install
	${MAKE} argocd-ingress-apply
	${MAKE} argocd-get-admin-password
	${MAKE} argocd-login

-include ./Makefile.argocd
-include ./Makefile.ingress
-include ./Makefile.jenkins
-include ./Makefile.crossplane
-include ./Makefile.prometheus
-include ./Makefile.grafana
-include ./Makefile.qemu
-include ./Makefile.aws
-include ./Makefile.robusta
-include ./scripts/Makefile
-include ./ansible/Makefile
-include ./terraform/Makefile
-include ./k8s/Makefile
-include ./Makefile.podman
