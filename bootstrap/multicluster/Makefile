.PHONY: kctx create delete start stop hosts ca olm argocd argocd-olm init
all: kctx create delete start stop hosts ca olm argocd argocd-olm init

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

kctx-common: ## Activate homelab kubecontext
	kubectl config use-context kind-common

kctx-stage: ## Activate homelab kubecontext
	kubectl config use-context kind-stage

create-common: ## Create common cluster
	kind get clusters | grep common || kind create cluster --config common/kind.yaml:

create-ctage: ## Create stage cluster
	kind get clusters | grep stage || kind create cluster --config stage/kind.yaml

delete: ## Delete existing cluster
	kind delete cluster -n common
	kind delete cluster -n stage

start-common stop-common: create-common ## Start/Stop common kind cluster
	docker ps -aq --filter "name=common" | xargs docker "$@"

start-stage stop-stage: create-stage ## Start/Stop stage kind cluster
	docker ps -aq --filter "name=stage" | xargs docker "$@"

host: ## Configure host machine: dns, cert, reute
	@echo "$$ADD_HOSTS" | while IFS= read -r line; do \
		grep -qF "$$line" /etc/hosts || { \
			echo "Adding: $$line"; \
			echo "$$line" | sudo tee -a /etc/hosts > /dev/null; \
		}; \
	done
	# Warning: These routes are temporary and need to be re-added after restart
	sudo route -n add -net 172.18.255.0/24 $$(docker network inspect kind -f "{{(index .IPAM.Config 0).Gateway}}")
	sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ca.crt || true

ca-common: start-common ## Create CA for homelab
	kubectl --context kind-common create ns ingress || true
	kubectl --context kind-common create secret generic -n ingress ca --from-file=tls.crt=../kind/ca.crt --from-file=tls.key=../kind/ca.key || true

argocd: kctx ## Deploy argocd as Helm Chart
	kubectl create ns argocd || true
	helmfile apply --suppress-diff -f ../../_argocd/helmfile.yaml
	kubectl apply -f ../../_argocd-infra/app.yaml
	@PASSWORD_HASH=$$(htpasswd -bnBC 10 "" admin | tr -d ':\n') && \
	kubectl patch secret -n argocd argocd-secret -p "$$(printf '{"stringData": {"admin.password": "%s"}}' "$$PASSWORD_HASH")"
	kubectl rollout restart deployment/argocd-server -n argocd
	#
	# Access ArgoCD UI:
	# kubectl port-forward svc/argocd-server -n argocd 8080:80
	#
	# Username: admin
	# Password: admin

init: hosts ca argocd ## Init cluster
