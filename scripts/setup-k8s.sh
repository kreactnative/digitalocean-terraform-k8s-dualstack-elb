#!/bin/sh
sudo timedatectl set-timezone Asia/Bangkok
dnf makecache --refresh
dnf update --allowerasing --skip-broken --nobest  -y
#cat /etc/rocky-release
uname -r
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config


## only fedora
sudo swapoff -a
sudo dnf remove zram-generator-defaults -y
swapoff -a
sudo dnf autoremove -y

modprobe overlay
modprobe br_netfilter

cat > /etc/modules-load.d/k8s.conf << EOF
overlay
br_netfilter
EOF

cat > /etc/sysctl.d/k8s.conf << EOF
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv6.conf.all.forwarding=1
EOF

sudo sysctl -w net.ipv6.conf.all.forwarding=1
echo net.ipv6.conf.all.forwarding=1 >> /etc/sysctl.conf

sysctl --system

swapoff -a
sed -e '/swap/s/^/#/g' -i /etc/fstab
free -m

### containerd
#dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
#dnf makecache
#dnf install -y containerd.io

#mv /etc/containerd/config.toml /etc/containerd/config.toml.orig
#containerd config default > /etc/containerd/config.toml
#sed -i "s|SystemdCgroup = false|SystemdCgroup = true|g" /etc/containerd/config.toml
#systemctl enable --now containerd.service
#systemctl status containerd.service --no-pager
### cri-o
VERSION=1.28
sudo curl -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable.repo https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/CentOS_8/devel:kubic:libcontainers:stable.repo
sudo curl -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable:cri-o:${VERSION}.repo https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:${VERSION}/CentOS_8/devel:kubic:libcontainers:stable:cri-o:${VERSION}.repo
sudo dnf -y install cri-o cri-tools
sudo systemctl enable --now crio
sudo systemctl status crio --no-pager

cat > /etc/yum.repos.d/k8s.repo << EOF
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF


dnf makecache
dnf install -y {kubelet,kubeadm,kubectl} --disableexcludes=kubernetes
systemctl enable --now kubelet.service
systemctl status kubelet --no-pager
sudo dnf -y install iproute-tc
sudo dnf install yum-plugin-versionlock -y
sudo dnf versionlock kubelet kubeadm kubectl

mkdir /opt/bin
curl -fsSLo /opt/bin/flanneld https://github.com/flannel-io/flannel/releases/download/v0.20.1/flannel-v0.20.1-linux-amd64.tar.gz
chmod +x /opt/bin/flanneld

sudo dnf install nfs-utils nfs4-acl-tools -y
sudo systemctl start nfs-client.target
sudo systemctl enable nfs-client.target
sudo systemctl status nfs-client.target --no-pager

sudo /bin/sh -c 'echo $(hostname -i | xargs -n1 | grep ^10.) $(hostname) >> /etc/hosts'