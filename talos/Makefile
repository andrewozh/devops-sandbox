.PHONY: help setup-network create-configs cluster1-up cluster2-up clusters-up cluster1-down cluster2-down clusters-down clean

TALOSCTL = talosctl
PODMAN = podman

CLUSTER1_NAME = talos-cluster1
CLUSTER2_NAME = talos-cluster2

CLUSTER1_ENDPOINT = 127.0.0.1:6443
CLUSTER2_ENDPOINT = 127.0.0.1:6444

CLUSTER1_NODE_IP = 172.20.0.10
CLUSTER2_NODE_IP = 172.20.0.20

NETWORK_NAME = talos-net
NETWORK_SUBNET = 172.20.0.0/16

help: ## Show this help message
	@echo "Talos Dual Cluster Setup (Podman on macOS)"
	@echo ""
	@echo "Usage:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

setup-network: ## Create podman network for clusters
	@echo "Setting up network: $(NETWORK_NAME)"
	$(PODMAN) network exists $(NETWORK_NAME) || $(PODMAN) network create --subnet $(NETWORK_SUBNET) $(NETWORK_NAME)
	@echo "Network ready: $(NETWORK_NAME) ($(NETWORK_SUBNET))"

create-configs: ## Generate Talos configurations for both clusters
	@echo "Generating configurations..."
	@mkdir -p configs
	$(TALOSCTL) gen config $(CLUSTER1_NAME) https://$(CLUSTER1_ENDPOINT) \
		--output-dir configs/cluster1 \
		--with-examples=false \
		--with-docs=false
	$(TALOSCTL) gen config $(CLUSTER2_NAME) https://$(CLUSTER2_ENDPOINT) \
		--output-dir configs/cluster2 \
		--with-examples=false \
		--with-docs=false
	@echo "Configurations generated in configs/"

cluster1-up: setup-network create-configs ## Start cluster1
	@echo "Starting $(CLUSTER1_NAME)..."
	$(TALOSCTL) cluster create \
		--name $(CLUSTER1_NAME) \
		--provisioner container \
		--container-runtime podman \
		--network $(NETWORK_NAME) \
		--endpoint $(CLUSTER1_ENDPOINT) \
		--config-patch @configs/cluster1-patch.yaml \
		--workers 1 \
		--masters 1 \
		--wait

cluster2-up: setup-network create-configs ## Start cluster2
	@echo "Starting $(CLUSTER2_NAME)..."
	$(TALOSCTL) cluster create \
		--name $(CLUSTER2_NAME) \
		--provisioner container \
		--container-runtime podman \
		--network $(NETWORK_NAME) \
		--endpoint $(CLUSTER2_ENDPOINT) \
		--config-patch @configs/cluster2-patch.yaml \
		--workers 1 \
		--masters 1 \
		--wait

clusters-up: cluster1-up cluster2-up ## Start both clusters
	@echo "Both clusters are running!"
	@echo "Cluster1 endpoint: $(CLUSTER1_ENDPOINT)"
	@echo "Cluster2 endpoint: $(CLUSTER2_ENDPOINT)"

cluster1-down: ## Stop cluster1
	@echo "Stopping $(CLUSTER1_NAME)..."
	$(TALOSCTL) cluster destroy --name $(CLUSTER1_NAME) --provisioner container

cluster2-down: ## Stop cluster2
	@echo "Stopping $(CLUSTER2_NAME)..."
	$(TALOSCTL) cluster destroy --name $(CLUSTER2_NAME) --provisioner container

clusters-down: cluster1-down cluster2-down ## Stop both clusters

clean: clusters-down ## Clean up everything including network
	@echo "Cleaning up network..."
	$(PODMAN) network rm $(NETWORK_NAME) || true
	@echo "Removing config files..."
	rm -rf configs/
	@echo "Cleanup complete"

status: ## Show cluster status
	@echo "=== Cluster Status ==="
	@echo "Network:"
	@$(PODMAN) network ls | grep $(NETWORK_NAME) || echo "Network not found"
	@echo ""
	@echo "Containers:"
	@$(PODMAN) ps -a | grep talos || echo "No Talos containers running"

kubeconfig-cluster1: ## Get kubeconfig for cluster1
	$(TALOSCTL) --talosconfig configs/cluster1/talosconfig kubeconfig configs/cluster1/kubeconfig

kubeconfig-cluster2: ## Get kubeconfig for cluster2
	$(TALOSCTL) --talosconfig configs/cluster2/talosconfig kubeconfig configs/cluster2/kubeconfig

kubeconfigs: kubeconfig-cluster1 kubeconfig-cluster2 ## Get kubeconfigs for both clusters
	@echo "Kubeconfigs saved:"
	@echo "  Cluster1: configs/cluster1/kubeconfig"
	@echo "  Cluster2: configs/cluster2/kubeconfig"