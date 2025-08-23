.PHONY: kctx start stop olm argocd argocd-olm init
all: kctx start stop olm argocd argocd-olm init

define ADD_HOSTS
127.0.0.1       home.lab
127.0.0.1       argocd.home.lab
127.0.0.1       vault.home.lab
127.0.0.1       grafana.home.lab
127.0.0.1       prometheus.home.lab
127.0.0.1       kibana.home.lab
127.0.0.1       alertmanager.home.lab
endef
export ADD_HOSTS

kctx: ## Activate homelab kubecontext
	kubectl config use-context kind-homelab

create: ## Create homelab cluster
	kind get clusters | grep homelab || kind create cluster --config homelab.kind.yaml

delete: ## Delete existing cluster
	kind delete cluster -n homelab

start stop: create ## Start/Stop homelab kind cluster
	podman ps -aq --filter "name=homelab" | xargs podman "$@"

hosts: ## Patch /etc/hosts with homelab entries
	@echo "$$ADD_HOSTS" | while IFS= read -r line; do \
		grep -qF "$$line" /etc/hosts || { \
			echo "Adding: $$line"; \
			echo "$$line" | sudo tee -a /etc/hosts > /dev/null; \
		}; \
	done

ca: start ## Create CA for homelab
	kubectl create ns ingress || true
	kubectl create secret generic -n ingress ca --from-file=tls.crt=ca.crt --from-file=tls.key=ca.key
	sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ca.crt

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
	helmfile apply --suppress-diff -f _argocd/helmfile.yaml
	kubectl apply -f _argocd-infra/app.yaml
	@PASSWORD_HASH=$$(htpasswd -bnBC 10 "" admin | tr -d ':\n') && \
	kubectl patch secret -n argocd argocd-secret -p "$$(printf '{"stringData": {"admin.password": "%s"}}' "$$PASSWORD_HASH")"
	kubectl rollout restart deployment/argocd-server -n argocd
	#
	# Access ArgoCD UI:
	# kubectl port-forward svc/argocd-server -n argocd 8080:80
	#
	# Username: admin
	# Password: admin

init: argocd ## Init cluster
