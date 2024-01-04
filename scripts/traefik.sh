#!/bin/bash
cd /tmp/ || exit
kubectl apply -f metric-server.yaml
helm repo add metallb https://metallb.github.io/metallb
helm repo update
kubectl create namespace metallb-system
helm upgrade --install metallb metallb/metallb -n  metallb-system
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
helm repo add traefik https://traefik.github.io/charts
helm upgrade --install -f traefik-values.yaml traefik traefik/traefik -n traefik --create-namespace --version v24.0.0
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm upgrade --install kube-prometheus-stack  --create-namespace  --namespace kube-prometheus-stack  prometheus-community/kube-prometheus-stack -f prometheus-stack-values.yaml
helm repo add grafana https://grafana.github.io/helm-charts
helm upgrade --install loki grafana/loki-stack --namespace loki --create-namespace --set grafana.enabled=false
helm repo add jetstack https://charts.jetstack.io
helm upgrade --install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --set installCRDs=true
cd /tmp/ || exit
kubectl apply -f ssl.yaml
kubectl apply -f metal-ip.yaml
kubectl apply -f traefik.yaml