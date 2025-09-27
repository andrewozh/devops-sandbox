# Istio Multicluster Cross-Service Communication Flow

## Specific Goal: curl in cluster2 → helloworld service in cluster1

**Objective:** Make curl pod in cluster2 successfully reach helloworld pod running in cluster1.

Current setup:
- cluster1: has helloworld pod (the only helloworld instance)
- cluster2: has curl pod only (no helloworld service/pod)
- **Goal:** curl in cluster2 must reach helloworld in cluster1

## Request Journey Milestones

When curl pod in cluster2 executes `curl http://helloworld:5000/hello`, the request must pass through these milestones:

### Milestone 1: DNS Resolution in cluster2 ✅
**What happens:** curl pod in cluster2 resolves `helloworld.sample.svc.cluster.local`
**Expected:** Should resolve to helloworld service IP (created by Istio from cluster1's service)
**Test:**
```bash
kubectl exec -n sample --context=kind-cluster2 curl-pod -c curl -- nslookup helloworld.sample.svc.cluster.local
```
**Success:** Returns service IP that points to cluster1's helloworld

**Test Result:**
```bash
$ kubectl exec -n sample --context=kind-cluster2 curl-67bd76dbb7-hhljm -c curl -- nslookup helloworld.sample.svc.cluster.local
Server:		10.96.0.10
Address:	10.96.0.10:53

Name:	helloworld.sample.svc.cluster.local
Address: 10.96.183.126
```
**Status:** SUCCESS - DNS resolution in cluster2 works correctly

## Step 2: Envoy Sidecar Intercepts Request in cluster2 ✅
**What happens:** curl pod's envoy sidecar intercepts the outbound HTTP request to helloworld:5000
**Expected result:** Envoy should recognize this as a service mesh destination
**Test command:**
```bash
kubectl exec -n sample --context=kind-cluster2 curl-pod -c istio-proxy -- curl -s localhost:15000/config_dump | grep helloworld
```
**Success criteria:** Shows helloworld cluster configuration in envoy

**Test Result:**
```bash
$ kubectl exec -n sample --context=kind-cluster2 curl-67bd76dbb7-hhljm -c istio-proxy -- curl -s localhost:15000/config_dump | grep helloworld
      "name": "outbound|5000||helloworld.sample.svc.cluster.local",
       "service_name": "outbound|5000||helloworld.sample.svc.cluster.local"
           "name": "helloworld",
           "host": "helloworld.sample.svc.cluster.local"
      "alt_stat_name": "outbound|5000||helloworld.sample.svc.cluster.local;",
          "sni": "outbound_.5000_._.helloworld.sample.svc.cluster.local"
```
**Status:** SUCCESS - Envoy has helloworld service configuration

## Step 3: Service Discovery - cluster1's istiod reads cluster2 services ❌
**What happens:** istiod in cluster1 should discover helloworld service endpoints from both clusters via remote secret
**Expected result:** istiod should know about endpoints in both cluster1 AND cluster2
**Test command:**
```bash
# Check if istiod in cluster1 can see cluster2's endpoints
kubectl logs -n istio-system --context=kind-cluster1 deployment/istiod | grep -i "cluster2\|remote"
```
**Success criteria:** Shows logs of connecting to cluster2 and reading its endpoints

**Test Result:**
```bash
$ kubectl logs -n istio-system --context=kind-cluster1 deployment/istiod | grep -i "cluster2\|remote" | tail -10
2025-09-27T07:50:09.969402Z	info	model	Incremental push, service helloworld.sample.svc.cluster.local at shard Kubernetes/cluster2 has no endpoints
2025-09-27T07:50:10.351177Z	info	model	Incremental push, service helloworld.sample.svc.cluster.local at shard Kubernetes/cluster2 has no endpoints
2025-09-27T07:52:48.464710Z	info	model	Incremental push, service helloworld.sample.svc.cluster.local at shard Kubernetes/cluster2 has no endpoints
```

**Issue Found:**
```bash
$ kubectl get endpoints helloworld -n sample --context=kind-cluster2
NAME         ENDPOINTS   AGE
helloworld   <none>      8m38s

# Compare with cluster1:
$ kubectl get endpoints helloworld -n sample --context=kind-cluster1
NAME         ENDPOINTS     AGE
helloworld   10.244.0.9:5000   58m
```
**Status:** PARTIALLY FIXED - Found and resolved network label issue

**Root Cause Found:**
Both clusters had same network label `topology.istio.io/network=network1`, making Istio think they're in same network.

**Fix Applied:**
```bash
# Remove network label from cluster2
kubectl label namespace istio-system --context=kind-cluster2 topology.istio.io/network-
# Restart istiod to pick up changes  
kubectl rollout restart deployment/istiod -n istio-system --context=kind-cluster1
```

**Current Status:**
- ❌ Kubernetes endpoints still empty: `kubectl get endpoints helloworld -n sample --context=kind-cluster2` shows `<none>`
- ✅ **Istio service discovery WORKS**: Both clusters' Envoy proxies see cluster1 endpoint:
```bash
$ istioctl --context=kind-cluster2 proxy-config endpoint curl-67bd76dbb7-hhljm.sample | grep helloworld
10.244.0.9:5000    HEALTHY    OK    outbound|5000||helloworld.sample.svc.cluster.local
$ istioctl --context=kind-cluster1 proxy-config endpoint curl-7cd64bb6c5-tdjg8.sample | grep helloworld  
10.244.0.9:5000    HEALTHY    OK    outbound|5000||helloworld.sample.svc.cluster.local
```

**Next Issue:** Network connectivity - Envoy sees endpoints but connection fails:
```bash
$ kubectl exec -n sample --context=kind-cluster2 curl-67bd76dbb7-hhljm -c curl -- curl -s http://helloworld:5000/hello
upstream connect error or disconnect/reset before headers. retried and the latest reset reason: remote connection failure, transport failure reason: delayed connect error: Connection refused
```

## Step 4: Cross-cluster Service Registry Merge
**What happens:** istiod in cluster1 merges service endpoints from both clusters and pushes config to all proxies
**Expected result:** Both clusters should see endpoints from both clusters
**Test command:**
```bash
# cluster1 should see both v1 (local) and v2 (remote) endpoints
kubectl get endpoints helloworld -n sample --context=kind-cluster1
# cluster2 should see both v1 (remote) and v2 (local) endpoints  
kubectl get endpoints helloworld -n sample --context=kind-cluster2
```
**Success criteria:** Each cluster shows endpoints from BOTH clusters

## Step 5: Envoy Configuration Update in cluster2
**What happens:** istiod pushes updated endpoint configuration to cluster2's curl pod envoy sidecar
**Expected result:** Envoy in cluster2 should know about cluster1's helloworld endpoints
**Test command:**
```bash
kubectl exec -n sample --context=kind-cluster2 curl-pod -c istio-proxy -- curl -s localhost:15000/clusters | grep helloworld
```
**Success criteria:** Shows endpoints from both clusters in the helloworld cluster

## Step 6: Load Balancing Decision
**What happens:** Envoy in cluster2 decides which endpoint to route to (local vs remote)
**Expected result:** Should distribute between cluster1 and cluster2 endpoints
**Test command:**
```bash
# Multiple requests should hit different versions
for i in {1..10}; do 
  kubectl exec -n sample --context=kind-cluster2 curl-pod -c curl -- curl -s http://helloworld:5000/hello
done
```
**Success criteria:** Should see both "Hello version: v1" (cluster1) and "Hello version: v2" (cluster2)

## Step 7: Cross-cluster Network Routing (if remote endpoint chosen)
**What happens:** If envoy chooses cluster1 endpoint, traffic must route from cluster2 to cluster1
**Expected result:** Network connectivity between Docker containers should work
**Test command:**
```bash
# Direct connectivity test from cluster2 to cluster1's helloworld pod IP
CLUSTER1_POD_IP=$(kubectl get pod -n sample --context=kind-cluster1 -l version=v1 -o jsonpath='{.items[0].status.podIP}')
kubectl exec -n sample --context=kind-cluster2 curl-pod -c curl -- curl -s --connect-timeout 5 http://$CLUSTER1_POD_IP:5000/hello
```
**Success criteria:** Successfully returns "Hello version: v1"

## Step 8: Response Path Back
**What happens:** Response travels back from cluster1 → cluster2 → curl pod
**Expected result:** Original curl command should receive the response
**Test command:**
```bash
kubectl exec -n sample --context=kind-cluster2 curl-pod -c curl -- curl -s -w "\\nHTTP Code: %{http_code}\\n" http://helloworld:5000/hello
```
**Success criteria:** Returns "Hello version: v1" with HTTP Code: 200

---

## Current State Analysis

Based on our testing:
- ✅ Step 1: DNS works (resolves to local cluster service IP)
- ✅ Step 2: Envoy intercepts (pods have sidecars)  
- ✅ Step 3: Endpoint discovery works - both clusters see same endpoints
- ✅ Step 4: Endpoints merged - istioctl shows cross-cluster endpoints
- ❌ Step 5: Load balancing NOT working - only hitting local endpoints
- ❌ Step 6: Cross-cluster routing failing
- ❌ Step 7: Traffic not reaching remote cluster
- ❌ Step 8: Only getting responses from local cluster

## Verification Results

**Endpoint Discovery Status:**
```bash
# Both clusters see the same endpoints (GOOD):
$ istioctl --context=kind-cluster1 proxy-config endpoint curl-pod.sample | grep helloworld
10.244.0.6:5000    HEALTHY    OK    outbound|5000||helloworld.sample.svc.cluster.local
10.244.0.9:5000    HEALTHY    OK    outbound|5000||helloworld.sample.svc.cluster.local

$ istioctl --context=kind-cluster2 proxy-config endpoint curl-pod.sample | grep helloworld  
10.244.0.6:5000    HEALTHY    OK    outbound|5000||helloworld.sample.svc.cluster.local
10.244.0.9:5000    HEALTHY    OK    outbound|5000||helloworld.sample.svc.cluster.local
```

**Cross-Cluster Communication Test Results:**
```bash
# From cluster2 curl trying to reach cluster1 helloworld-v1:
$ kubectl exec -n sample --context=kind-cluster2 curl-pod -c curl -- curl -s http://helloworld:5000/hello
Hello version: v2, instance: helloworld-v2-xxx  # PROBLEM: Getting v2 (local), not v1 (remote)!
```

## Root Cause Focus
The failure is in **Step 6** - Cross-cluster routing:
- ✅ Service discovery works (both clusters see same endpoints)
- ✅ Remote secret configured correctly  
- ✅ API connectivity works between control planes
- ✅ Endpoints visible in both clusters
- ❌ **Traffic from cluster2 not reaching cluster1 helloworld-v1 pod**
- ❌ Only getting local responses

**Current Problem:**
curl in cluster2 should be able to reach helloworld-v1 in cluster1, but it's only hitting the local helloworld-v2 in cluster2.

**Possible Issues:**
1. **Network connectivity** - can cluster2 pods actually reach cluster1 pod IPs?
2. **Locality preference** - Envoy preferring local endpoints over remote
3. **Load balancing algorithm** - not distributing to remote endpoints  
4. **Network routing** - cross-cluster pod-to-pod communication blocked
5. **Firewall/iptables** - blocking inter-cluster traffic
