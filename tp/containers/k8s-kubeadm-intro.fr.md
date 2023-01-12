# Travaux Pratiques: Kubernetes - Kubeadm

## Introduction

Dans ce TP, nous allons déployer un cluster avec kubeadm de deux noeuds : 1 master et un 1 worker.

## Prérequis

Nous allons déployer deux VM avec Vagrant, pour cela nous avons également besoin d'un hyperviseur comme Virtualbox :

- [Virtualbox v6.0](https://www.virtualbox.org/wiki/Downloads)
- [Vagrant](https://www.vagrantup.com/downloads.html)

## Boot de l'environment

Clonez le répository de formations :

```console
$ git clone https://github.com/particuleio/formations.git
```

Dans le répertoire `tp/containers/vagrant/kubeadm`:

```console
$ vagrant up
Bringing machine 'master' up with 'virtualbox' provider...
Bringing machine 'worker' up with 'virtualbox' provider...
```

Vagrant demandera quelle interface réseau utiliser, choisissez l'interface réseau utilisée pour se connecter à Internet.

Il est ensuite possible de se connecter en SSH sur chaque machine avec les commandes suivantes :

```console
$ vagrant ssh master
```

```console
$ vagrant ssh worker
```

## Préparation des nodes

Toutes ces actions sont à réaliser **sur les deux VM**.

- Les opérations commençant par **#** sont à réaliser en tant qu'utilisateur root.
- Les opérations commençant par **$** sont à réaliser en tant qu'utilisateur **non** root.

### Désactivation de la swap

Le Kubelet ne supporte pas la swap et il est donc nécessaire de la désactiver.

```console
# swapoff -a
# sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
```

Rédémarrez ensuite les deux VM.

### Installation d'une container runtime

Nous allons utiliser `containerd` en tant que container runtime. Pour préparer les machines, lancez les commandes suivantes :

```console
# cat > /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF

# modprobe overlay
# modprobe br_netfilter

# cat > /etc/sysctl.d/99-kubernetes-cri.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# sysctl --system
```

Installation de `containerd` :

```console
### Install containerd
### Set up the repository
### Install packages to allow apt to use a repository over HTTPS

# apt update && apt install -y apt-transport-https ca-certificates curl software-properties-common

### Add Docker’s official GPG key
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

### Add Docker apt repository.
# add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

### Install containerd
# apt update && apt install -y containerd.io

### Configure containerd
# mkdir -p /etc/containerd
# containerd config default > /etc/containerd/config.toml

### Restart containerd
# systemctl restart containerd
```

### Installation de kubeadm et kubelet

Ajoutez les dépots de code Kubernetes :

```console
# apt update && apt install -y apt-transport-https curl
# curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
# cat <<EOF | tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
# apt update
# apt install -y kubelet kubeadm kubectl
# apt-mark hold kubelet kubeadm kubectl
```

Sur les machines, 2 interfaces réseaux sont présents :

- enp0s3: nécessaire à Vagrant
- enp0s8: le réseau privé que nous allons utiliser pour kubeadm

Les noms des interfaces peuvent être différents chez vous. Mais l'ordre ne
devrait pas changer la première est réservée à Vagrant et la seconde est celle
du réseau privé que vous devez utiliser. Pensez à remplacer "enp0s8" dans le
reste du TP si votre interface est nommée différemment.

Créez et éditez le ficher `/etc/default/kubelet`, pour chaque nœud remplacez avec la bonne adresse IP :

```console
KUBELET_EXTRA_ARGS="--node-ip=IP_ENP0S8"
```

Démarrez le kubelet :

```console
# systemctl daemon-reload
# systemctl restart kubelet
```

## Déploiement de master


Sur le nœud master, en root, lancez la commande suivante :

```console
# kubeadm init --pod-network-cidr=192.168.0.0/16 --apiserver-advertise-address=IP_ENP0S8
```

L'opération prend quelques minutes suivant la qualité de la connexion.

Nous allons repasser en utilisateur non root pour la suite. Pour configurer `kubectl` sur le master :

```console
$ mkdir -p $HOME/.kube
$ sudo -E cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
$ sudo -E chown $(id -u):$(id -g) $HOME/.kube/config
```

Testez l'accès au cluster :

```console
$ kubectl get nodes
NAME     STATUS   ROLES    AGE   VERSION
master   NotReady    master   12m   v1.17.2
```

Pour terminer et rendre définitivement le node `Ready`, il faut rajouter un
plugin réseau. Nous allons utiliser [calico](https://www.projectcalico.org/) :

```console
$ kubectl apply -f https://docs.projectcalico.org/v3.11/manifests/calico.yaml
```

Nous sommes maintenant prêt à rajouter le worker node.

## Déploiement du worker node

Pour rajouter un worker node, il suffit d'utiliser la commande `join` (sur le worker node), affichée précédemment à la fin de commande `kubeadm init`.

```console
# kubeadm join 10.42.42.42:6443 --token xxxxxxxxxxxxxxxx \
    --discovery-token-ca-cert-hash sha256:xxxxxxxxxxxxxxxxxxxxxxx
```

Vous pouvez obtenir cette commande `join` plus tard avec la commande `kubeadm
token create --print-join-command` depuis le node Master.

Sur le Master, surveillez la liste des nodes :

```console
$ kubectl get nodes -w
```

## Conclusion

Vous avez à votre disposition un cluster de deux nœuds déployés avec kubeadm.
