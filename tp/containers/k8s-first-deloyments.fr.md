# Travaux Pratiques: Kubernetes - Intro déploiement

## Introduction

Déployer des Pods, des Deployments, tester la scalabilité et les Service de
base.

## Prérequis

- Cluster Kubernetes
- Kubectl


## déploiement
### Un simple déploiement

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
        image: docker.io/particule/simplecolorapi:1.0
        ports:
        - containerPort: 5000
```

```yaml
---
apiVersion: v1
kind: Service
metadata:
  name: helloworld
spec:
  type: ClusterIP
  ports:
  - port: 5000
    targetPort: 5000
  selector:
    app: helloworld
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
        image: docker.io/particule/simplecolorapi:1.0
        ports:
        - containerPort: 5000
```


Lancez trois shells différents, dans les deux premiers, lancez :

*(si le binaire `jq` n'est pas présent sur votre système, installez le)*

- `while true; do curl $(kubectl get $(kubectl get node -l node-role.kubernetes.io/master="" -o name) -o json | jq '.status.addresses[0].address' -r):$(kubectl get svc color -o json | jq '.spec.ports[].nodePort'); sleep 1; done`
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
