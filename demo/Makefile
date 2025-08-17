.PHONY: help killercoda
all: help killercoda

help: ## Show this message
	@echo "Suggested commands:"
	@echo
	@grep -E '^[ a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

killercoda:
	kubectl apply -f local-git-server.yaml
	helm upgrade --install argocd _argocd  --namespace argocd --create-namespace  --values ../_argocd/values-override.yaml --timeout 800s --atomic --dependency-update
	cat ../_argocd-infra/app.yaml | sed 's|https://github.com/andrewozh/infra-apps.git|http://git-server.default.svc.cluster.local/.git|g' | yq '.spec.source.helm.parameters = [{"name": "repo", "value": "http://git-server.default.svc.cluster.local/.git"}] + (.spec.source.helm.parameters // [])' | kubectl apply -f -
	@PASSWORD_HASH=$$(htpasswd -bnBC 10 "" admin | tr -d ':\n') && \
	kubectl patch secret -n argocd argocd-secret -p "$$(printf '{"stringData": {"admin.password": "%s"}}' "$$PASSWORD_HASH")"
	kubectl rollout restart deployment/argocd-server -n argocd
