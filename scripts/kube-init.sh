#!/bin/bash
cd /tmp/ 
sudo kubeadm init --config=cluster.yaml --upload-certs
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo cp -i /etc/kubernetes/admin.conf /tmp/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
sudo chown -R root:root /tmp/config
export KUBECONFIG=/tmp/config
sudo chmod 644 /etc/kubernetes/admin.conf
sudo echo $(kubeadm token create --print-join-command) --control-plane --certificate-key $(sudo kubeadm init phase upload-certs --upload-certs --config cluster.yaml | grep -vw -e certificate -e Namespace) >> join-master.sh
sudo kubeadm token create --print-join-command >> join-worker.sh
sudo chown -R root:root join-master.sh
sudo chown -R root:root join-worker.sh
export KUBECONFIG=/etc/kubernetes/admin.conf