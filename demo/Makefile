.PHONY: kctx demo create delete start stop
all: kctx demo create delete start stop

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

help: ## Show this message
	@echo "Suggested commands:"
	@echo
	@grep -E '^[ a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

kctx: ## Activate homelab kubecontext
	kubectl config use-context kind-homelab

create: ## Create homelab cluster
	kind get clusters | grep homelab || kind create cluster --config kind-homelab.yaml

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

demo: start hosts ca ## Bootstrap demo environment
