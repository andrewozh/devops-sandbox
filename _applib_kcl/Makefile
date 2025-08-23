# 🚀 YAML + KCL Hybrid Application Generator

.PHONY: help demo manifests deploy clean install-kcl check-kcl

help: ## Show available commands
	@echo "🚀 YAML + KCL Hybrid Application Generator"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Quick start: make demo"

demo: ## Run the full demo (loads YAML configs and generates manifests)
	@echo "🎯 Running YAML + KCL hybrid demo..."
	@kcl app.k

manifests: ## Generate and output Kubernetes manifests only  
	@echo "📦 Generating Kubernetes manifests..."
	@kcl app.k --format yaml | grep -A 1000 "manifests:" | tail -n +2

manifests-file: ## Save manifests to file
	@echo "💾 Saving manifests to manifests.yaml..."
	@kcl app.k --format yaml | grep -A 1000 "manifests:" | tail -n +2 > manifests.yaml
	@echo "✅ Manifests saved to manifests.yaml"

deploy: ## Deploy manifests to Kubernetes (requires kubectl)
	@echo "🚀 Deploying to Kubernetes..."
	@kcl app.k --format yaml | grep -A 1000 "manifests:" | tail -n +2 | kubectl apply -f -

deploy-dry: ## Dry-run deployment to Kubernetes
	@echo "🧪 Dry-run deployment..."
	@kcl app.k --format yaml | grep -A 1000 "manifests:" | tail -n +2 | kubectl apply --dry-run=client -f -

check-kcl: ## Check if KCL is installed
	@which kcl > /dev/null || (echo "❌ KCL not found. Run 'make install-kcl' to install it." && exit 1)
	@echo "✅ KCL is installed: $$(kcl --version)"

install-kcl: ## Install KCL
	@echo "📥 Installing KCL..."
	@curl -fsSL https://kcl-lang.io/script/install.sh | /bin/bash
	@echo "✅ KCL installed successfully!"

clean: ## Clean generated files
	@rm -f manifests.yaml
	@echo "🧹 Cleaned generated files"

edit-prod: ## Edit production configuration
	@echo "📝 Opening production config..."
	@${EDITOR:-vim} examples/production.yaml

edit-dev: ## Edit development configuration  
	@echo "📝 Opening development config..."
	@${EDITOR:-vim} examples/development.yaml

validate: ## Validate syntax and show summary
	@echo "✅ KCL syntax validation..."
	@kcl app.k --format yaml | grep -A 20 "summary:" | head -25