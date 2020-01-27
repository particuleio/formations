# Travaux Pratiques: Kubernetes - Kubeadm - Networking

## Introduction

Les services permettent aux applications déployées sur Kubernetes de communiquer
ensemble, c'est l'une des briques les plus importantes de la partie réseau.
Nous allons voir les différents types de services et les notions associées:

- *ClusterIP*
- *NodePort*
- *ExternalIP*
- *LoadBalancer*

## Prérequis

- Cluster Kubernetes `kubeadm` du tp precedent.

## ClusterIP

Chaque cluster Kubernetes dispose d'un réseau interne pour les services. Le type de service par defaut est *ClusterIP*, ces IP sont joignable uniquement à l'intérieur du cluster.

Avoir une seule IP permet de load balancer le trafic automatiquement entre de multiples pods (replicas).

Créez le fichier `clusterip.yaml` et appliquez le sur le cluster:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: webapp1-clusterip-svc
  labels:
    app: webapp1-clusterip
spec:
  ports:
  - port: 80
  selector:
    app: webapp1-clusterip
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp1-clusterip-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: webapp1-clusterip
  template:
    metadata:
      labels:
        app: webapp1-clusterip
    spec:
      containers:
      - name: webapp1-clusterip-pod
        image: katacoda/docker-http-server:latest
        ports:
        - containerPort: 80
```

Ce fichier déploie une application web ainsi que 2 replicas.

Regardez l'IP de service:

```bash
kubectl get svc
```

Remarquez que, par défaut, le port du service est la même que le port du
conteneur (80). Il est possible de dissocier le port du conteneur du port
du service grâce à la notion de *targetPort*.

Créez et appliquez le fichier `clusterip-target.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: webapp1-clusterip-targetport-svc
  labels:
    app: webapp1-clusterip-targetport
spec:
  ports:
  - port: 8080
    targetPort: 80
  selector:
    app: webapp1-clusterip-targetport
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp1-clusterip-targetport-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: webapp1-clusterip-targetport
  template:
    metadata:
      labels:
        app: webapp1-clusterip-targetport
    spec:
      containers:
      - name: webapp1-clusterip-targetport-pod
        image: katacoda/docker-http-server:latest
        ports:
        - containerPort: 80
```

Regardez maintenant le mapping du service avec `kubectl get svc`. Que remarquez vous ?

Les IPs de service ne sont pas joignables directement car nous sommes situés à l'extérieur du cluster. Pour y accéder, nous devons publier le service.

## NodePort

Les services de type *NodePort* permettent d'exposer un service a l'extérieur du cluster en mappant un port sur tous les noeuds d'un cluster.

Créez et appliquez le fichier `nodeport.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: webapp1-nodeport-svc
  labels:
    app: webapp1-nodeport
spec:
  type: NodePort
  ports:
  - port: 80
    nodePort: 30080
  selector:
    app: webapp1-nodeport
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp1-nodeport-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: webapp1-nodeport
  template:
    metadata:
      labels:
        app: webapp1-nodeport
    spec:
      containers:
      - name: webapp1-nodeport-pod
        image: katacoda/docker-http-server:latest
        ports:
        - containerPort: 80
```

Récupérez l'IP du nœuds et accédez au service sur le port 30080.

Ce type de service permet d'exposer un ensemble de pods sur tous les noeuds d'un cluster. Si vous souhaitez exposer le service uniquement sur une IP, il existe un autre type de service.

## ExternalIP

```yaml
Version: v1
kind: Service
metadata:
  name: webapp1-externalip-svc
  labels:
    app: webapp1-externalip
spec:
  ports:
  - port: 80
  externalIPs:
  - HOSTIP
  selector:
    app: webapp1-externalip
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp1-externalip-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: webapp1-externalip
  template:
    metadata:
      labels:
        app: webapp1-externalip
    spec:
      containers:
      - name: webapp1-externalip-pod
        image: katacoda/docker-http-server:latest
        ports:
        - containerPort: 80
```

Le service est maintenant bind sur l'IP externe du nœud du cluster.

Accédez au service via curl:

```
curl -v $EXTERNAL_IP
```

## Load Balancer

Le dernier type de service est spécifique aux fournisseurs de Cloud. Par exemple, dans le cas d'un cluster sur Amazon Web Service, il est possible de provisionner automatiquement un load balancer et de publier le trafic vers l'extérieur.

Un cluster sur une machine virtuelle ne fournit pas de Cloud ou de load balancer.
