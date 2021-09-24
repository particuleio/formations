# Travaux Pratiques: Kubernetes - KIND

## Introduction

Dans ce TP, nous allons déployer un cluster avec [KIND](https://kind.sigs.k8s.io/) (Kubernetes in Docker).
Une installation pour Linux ainsi qu'une installation pour Windows sont disponibles.

## Installation Linux

Docker doit être installé : <https://docs.docker.com/engine/install/ubuntu/>

```console
$ curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.11.0/kind-linux-amd64
$ chmod +x ./kind
$ sudo mv ./kind /usr/local/bin
$ kind --version
kind version 0.11.0
```

## Installation Windows

Docker for Windows doit être installé : <https://docs.docker.com/docker-for-windows/install/>

```powershell
$ curl.exe -Lo kind-windows-amd64.exe https://kind.sigs.k8s.io/dl/v0.11.0/kind-windows-amd64
$ Move-Item .\kind-windows-amd64.exe c:\Users\your_user\AppData\Local\Microsoft\WindowsApps\kind.exe
$ kind --version
kind version 0.11.0
```

## Boot de l'environment

Enregistrez le fichier suivant sous le nom
`multi-node-1-controler-1-worker.yaml` :

```yaml
# two nodes cluster config
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
```

Installez la ligne de commande `kubectl` :
<https://kubernetes.io/fr/docs/tasks/tools/install-kubectl/>

```console
$ kind create cluster --config multi-node-1-controler-1-worker.yaml

[...]

$ kubectl get node
NAME            STATUS   ROLES    AGE   VERSION
control-plane   Ready    master   82s   v1.19.1
worker          Ready    <none>   48s   v1.19.1
```
