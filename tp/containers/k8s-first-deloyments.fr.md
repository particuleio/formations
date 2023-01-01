# Travaux Pratiques: Kubernetes - Intro déploiement

## Introduction

Déployer des Pods, des Deployments, tester la scalabilité et les Service de
base.

## Prérequis

- Cluster Kubernetes
- Kubectl
- Wget

Le cluster de type kind doit avoir une configuration simulaire:

``` yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 8080
    protocol: TCP
  - containerPort: 8443
    hostPort: 443
    protocol: TCP
```


## déploiement
### Un simple déploiement

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: color
spec:
  replicas: 3
  selector:
    matchLabels:
      app: color
  template:
    metadata:
      labels:
        app: color
    spec:
      containers:
      - name: color
        image: docker.io/particule/simplecolorapi:1.0
        ports:
        - containerPort: 5000
```

```yaml
---
apiVersion: v1
kind: Service
metadata:
  name: color
spec:
  type: ClusterIP
  ports:
  - port: 5000
    targetPort: 5000
  selector:
    app: color
```

Appliquez le Deployment et le service avec
la commande `kubectl apply -f`.

Vérifier que les trois Pod sont bien `Running` avec la commande `kubectl get pod`.

### Scale up

Changez le nombre de réplicats du Deployment :

```console
$ kubectl scale deployment/helloworld --replicas=5
```

Vérifier le nombre de pod.

Appliquez à nouveau le fichier `deployment.yaml`, que se passe t-il ?

### Modification de l'image

Déployez le Deployment et le Service ci dessous. Deux ressources peuvent être
enregistrées dans le même fichier tant qu'elles sont séparées par `---`.

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: color
spec:
  replicas: 5
  selector:
    matchLabels:
      app: color
  template:
    metadata:
      labels:
        app: color
    spec:
      containers:
      - name: color
        image: docker.io/particule/simplecolorapi:2.0
        ports:
        - containerPort: 5000
```


Créer et exposer un pod avec l'image `docker.io/particule/simplecolorapi:1.0`

Est-ce que l'application est disponible ?


Schédulez un pod de test afin d'avoir un accès dans le cluster :

```yaml
---
apiVersion: v1
kind: Pod
metadata:
  name: debug
spec:
  containers:
  - name: debug
    image: rguichard/debug:amd64
    command: ["sleep", "36000"]
```


```
$ kubectl apply -f debug.yaml
$ kubectl exec -it debug -- /bin/bash
```


Lancez trois shells différents, dans les deux premiers, lancez :

Dans le pod debug, executez la commnde:
- `while true; do curl http://<SVC_ADDR>:5000; sleep 1; done`


- `while true; do kubectl get pod; sleep 1; clear; done`

Dans le troisième, mettez à jour l'image utilisée par le Deployment.

```console
$ kubectl set image deployment/color color=docker.io/particule/simplecolorapi:2.0
```

Que constatez vous sur les premiers shells ?

### Rolling updates
Finalement vous considérer que cette version `2.0` ne vous plait pas et décidez
de revenir en arrière.

Utiliser la commande `kubectl rollout` pour revenir à la version `1.0`.

On peut consulter l'historique des changement avec la commande:
```kubectl rollout history deployment color```


## Ingress
Ingress permet de simplifier l'accès aux applications.

Au lieu d'exposer à chaque fois un port pour chaque application,
on peut exposer un seul port pour reverse-proxy/loadbalancer
appelé `ingress controller`
qui permet de rediriger les requêtes en se basant sur de configuration.

Kubernetes permet de gérer ça avec des objets de type `ingress`


Pour commencer, il faut installer un ingress controller


``` bash
$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.5.1/deploy/static/provider/kind/deploy.yaml
```


```yaml
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myfirst-ingress
  annotations:
      nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - 
    http:
      paths:
      - pathType: Prefix
        path: "/colors"
        backend:
          service:
            name: color
            port:
              number: 5000

```


## Autoscaling

``` bash
# add metrics api
wget https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.6.2/components.yaml
sed '/args:/a \        - --kubelet-insecure-tls' -i components.yaml
kubectl apply -f components.yaml
```

``` yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: stress
spec:
  replicas: 1
  selector:
    matchLabels:
      app: stress
  template:
    metadata:
      labels:
        app: stress
    spec:
      containers:
      -
        name: stress
        image: docker.io/sametma/stress-ng
        command:
        - sh
        - -c
        - sleep $WAIT_TIME; stress-ng -c 1 -l $CPU_PERCENT
        env:
          -
            name: WAIT_TIME
            value: "10"
          -
            name: CPU_PERCENT
            value: "30"
        resources:
          requests:
            memory: "64Mi"
            cpu: "300m"
          limits:
            memory: "128Mi"
            cpu: "400m"
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: hpa-demo
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: stress
  minReplicas: 1
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
```


```
watch -n 1 kubectl top pods --selector app=stress
```


```
watch -n 1 kubectl get hpa
```