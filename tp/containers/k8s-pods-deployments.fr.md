# Travaux Pratiques: Kubernetes - Intro déploiement

## Introduction

Déployer des Pods, des Deployments, tester la scalabilité et les Service de
base.

## Prérequis

- Cluster Kubernetes

## Pods

```yaml
---
apiVersion: v1
kind: Pod
metadata:
  name: pod
spec:
  containers:
    - name: pod
      image: hello-world
```

Appliquez ce pod avec la commande `kubectl apply -f pod.yaml`.

Vérifier que le pod est bien `Running` avec la commande `kubectl get pod`.

Avec la paramètre `-o wide` de la commande précédente, retrouvez l'IP du pod
ainsi que le node sur lequel il est déployé.

Comment peut-on accéder à l'IP du Pod pour vérifier qu'il fonctionne
correctement ?

## Deployments

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: helloworld
spec:
  replicas: 3
  selector:
    matchLabels:
      app: helloworld
  template:
    metadata:
      labels:
        app: helloworld
    spec:
      containers:
      - name: helloworld
        image: hello-world
        ports:
        - containerPort: 80
```

Appliquez ce Deployment avec la commande `kubectl apply -f deployment.yaml`.

Vérifier que les trois Pod sont bien `Running` avec la commande `kubectl get pod`.

Changez le nombre de réplicats du Deployment :

```console
$ kubectl scale deployment/helloworld --replicas=5
```

Vérifier le nombre de pod.

Appliquez à nouveau le fichier `deployment.yaml`, que se passe t-il ?

## Services

```yaml
---
apiVersion: v1
kind: Service
metadata:
  name: helloworld
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 80
  selector:
    app: helloworld
```

Vérifiez la création du Service. Sur quelle IP pouvez vous le joindre ? Est-ce
possible ?

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
    image: rguichard/debug
    command: ["sleep", "36000"]
```

```
$ kubectl apply -f debug.yaml
$ kubectl exec -it debug -- /bin/bash
```

Effectuer un `curl` sur la ClusterIP du Service et constatez le résultat. Que se
passe t-il si vous relancez plusieurs fois la commande `curl` ?

Quitter le pod avec `exit`.

Utilisez la commande `kubectl edit service helloworld` pour modifier le type de
Service et le transformer en `NodePort`.

Vérifiez la modification avec `kubectl get service`.

```console
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
helloworld   NodePort    10.103.251.40   <none>        80:30315/TCP   3h6m
```

Grâce à ce NodePort, avec quelle adresse pouvez vous accéder à ce service ?
(indice, la liste des Nodes peut être récupérée avec `kubectl get node`)


Supprimer le Deployment et le Service :

```console
$ kubectl delete deployment/helloworld service/helloworld
```

## Modification de l'image

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
        image: particule/simplecolorapi:1.0
        ports:
        - containerPort: 5000
---
apiVersion: v1
kind: Service
metadata:
  name: color
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 5000
  selector:
    app: color
```

Pour cette application, il existe 3 couples IP/port distincts permettant
d'y accéder. Lesquels sont-ils ?



Lancez trois shells différents, dans les deux premiers, lancez :

*(si le binaire `jq` n'est pas présent sur votre système, installez le)*

- `while true; do curl $(kubectl get $(kubectl get node -l node-role.kubernetes.io/master="" -o name) -o json | jq '.status.addresses[0].address' -r):$(kubectl get svc color -o json | jq '.spec.ports[].nodePort'); sleep 1; done`
- `while true; do kubectl get pod; sleep 1; clear; done`

Dans le troisième, mettez à jour l'image utilisée par le Deployment.

```console
$ kubectl set image deployment/color color=particule/simplecolorapi:2.0
```

Que constatez vous sur les premiers shells ?

Finalement vous considérer que cette version `2.0` ne vous plait pas et décidez
de revenir en arrière.

Utiliser la commande `kubectl rollout` pour revenir à la version `1.0`.
