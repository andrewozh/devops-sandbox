.PHONY: help killercoda
all: help killercoda

help: ## Show this message
	@echo "Suggested commands:"
	@echo
	@grep -E '^[ a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

killercoda:
	kubectl apply -f local-git-server.yaml
	helm upgrade --install argocd ../_argocd  --namespace argocd --create-namespace  --values ../_argocd/values-override.yaml --timeout 800s --atomic --dependency-update
	apt install apache2-utils -y
	@PASSWORD_HASH=$$(htpasswd -bnBC 10 "" admin | tr -d ':\n') && \
	kubectl patch secret -n argocd argocd-secret -p "$$(printf '{"stringData": {"admin.password": "%s"}}' "$$PASSWORD_HASH")"
	kubectl rollout restart deployment/argocd-server -n argocd
	cat ../_argocd-infra/app.yaml | sed 's|https://github.com/andrewozh/infra-apps.git|git://git-server.default.svc.cluster.local/|g' | yq '.spec.source.helm.valueFiles = ["../demo.yaml"]' | kubectl apply -f -
	kubectl expose -n argocd deployment argocd-server --type=NodePort --port=8080 --name=argocd-nodeport
	kubectl patch svc argocd-nodeport -n argocd --type='json' -p='[{"op":"add","path":"/spec/ports/0/nodePort","value":30080}]'
	#
	# Access ArgoCD UI:
	# Upper Right corner -> Traffic / Ports -> 30080
	#
	# Username: admin
	# Password: admin
