#### disable kube-proxy
```
kubectl -n kube-system delete ds kube-proxy
kubectl -n kube-system delete cm kube-proxy
```
#### enable control-plane scheduled
```
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
```
#### install metrics server
```
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
# ** edit deployment
# - --kubelet-insecure-tls
# **
```
#### install cilium cni
```
helm repo add cilium https://helm.cilium.io/
helm repo update

helm upgrade --install \
    cilium \
    cilium/cilium \
    --namespace kube-system \
    --set ipam.mode=kubernetes \
    --set=kubeProxyReplacement=true \
    --set bpf.masquerade=true \
    --set=securityContext.capabilities.ciliumAgent="{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}" \
    --set=securityContext.capabilities.cleanCiliumState="{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}" \
    --set bgpControlPlane.enabled=true \
    --set externalIPs.enabled=true \
    --set l2announcements.enabled=true \
    --set l2podAnnouncements.enabled=true \
    --set l2podAnnouncements.interface=eth0 \
    --set hubble.enabled=true \
    --set hubble.relay.enabled=true \
    --set hubble.ui.enabled=true

helm upgrade --install \
    cilium \
    cilium/cilium \
    --namespace kube-system \
    --set ipam.mode=kubernetes \
    --set=securityContext.capabilities.ciliumAgent="{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}" \
    --set=securityContext.capabilities.cleanCiliumState="{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}" \
    --set=cgroup.autoMount.enabled=false \
    --set=cgroup.hostRoot=/sys/fs/cgroup \
    --set=k8sServiceHost=192.168.1.200 \
    --set=k8sServicePort=6443 \
    --set bpf.masquerade=true \
    --set externalIPs.enabled=true \
    --set bgpControlPlane.enabled=true \
    --set l2announcements.enabled=true \
    --set l2podAnnouncements.enabled=true \
    --set l2podAnnouncements.interface=eth0 \
    --set hubble.enabled=true \
    --set hubble.relay.enabled=true \
    --set hubble.ui.enabled=true


helm upgrade --install cilium cilium/cilium \
    --namespace kube-system --create-namespace \
    --set bpf.masquerade=true \
    --set encryption.nodeEncryption=false \
    --set k8sServiceHost=192.168.1.200 \
    --set k8sServicePort=6443  \
    --set kubeProxyReplacement=true  \
    --set operator.replicas=1  \
    --set serviceAccounts.cilium.name=cilium  \
    --set serviceAccounts.operator.name=cilium-operator  \
    --set tunnel=vxlan \
    --set hubble.enabled=true \
    --set hubble.relay.enabled=true \
    --set hubble.ui.enabled=true \
    --set prometheus.enabled=true \
    --set operator.prometheus.enabled=true \
    --set hubble.metrics.enabled="{dns,drop,tcp,flow,port-distribution,icmp,http}" \
    --set externalIPs.enabled=true \
    --set bgpControlPlane.enabled=true \
    --set l2announcements.enabled=true \
    --set l2podAnnouncements.enabled=true \
    --set l2podAnnouncements.interface=eth0 \
    --set ipam.mode=kubernetes \
    --set securityContext.capabilities.ciliumAgent="{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}" \
    --set securityContext.capabilities.cleanCiliumState="{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}" \
    --set securityContext.privileged=true

helm upgrade --install cilium cilium/cilium \
    --namespace kube-system \
    --set ipam.mode=kubernetes \
    --set bpf.masquerade=true \
    --set encryption.nodeEncryption=false \
    --set k8sServiceHost=192.168.1.200 \
    --set k8sServicePort=6443  \
    --set kubeProxyReplacement=true  \
    --set operator.replicas=1  \
    --set serviceAccounts.cilium.name=cilium  \
    --set serviceAccounts.operator.name=cilium-operator  \
    --set tunnel=vxlan \
    --set hubble.enabled=true \
    --set hubble.relay.enabled=true \
    --set hubble.ui.enabled=true \
    --set prometheus.enabled=true \
    --set operator.prometheus.enabled=true \
    --set hubble.metrics.enabled="{dns,drop,tcp,flow,port-distribution,icmp,http}" \
    --set securityContext.capabilities.ciliumAgent="{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}" \
    --set securityContext.capabilities.cleanCiliumState="{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}" \
    --set securityContext.privileged=true

```