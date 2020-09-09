# Travaux Pratiques: Kubernetes - Kubeadm

## Introduction

Dans ce TP, nous allons déployer un cluster avec kubeadm de deux noeuds : 1 master et un 1 worker.

## Prérequis

Nous allons déployer deux VM avec Vagrant, pour cela nous avons également besoin d'un hyperviseur comme Virtualbox :

- [Virtualbox v6.0](https://www.virtualbox.org/wiki/Downloads)
- [Vagrant](https://www.vagrantup.com/downloads.html)

## Boot de l'environment

Clonez le répository de formations :

```bash
git@github.com:particuleio/formations.git
```

Dans le repertoire `tp/containers/vagrant/kubeadm`:

```bash
vagrant up
Bringing machine 'master' up with 'virtualbox' provider...
Bringing machine 'node' up with 'virtualbox' provider...
```

Vagrant demandera quelle interface réseau utiliser, choisissez l'interface réseau utilisée pour se connecter à Internet.

Il est ensuite possible de se connecter en SSH sur chaque machine avec les commandes suivantes :

```bash
vagrant ssh master
```

```bash
vagrant ssh node
```

## Préparation des nodes (à realiser sur les deux VM)

Les opérations suivantes sont à realiser en tant qu'utilisateur root.

### Installation d'une container runtime

Nous allons utiliser `containerd` en tant que container runtime. Pour préparer les machines, lancez les commandes suivantes :

```bash
cat > /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

# Setup required sysctl params, these persist across reboots.
cat > /etc/sysctl.d/99-kubernetes-cri.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sysctl --system
```

Installation de `containerd` :

```bash
# Install containerd
## Set up the repository
### Install packages to allow apt to use a repository over HTTPS
apt-get update && apt-get install -y apt-transport-https ca-certificates curl software-properties-common

### Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

### Add Docker apt repository.
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

## Install containerd
apt-get update && apt-get install -y containerd.io

# Configure containerd
mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml

# Restart containerd
systemctl restart containerd
```

### Installation de kubeadm et kubelet

Ajoutez les dépots de code Kubernetes :

```bash
sudo apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

Créez et éditez le ficher `/etc/default/kubelet`, pour chaque nœud remplacez avec la bonne adresse IP :

```bash
KUBELET_EXTRA_ARGS="--node-ip=NODE_IP_ETH1"
```

Démarrez le kubelet :

```bash
systemctl daemon-reload
systemctl restart kubelet
```

## Déploiement de master

Sur les machines, 2 interfaces réseaux sont présents :

- eth0: nécessaire à Vagrant
- eth1: le réseau privé que nous allons utiliser pour kubeadm

Sur le nœud master, en root, lancez la commande suivante :

```bash
kubeadm init --pod-network-cidr=192.168.0.0/16 --apiserver-advertise-address=IP_ETH1
```

L'opération prend quelques minutes suivant la qualité de la connexion.

Nous allons repasser en utilisateur non root pour la suite. Pour configurer `kubectl` sur le master :

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

Testez l'accès au cluster :

```bash
$ kubectl get nodes
NAME     STATUS   ROLES    AGE   VERSION
master   Ready    master   12m   v1.17.2
```

Pour terminer, il faut rajouter un plugin réseau. Nous allons utiliser [calico](https://www.projectcalico.org/) :

```bash
kubectl apply -f https://docs.projectcalico.org/v3.11/manifests/calico.yaml
```

Nous sommes maintenant prêt à rajouter le worker node.

## Déploiement du worker node

Pour rajouter un worker node, il suffit de copier/coller la commande de join affichée précédemment :

```bash
kubeadm join 10.0.2.15:6443 --token ahcn89.uxju0eocfom721bm \
    --discovery-token-ca-cert-hash sha256:6dbd5196874f122f108faaeff9cb274530a1362d4ea8fccb81f2ce5597765bb4
```

Vous pouvez obtenir cette commande `join` plus tard avec la commande `kubeadm
token create --print-join-command`.

Sur le master, surveillez la liste des nodes :

```
kubectl get nodes -w
```

## Conclusion

Vous avez à votre disposition un cluster de deux nœuds déployés avec kubeadm. Si vous avez le temps, reprenez les TPs minikube et testez les sur ce cluster.
