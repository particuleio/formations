# Travaux Pratiques: Kubernetes - KIND

## Introduction

Dans ce TP, nous allons déployer un cluster avec [KIND](https://kind.sigs.k8s.io/) (Kubernetes in Docker).
Une installation pour Linux ainsi qu'une installation est disponible.

## Prérequis
- Docker doit être installé : <https://docs.docker.com/engine/install/ubuntu/>

## Kubectl
```bash
$ curl -Lo /usr/local/bin/kubectl https://dl.k8s.io/release/v1.26.0/bin/linux/amd64/kubectl
$ chmod +x /usr/local/bin/kubectl
$ # verify the installation
$ kubectl version --client --short
Client Version: v1.26.0
Kustomize Version: v4.5.7
$ # add auto completion
$ echo 'source <(kubectl completion bash)' >>~/.bashrc
$ # alias kubectl
$ echo '
alias k=kubectl
complete -o default -F __start_kubectl k
' >> ~/.bashrc && source ~/.bashrc

```


## Installation

[Quick Start - kind](https://kind.sigs.k8s.io/docs/user/quick-start/)

```bash
$ curl -Lo /usr/local/bin/kind https://kind.sigs.k8s.io/dl/v0.17.0/kind-linux-amd64
$ chmod +x /usr/local/bin/kind
$ kind --version
kind version 0.17.0
$ # add auto completion
$ echo 'source <(kind completion bash)' >> ~/.bashrc && source ~/.bashrc
```

## Creation de cluster
### Méthode impérative
Création d'un simple cluster appelé `kind-test`
```bash
$ kind create cluster --name=test
Creating cluster "test" ...
 ✓ Ensuring node image (kindest/node:v1.25.3) 🖼 
 ✓ Preparing nodes 📦  
 ✓ Writing configuration 📜 
 ✓ Starting control-plane 🕹️ 
 ✓ Installing CNI 🔌 
 ✓ Installing StorageClass 💾 
Set kubectl context to "kind-test"
You can now use your cluster with:

kubectl cluster-info --context kind-test

Not sure what to do next? 😅  Check out https://kind.sigs.k8s.io/docs/user/quick-start/
```


Vérification de d'accès au cluster
```bash
$ kubectl get nodes
NAME                 STATUS   ROLES           AGE   VERSION
test-control-plane   Ready    control-plane   51s   v1.25.3
```

Suppression de cluster
``` bash
kind delete cluster --name=test
```

### Méthode déclarative
```bash
$ # create config file
$ echo '
# three node (two workers) cluster config
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
' > kind_cluster_1.yaml
$ # create cluster
$ kind create cluster --name=demo --config=kind_cluster_1.yaml
Creating cluster "demo" ...
 ✓ Ensuring node image (kindest/node:v1.25.3) 🖼
 ✓ Preparing nodes 📦 📦 📦  
 ✓ Writing configuration 📜 
 ✓ Starting control-plane 🕹️ 
 ✓ Installing CNI 🔌 
 ✓ Installing StorageClass 💾 
 ✓ Joining worker nodes 🚜 
Set kubectl context to "kind-demo"
You can now use your cluster with:

kubectl cluster-info --context kind-demo

Thanks for using kind! 😊
$ # Verify access to cluster
$ kubectl get nodes
NAME                 STATUS   ROLES           AGE   VERSION
demo-control-plane   Ready    control-plane   55s   v1.25.3
demo-worker          Ready    <none>          35s   v1.25.3
demo-worker2         Ready    <none>          35s   v1.25.3
```


## Control plane componentes
Kubernetes organise les objects avec les namespaces.
Amusez-vous en regardant ce qu'il y a dans chaque namespace !
``` bash
$ # get namespaces
$ kubectl get namespaces
NAME                 STATUS   AGE
default              Active   44s
kube-node-lease      Active   46s
kube-public          Active   46s
kube-system          Active   46s
local-path-storage   Active   41s
$ # get all objects inside namespace
$ kubectl -n <NAMESPACE> get all 
...
```

## Kubeconfig
- Les information d'accès aux clusters kuebrnetes sont stockés dans un fichier appelé kubeconfig.

- Le chemin par défaut de ce fichier est `$HOME/.kube/config`.

``` bash
$ # show current kubeconfig
$ kubectl config view
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://127.0.0.1:40525
  name: kind-demo
contexts:
- context:
    cluster: kind-demo
    user: kind-demo
  name: kind-demo
current-context: kind-demo
kind: Config
preferences: {}
users:
- name: kind-demo
  user:
    client-certificate-data: DATA+OMITTED
    client-key-data: DATA+OMITTED
```


## Conclusion
Dans ce TP nous avons vu comment mettre en place un cluster kubernetes en local avec `kind`.
