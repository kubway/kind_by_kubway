# Customized Kubernetes kind cluster installation  by Kubway 
This repository is for installing a kind cluster on a fresh installed Ubuntu Linux system. In this demo installation, cluster will be constituted of one master node and one worker node.
> Ce dépot a pour but d'installer un cluster kind sur un serveur Linux Ubuntu fraichement installé. Dans cette version de démonstration, le cluster sera composé d'un noeud master et d'un noeud worker.


## Some theory about components
> Un peu de théorie à propos des composants

Kind is used to simulate a kubernetes cluster with nodes as docker containers instead of physical or virtual servers. It is a good alternative to K3S or Minikube when you want to learm Kubernetes components (etcd, kube-api-server, scheduler, controller) because they are installed with kubeadm.

> Kind simule un cluster Kubernetes en utilisant des conteneurs docker au lieu de serveurs physiques ou virtuels. C'est une bonne alternative à K3S ou à Minikube quand on veut apprendre les composants internes de Kubernetes (etcd, kube-api-server, scheduler, controller) car ils sont installés avec kubeadm.

Cilium is a good alternative CNI (Container Network Interface) to Flannel, Calico or Weave.
> Cilium est une excellente alternative de CNI (Container Network Interface) à Flannel, Calico or Weave.

## Installing  kind and a demo cluster
### Prerequisites
- An Ubuntu Linux server (tested with Ubuntu 22.04)
- use a user with sudo access
- git

### Get repository
```bash
# Get repository
git clone https://github.com/kubway/kind_by_kubway.git
cd kind_by_kubway
```
### Customizing variables
Modify variables.env for convenience.

### kind and demo cluster installation

```bash
sudo -s source main.sh
```

## Checking installation
### Checking kind installation
```bash
helm version
docker version
kubectl version
kind version
```
Note: If you want to use docker with your current user , you must add it in the linux docker group
### Checking demo cluster installation
```bash
kind get clusters
kubectl get nodes
docker ps
kubectl get pods -n kube-system 
```
Note: If you want to use kubectl with your current user , you must update $HOME/.kube/config with values in /root/.kube/config

### Creating a pod in the demo Cluster
```bash
kubectl run monpod --image nginx
kubectl get pod
```
### Destroying the pod in the demo Cluster
```bash
kubectl delete pod monpod
```

### Destroying demo cluster
```bash
sudo -s kind delete clusters $CLUSTER_NAME
```

