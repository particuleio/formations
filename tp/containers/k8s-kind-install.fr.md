# Travaux Pratiques: Kubernetes - KIND

## Introduction

Dans ce TP, nous allons déployer un cluster avec KIND (Kubernetes in Docker).
Une installation pour Linux ainsi qu'une installation est disponible.

## Installation Linux

Docker doit être installé : <https://docs.docker.com/engine/install/ubuntu/>

```console
$ curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.9.0/kind-linux-amd64
$ chmod +x ./kind
$ sudo mv ./kind /usr/local/bin
$ kind --version
kind version 0.9.0
```

## Installation Windows

Docker for Windows doit être installé : <https://docs.docker.com/docker-for-windows/install/>

```powershell
$ curl.exe -Lo kind-windows-amd64.exe https://kind.sigs.k8s.io/dl/v0.9.0/kind-windows-amd64
$ Move-Item .\kind-windows-amd64.exe c:\Users\your_user\AppData\Local\Microsoft\WindowsApps\kind.exe
$ kind --version
kind version 0.9.0
```

## Boot de l'environment

Clonez le répository de formations :

```console
$ git clone https://github.com/particuleio/formations.git
$ cd formations/tp/containers/kind
```

```console
$ kind create cluster --config mutli-node-1-controler-1-worker.yaml

[...]

$ kubectl get node
NAME            STATUS   ROLES    AGE   VERSION
control-plane   Ready    master   82s   v1.19.1
worker          Ready    <none>   48s   v1.19.1
```
