.PHONY: kctx olm argocd argocd-olm init
all: kctx olm argocd argocd-olm init

help: ## Show this message
	@echo "Suggested commands:"
	@echo
	@grep -E '^[ a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

kctx: ## Activate homelab kubecontext
	kubectl config use-context kind-homelab

olm: kctx ## Deploy Operator Lifecycle Manager
	# https://github.com/argoproj-labs/argocd-operator/issues/945
	operator-sdk olm status || (operator-sdk olm install ; kubectl label namespace olm pod-security.kubernetes.io/enforce=baseline --overwrite)

argocd-olm: kctx olm ## Deploy argocd via OLM
	kubectl apply -k _argocd-infra/olm-catalog-source/
	kubectl apply -k _argocd-infra/olm-subscription/
	while ! kubectl get crd argocds.argoproj.io 2>/dev/null ; do sleep 1 ; done
	kubectl apply -k _argocd-infra/

argocd: kctx ## Deploy argocd as Helm Chart
	kubectl create ns argocd || true
	helmfile apply -f _argocd/helmfile.yaml
	kubectl apply -f _argocd-infra/app.yaml
	# Reset ArgoCD admin password:
	# kubectl patch secret -n argocd argocd-secret -p '{"stringData": { "admin.password": "'$(htpasswd -bnBC 10 "" HxtjMoorHhGW-ESX | tr -d ':\n')'"}}'
	#
	# Restart ArgoCD server to apply changes:
	# kubectl rollout restart deployment/argocd-server -n argocd
	#
	# Access ArgoCD UI:
	# kubectl port-forward svc/argocd-server -n argocd 8080:80

init: argocd ## Init cluster
