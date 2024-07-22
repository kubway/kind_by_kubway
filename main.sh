#
# !/bin/bash
# kind cluster installation main program
# Version : April 26, 2024
# Author : marie.foucher@kubway.fr
#
source variables.env

# Update environment for apt
bash -c "echo 'GNUTLS_CPUID_OVERRIDE=0x1' >> /etc/environment"

# Helm install
curl -Lo ./helm.tar.gz https://get.helm.sh/helm-$HELM_VERSION-linux-amd64.tar.gz
tar xvzf helm.tar.gz
cp linux-amd64/helm /usr/local/sbin/
helm version

# Docker installation
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce=$DOCKER_VERSION docker-ce-cli=$DOCKER_VERSION containerd.io docker-buildx-plugin docker-compose-plugin

# Kind Installation 
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/$KIND_VERSION/kind-linux-amd64
# For ARM64
[ $(uname -m) = aarch64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/KIND_VERSION/kind-linux-arm64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
kind version

# kubectl Installation 
curl -LO https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/sbin/kubectl
echo 'source <(kubectl completion bash)' >>~/.bashrc
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -o default -F __start_kubectl k' >>~/.bashrc
source ~/.bashrc
kubectl version --client

# kind configuration file creation
cat << EOF > $CLUSTER_NAME.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: $CLUSTER_NAME
nodes:
- role: control-plane
  image: $CLUSTER_NODES_IMAGE
- role: worker
  image: $CLUSTER_NODES_IMAGE
networking:
  podSubnet: $CLUSTER_PODSUBNET
  serviceSubnet: $CLUSTER_SERVICESUBNET
  disableDefaultCNI: true
EOF

# Cluster creation
sudo kind create cluster --config=$CLUSTER_NAME.yaml
kubectl get nodes

# Cilium CNI Installation
docker pull quay.io/cilium/cilium:$CILIUM_VERSION
sudo helm repo add cilium https://helm.cilium.io/
curl -LO https://github.com/cilium/cilium/archive/main.tar.gz
tar xzf main.tar.gz
cd cilium-main/install/kubernetes
kind load docker-image quay.io/cilium/cilium:$CILIUM_VERSION --name $CLUSTER_NAME
helm install cilium ./cilium \
   --namespace kube-system \
   --set image.pullPolicy=IfNotPresent \
   --set ipam.mode=kubernetes

