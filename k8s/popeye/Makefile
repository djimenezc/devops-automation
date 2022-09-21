.ONESHELL: # Applies to every targets in the file!
SELF_DIR_K8S_POPEYE := $(dir $(lastword $(MAKEFILE_LIST)))

k8s-popeye-apply:
	kubectl apply -f ./${SELF_DIR_K8S_POPEYE}ns.yml
	kubectl apply -f ./${SELF_DIR_K8S_POPEYE}serviceAccount.yml
	kubectl apply -f ./${SELF_DIR_K8S_POPEYE}clusterRole.yml
	kubectl apply -f ./${SELF_DIR_K8S_POPEYE}clusterRoleBinding.yml
	kubectl apply -f ./${SELF_DIR_K8S_POPEYE}cronJob.yml

k8s-popeye-delete:
	kubectl delete --ignore-not-found=true -f ./${SELF_DIR_K8S_POPEYE}cronJob.yml
	kubectl delete --ignore-not-found=true -f ./${SELF_DIR_K8S_POPEYE}clusterRoleBinding.yml
	kubectl delete --ignore-not-found=true -f ./${SELF_DIR_K8S_POPEYE}clusterRole.yml
	kubectl delete --ignore-not-found=true -f ./${SELF_DIR_K8S_POPEYE}serviceAccount.yml
	kubectl delete --ignore-not-found=true -f ./${SELF_DIR_K8S_POPEYE}ns.yml

k8s-popeye-manifest-validation:
	datree test ./${SELF_DIR_K8S_POPEYE}*.yml
