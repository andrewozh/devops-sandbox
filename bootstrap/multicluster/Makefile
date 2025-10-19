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

create: ## Create kind multi-cluster
	docker network create --driver=bridge --subnet=172.20.0.0/16 --gateway=172.20.0.1 kind-multicluster 2>/dev/null || true
	kind get clusters | grep common || kind create cluster --config common/kind.yaml
	kind get clusters | grep stage || kind create cluster --config stage/kind.yaml
	docker network connect --ip=172.20.1.10 kind-multicluster common-control-plane 2>/dev/null || true
	docker network connect --ip=172.20.1.20 kind-multicluster stage-control-plane 2>/dev/null || true
	docker network connect --ip=172.20.1.11 kind-multicluster common-worker 2>/dev/null || true
	docker network connect --ip=172.20.1.21 kind-multicluster stage-worker 2>/dev/null || true

delete: ## Delete existing cluster and custom network
	kind delete cluster -n common
	kind delete cluster -n stage
	docker network rm kind-multicluster 2>/dev/null || true

start stop: create ## Start/Stop kind multi-cluster
	docker ps -aq --filter "name=common" | xargs docker "$@"
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

ca: start ## Create CA for common
	kubectl --context kind-common create ns ingress || true
	kubectl --context kind-common create secret generic -n ingress ca --from-file=tls.crt=../kind/ca.crt --from-file=tls.key=../kind/ca.key || true
	kubectl --context kind-stage create ns ingress || true
	kubectl --context kind-stage create secret generic -n ingress ca --from-file=tls.crt=../kind/ca.crt --from-file=tls.key=../kind/ca.key || true

argocd: kctx-common ## Deploy argocd as Helm Chart
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

argocd-add-stage:
	kubectl --context=kind-stage apply -f argocd-sa-stage.yaml
	@TOKEN=$$(kubectl --context=kind-stage get secret argocd-manager-token -n kube-system -o jsonpath='{.data.token}' | base64 -d) \
	CA_CERT=$$(kubectl --context=kind-stage config view --raw --minify --flatten -o jsonpath='{.clusters[0].cluster.certificate-authority-data}') \
	STAGE_IP=172.20.1.20 \
	envsubst < argocd-cluster-stage-secret.yaml | kubectl --context=kind-common apply -f -

istio:
	bash istio-setup.sh

dnsmasq:
	sudo mkdir -p /etc/resolver
	echo "nameserver 127.0.0.1" | sudo tee /etc/resolver/local

proxy:
	docker-compose up -d

init: create ca argocd argocd-add-stage proxy ## istio dnsmasq
