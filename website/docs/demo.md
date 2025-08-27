---
sidebar_position: 80
---

# devops-sandbox demo

- [ ] this is description of what i want to see on the demo page
  * the page itself i want to be wide
  * i also want the page to be two columns

- [ ] add tags for essential apps to be able to see em by localhost link

- [ ] add on page a web-browser like styled set of iframe pages with tabs
  - http://localhost:8080
  - https://argocd.home.lab
  - https://grafana.home.lab
  - https://kibana.home.lab
  - https://vault.home.lab
  (and i want them to check if page is accessible every 10 sec and turn green when it does)

# SCENARIO

- user runs remote `bootstrap.sh`
- fetch current repo
- local DNS and CA configured
- local kubernetes is up
- script installs argocd
- argocd sync all other apps
- user easily deploy new app
