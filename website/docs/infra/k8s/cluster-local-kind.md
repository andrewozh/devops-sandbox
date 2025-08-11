# Local Kind single-cluster setup

## Cluster

```bash
cat <<EOF > kind-homelab.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: homelab
nodes:
  - role: control-plane
    kubeadmConfigPatches:
      - |
        kind: InitConfiguration
        nodeRegistration:
          kubeletExtraArgs:
            node-labels: "ingress-ready=true"
    extraPortMappings:
      - containerPort: 80
        hostPort: 80
        # listenAddress: 127.0.0.1
        protocol: TCP
      - containerPort: 443
        hostPort: 443
        # listenAddress: 127.0.0.1
        protocol: TCP
  - role: worker
EOF
```

## NGINX Ingress + local DNS

- configure `kubeadmConfigPatches` by example above

- configure nginx ingress controller

```bash
ingress-nginx:
  controller:
    image:
      runAsNonRoot: true
      readOnlyRootFilesystem: false
      allowPrivilegeEscalation: false
      seccompProfile:
        type: RuntimeDefault
    extraArgs:
      publish-status-address: localhost
    service:
      type: NodePort
    hostPort:
      enabled: true
    publishService:
      enabled: false
    updateStrategy:
      type: RollingUpdate
      rollingUpdate:
        maxUnavailable: 1
    terminationGracePeriodSeconds: 0
    nodeSelector:
      ingress-ready: "true"
    tolerations:
      - effect: NoSchedule
        key: node-role.kubernetes.io/master
        operator: Equal
      - effect: NoSchedule
        key: node-role.kubernetes.io/control-plane
        operator: Equal
    allowSnippetAnnotations: false
    watchIngressWithoutClass: true
    metrics:
      enabled: true
      serviceMonitor:
        enabled: true
```

- for each ingress host add appropriate record to `/etc/hosts` file

```bash
cat /etc/hosts
##
# Host Database
#
# localhost is used to configure the loopback interface
# when the system is booting.  Do not change this entry.
##
127.0.0.1       localhost
255.255.255.255 broadcasthost
::1             localhost

127.0.0.1       home.lab
127.0.0.1       argocd.home.lab
127.0.0.1       vault.home.lab
127.0.0.1       grafana.home.lab
127.0.0.1       prometheus.home.lab
127.0.0.1       kibana.home.lab
```

## LoadBalancer

- cloud-provider-kind

```
go install sigs.k8s.io/cloud-provider-kind@latest
kubectl label node homelab-control-plane node.kubernetes.io/exclude-from-external-load-balancers-
```
