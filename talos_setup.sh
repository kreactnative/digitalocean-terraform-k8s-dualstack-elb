#!/bin/bash
talosctl gen config talos-ha-cilium https://167.172.5.115:443  --config-patch @cni.yaml
sleep 3

talosctl apply-config --insecure --nodes 167.71.194.29 --file controlplane.yaml
echo "Applied controller config to 167.71.194.29"
talosctl apply-config --insecure --nodes 143.198.207.27 --file controlplane.yaml
echo "Applied controller config to 143.198.207.27"
talosctl apply-config --insecure --nodes 159.223.82.56 --file controlplane.yaml
echo "Applied controller config to 159.223.82.56"

talosctl apply-config --insecure --nodes 68.183.191.251 --file worker.yaml
echo "Applied worker config to 68.183.191.251"
talosctl apply-config --insecure --nodes 167.99.75.181 --file worker.yaml
echo "Applied worker config to 167.99.75.181"
talosctl apply-config --insecure --nodes 68.183.232.34 --file worker.yaml
echo "Applied worker config to 68.183.232.34"


# Bootstrap
sleep 30
talosctl bootstrap --nodes 167.71.194.29 -e 167.71.194.29 --talosconfig=./talosconfig
echo "Started bootstrap process"
sleep 60

# Update kubeconfig
talosctl kubeconfig $HOME/.kube/talos-digitalocean-cilium-config --nodes 167.71.194.29 -e 167.71.194.29 --talosconfig=./talosconfig --force
echo "Updated kubeconfig"
export KUBECONFIG=$HOME/.kube/talos-digitalocean-cilium-config
echo "switch context to new kubeconfig"
kubectl config current-context
echo "install cilium"
./cilium.sh

# Health check
n=0
retries=5
until [ "$n" -ge "$retries" ]; do
  if talosctl --talosconfig=./talosconfig --nodes 167.71.194.29 -e 167.71.194.29 health; then
    break
  else
    n=$((n+1))
    sleep 5
  fi
done
echo "Successfully created cluster"