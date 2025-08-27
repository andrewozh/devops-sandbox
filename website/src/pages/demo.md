---
hide_table_of_contents: true
---

# DevOps Sandbox Demo

## Local setup on Kind

import BrowserOnly from '@docusaurus/BrowserOnly';

<BrowserOnly>
{() => {
  const getOSInfo = () => {
    const userAgent = window.navigator.userAgent;
    const platform = window.navigator.platform;
    
    if (userAgent.includes('Mac') || platform.includes('Mac')) {
      return { name: 'macOS', color: 'success', message: 'Your OS is supported for local demo', icon: '🍎' };
    } else if (userAgent.includes('Linux') || platform.includes('Linux')) {
      return { name: 'Linux', color: 'warning', message: 'Local demo not tested on your OS', icon: '🐧' };
    } else if (userAgent.includes('Win') || platform.includes('Win')) {
      return { name: 'Windows', color: 'warning', message: 'Local demo not tested on your OS', icon: '🪟' };
    } else if (userAgent.includes('iPhone') || userAgent.includes('iPad')) {
      return { name: 'iOS', color: 'danger', message: 'You can\'t run local demo on your OS', icon: '📱' };
    } else if (userAgent.includes('Android')) {
      return { name: 'Android', color: 'danger', message: 'You can\'t run local demo on your OS', icon: '🤖' };
    } else {
      return { name: 'Unknown', color: 'danger', message: 'You can\'t run local demo on your OS', icon: '❓' };
    }
  };
  const osInfo = getOSInfo();
  return (
    <div className={`alert alert--${osInfo.color}`} role="alert" style={{ marginBottom: '1.5rem' }}>
      <span style={{ fontSize: '1.2rem', marginRight: '0.5rem', marginBottom: '0.5rem' }}>{osInfo.icon}</span>
      <strong>{osInfo.name}</strong> | {osInfo.message}
    </div>
  );
}}
</BrowserOnly>

### 1. bootstrap

:::warning Requirements
- **macOS/Linux**
- **podman, kind**
- **sudo** - for installing home.lab local certs (do not trust, just check the code)
:::

```bash
bash <(curl -s https://raw.githubusercontent.com/andrewozh/devops-sandbox/refs/heads/main/bootstrap/kind/bootstrap.sh)
```

### 2. port-forward argocd and see the sync process

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:80
```

:::tip Access ArgoCD UI
- http://localhost:8080
- Username: admin
- Password: admin
:::

:::note Essential apps
  - argocd (admin/admin)
  - ingress-nginx
  - cert-manager
  - prometheus-stack
:::

#### iframe browser

:::note Links
- https://argocd.home.lab
- https://grafana.home.lab
- https://kibana.home.lab
- https://vault.home.lab
:::

### 3. Sync other infra apps

:::note Required apps
- vault
- external-secrets
- elk
:::

:::note Optional apps
- postgres
- kafka
- mongo
- redis
- clickhouse
:::

### (TODO) 4. Deploy demo apps: producer/consumer 

- have web-ui
- shows secrets
- db connection status
- shows data from databases
- add message in producer-app
- appear message in consumer app
- have metrics

---

## KILLERCODA

:::note Free online kubernetes playground
- https://killercoda.com/playgrounds/scenario/kubernetes
- `2 x 2Gb` or `1 x 4Gb`
:::

```bash
bash <(curl -s https://raw.githubusercontent.com/andrewozh/devops-sandbox/refs/heads/main/bootstrap/demo/bootstrap.sh)
```

