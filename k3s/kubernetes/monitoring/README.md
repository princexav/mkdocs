# Kubernetes Monitoring — Prometheus + Grafana

## Quick Start

```bash
# 1. Install Helm (if not installed)
# Mac:     brew install helm
# Linux:   curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
# Windows: scoop install helm  OR  choco install kubernetes-helm

# 2. Add Helm repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# 3. Install with custom values
helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace \
  -f kubernetes/monitoring/values.yml

# 4. Verify all pods are running
kubectl get pods -n monitoring

# 5. Access Grafana
kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80
# Open: http://localhost:3000  (admin / healthpulse123)
```

## Uninstall

```bash
helm uninstall monitoring -n monitoring
kubectl delete namespace monitoring
```

## See Also

- Full guide: `guides/TASK-K-GUIDE.md`
