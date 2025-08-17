# devops-sandbox

```bash
bash <(curl -s https://raw.githubusercontent.com/andrewozh/devops-sandbox/refs/heads/main/demo/bootstrap.sh)"
```


## TODO

- [ ] github actions and reusable workflows markdown documentation generator

## Prerequisits

Kubernetes cluster:
* deploy `eks-common` using terragrunt
* or deploy local homelab using `make homelab`
* update-kubeconfig and use appropriate context

## Bootstrap

```bash
# simple: argocd via helm chart (recommended)
make argocd
# advanced: argocd via OLM
make argocd-olm
```

## Docs

```bash
pyenv activate 3.10.16
pip install mkdocs
mkdocs serve
```
