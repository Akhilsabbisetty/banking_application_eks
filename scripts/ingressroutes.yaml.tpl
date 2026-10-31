# Traefik IngressRoutes for Argo CD / Grafana / Prometheus / Alertmanager.
# Apply with:  DOMAIN=ascloud.space envsubst < scripts/ingressroutes.yaml.tpl | kubectl apply -f -
# (priority 100 is required so these beat the app's  Host && PathPrefix("/")  router)
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata: { name: argocd, namespace: argocd }
spec:
  entryPoints: [websecure]
  routes:
    - match: Host(`${DOMAIN}`) && PathPrefix(`/argocd`)
      kind: Rule
      priority: 100
      services:
        - { name: argocd-server, port: 80 }
  tls: { secretName: banking-tls }
---
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata: { name: grafana, namespace: observability }
spec:
  entryPoints: [websecure]
  routes:
    - match: Host(`${DOMAIN}`) && PathPrefix(`/grafana`)
      kind: Rule
      priority: 100
      services:
        - { name: kube-prometheus-stack-grafana, port: 80 }
  tls: { secretName: banking-tls }
---
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata: { name: prometheus, namespace: observability }
spec:
  entryPoints: [websecure]
  routes:
    - match: Host(`${DOMAIN}`) && PathPrefix(`/prometheus`)
      kind: Rule
      priority: 100
      services:
        - { name: kube-prometheus-stack-prometheus, port: 9090 }
  tls: { secretName: banking-tls }
---
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata: { name: alertmanager, namespace: observability }
spec:
  entryPoints: [websecure]
  routes:
    - match: Host(`${DOMAIN}`) && PathPrefix(`/alertmanager`)
      kind: Rule
      priority: 100
      services:
        - { name: kube-prometheus-stack-alertmanager, port: 9093 }
  tls: { secretName: banking-tls }
