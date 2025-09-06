# devops-sandbox

## Killercoda demo

```bash
bash <(curl -s https://raw.githubusercontent.com/andrewozh/devops-sandbox/refs/heads/main/bootstrap/demo/bootstrap.sh)
```

## Keep repo clean

If an image is no longer neede, i prefer to completely remove it from git history to keep repo size under control

```bash
brew install bfg
bfg --delete-files pritunl-cloud-architecture.png
git reflog expire --expire=now --all && git gc --prune=now --aggressive
```
