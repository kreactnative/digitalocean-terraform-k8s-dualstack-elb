#!/bin/bash
export KUBECONFIG=$HOME/.kube/talos-digitalocean-cilium-config
kubectl config current-context
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.12/config/manifests/metallb-native.yaml
sleep 20
kubectl apply -f metallb.yaml
sleep 20
istioctl install -f k8s/istio-operator.yaml -y