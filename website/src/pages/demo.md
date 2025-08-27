---
hide_table_of_contents: true
---

# DevOps Sandbox Demo

## Local setup on Kind

import React from 'react';
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

#### Web Browser Interface

<BrowserOnly fallback={<div>Loading browser interface...</div>}>
  {() => {
    const [activeTab, setActiveTab] = React.useState('localhost');
    const [tabs, setTabs] = React.useState([
      {
        id: 'localhost',
        name: 'ArgoCD (localhost)',
        url: 'http://localhost:8080',
        status: 'checking'
      },
      {
        id: 'argocd',
        name: 'ArgoCD',
        url: 'https://argocd.home.lab',
        status: 'checking'
      },
      {
        id: 'grafana',
        name: 'Grafana',
        url: 'https://grafana.home.lab',
        status: 'checking'
      },
      {
        id: 'kibana',
        name: 'Kibana',
        url: 'https://kibana.home.lab',
        status: 'checking'
      },
      {
        id: 'vault',
        name: 'Vault',
        url: 'https://vault.home.lab',
        status: 'checking'
      }
    ]);
    const [iframeErrors, setIframeErrors] = React.useState(new Set());

    const checkURLAccessibility = async (url) => {
      try {
        const response = await fetch(url, { 
          method: 'GET',
          mode: 'no-cors',
          cache: 'no-cache'
        });
        return true;
      } catch (error) {
        return false;
      }
    };

    React.useEffect(() => {
      const checkAllTabs = async () => {
        const updatedTabs = await Promise.all(
          tabs.map(async (tab) => {
            const isAccessible = await checkURLAccessibility(tab.url);
            return {
              ...tab,
              status: isAccessible ? 'online' : 'offline'
            };
          })
        );
        setTabs(updatedTabs);
      };

      checkAllTabs();
      const interval = setInterval(checkAllTabs, 10000);
      return () => clearInterval(interval);
    }, []);

    const browserStyle = {
      width: '100%',
      background: 'var(--ifm-color-emphasis-100)',
      borderRadius: '12px',
      overflow: 'hidden',
      boxShadow: '0 8px 32px rgba(0, 0, 0, 0.1)',
      border: '1px solid var(--ifm-color-emphasis-200)',
      marginTop: '1rem'
    };

    const headerStyle = {
      background: 'var(--ifm-color-emphasis-200)',
      borderBottom: '1px solid var(--ifm-color-emphasis-300)',
      display: 'flex',
      alignItems: 'center',
      padding: '0.75rem 1rem',
      gap: '1rem'
    };

    const controlsStyle = {
      display: 'flex',
      gap: '0.5rem',
      alignItems: 'center'
    };

    const controlButtonStyle = {
      width: '12px',
      height: '12px',
      borderRadius: '50%',
      cursor: 'pointer'
    };

    const tabsStyle = {
      display: 'flex',
      gap: '0.25rem',
      flex: 1,
      overflowX: 'auto'
    };

    const getTabStyle = (tab) => ({
      background: activeTab === tab.id ? 'var(--ifm-color-emphasis-100)' : 'var(--ifm-color-emphasis-300)',
      border: 'none',
      borderRadius: '8px 8px 0 0',
      padding: '0.5rem 1rem',
      cursor: 'pointer',
      display: 'flex',
      alignItems: 'center',
      gap: '0.5rem',
      transition: 'all 0.2s ease',
      minWidth: '180px',
      color: 'var(--ifm-font-color-base)',
      borderBottom: activeTab === tab.id ? '2px solid var(--ifm-color-primary)' : '2px solid transparent',
      borderLeft: tab.status === 'online' ? '3px solid #22c55e' : tab.status === 'offline' ? '3px solid #ef4444' : '3px solid #f59e0b'
    });

    const contentStyle = {
      height: '500px',
      position: 'relative',
      background: 'white'
    };

    const iframeStyle = {
      width: '100%',
      height: '100%',
      border: 'none',
      background: 'white'
    };

    const offlineStyle = {
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      height: '100%',
      textAlign: 'center',
      color: 'var(--ifm-font-color-base)',
      padding: '2rem'
    };

    return (
      <div style={browserStyle}>
        <div style={headerStyle}>
          <div style={controlsStyle}>
            <div style={{...controlButtonStyle, backgroundColor: '#ff5f57'}}></div>
            <div style={{...controlButtonStyle, backgroundColor: '#ffbd2e'}}></div>
            <div style={{...controlButtonStyle, backgroundColor: '#28ca42'}}></div>
          </div>
          <div style={tabsStyle}>
            {tabs.map((tab) => (
              <button
                key={tab.id}
                style={getTabStyle(tab)}
                onClick={() => setActiveTab(tab.id)}
              >
                <span style={{ fontSize: '0.8rem' }}>
                  {tab.status === 'checking' && '🔄'}
                  {tab.status === 'online' && '🟢'}
                  {tab.status === 'offline' && '🔴'}
                </span>
                <span style={{ fontWeight: '600', fontSize: '0.9rem' }}>{tab.name}</span>
              </button>
            ))}
          </div>
        </div>
        <div style={contentStyle}>
          {tabs.map((tab) => (
            <div
              key={tab.id}
              style={{ 
                display: activeTab === tab.id ? 'block' : 'none',
                height: '100%',
                width: '100%'
              }}
            >
              {tab.status === 'online' ? (
                <iframe
                  src={tab.url}
                  style={iframeStyle}
                  title={`${tab.name} - ${tab.url}`}
                  sandbox="allow-scripts allow-forms allow-popups allow-top-navigation"
                />
              ) : (
                <div style={offlineStyle}>
                  <div style={{ fontSize: '4rem', marginBottom: '1rem', opacity: 0.6 }}>🔌</div>
                  <h3 style={{ color: 'var(--ifm-font-color-base)', marginBottom: '1rem' }}>Service Unavailable</h3>
                  <p style={{ color: 'var(--ifm-font-color-secondary)', marginBottom: '1rem' }}>
                    <strong>{tab.url}</strong> is not accessible
                  </p>
                  <p>
                    Status: <span style={{ 
                      background: 'var(--ifm-color-emphasis-300)', 
                      padding: '0.25rem 0.75rem',
                      borderRadius: '12px',
                      fontWeight: '600',
                      textTransform: 'uppercase',
                      fontSize: '0.8rem'
                    }}>{tab.status}</span>
                  </p>
                </div>
              )}
            </div>
          ))}
        </div>
      </div>
    );
  }}
</BrowserOnly>

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

