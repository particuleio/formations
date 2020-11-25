# Travaux Pratiques: Kubernetes - GitOps

## Introduction

Dans ce TP, nous allons appliquer la méthodologie GitOps pour déployer nos
applications.

La méthodologie GitOps vise à synchroniser un état désiré avec l'état réellement
déployé sur Kubernetes. L'état désiré est stocké sur Git et la synchronisation
est assurée par un composant installé dans Kubernetes. L'intéraction avec
l'état déployé se fait uniquement en modifiant, via Git, l'état désiré. Le
composant que nous utiliserons pour effectuer cette synchronisation est Flux
CD.

## Prérequis

- Un cluster Kubernetes
- `kubectl`
- `helm >= v3.0.0`
- Réussite du TP sur Helm
- Un repository git (de préférence public)
- Un compte sur Docker Hub


## Préparation de l'environnement

Pour notre application, nous allons utiliser cette application de démonstration
:

<https://github.com/particuleio/helloworld>

Vous pouvez soit la cloner et la pusher dans un nouveau repository ou bien
directement la forker dans votre environnement.

### Installation de Flux CD

Déployons Flux avec Helm avec le fichier de `values` suivants :

```yaml
syncGarbageCollection:
  enabled: true
git:
  url: "URL DE VOTRE REPO GIT"
  pollInterval: "2m"
registry:
  automationInterval: "2m"
```

```console
$ kubectl create namspace flux
$ helm repo add fluxcd https://charts.fluxcd.io
$ helm repo update
$ helm install -i flux fluxcd/flux --namespace flux --values values.yml
```

Il faut ensuite récupérer la clé publique générée par Flux et autoriser cette
clés à **lire/écrire** dans votre répository. En effet, Flux a aussi besoin
d'écrire dans votre repository pour y commit les changements de version d'image
Docker ainsi que pour y placer des tags lui permettant de se repérer.

```console
$ kubectl -n flux logs deployment/flux | grep identity.pub | cut -d '"' -f2

ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC2OEG/277kY2Q+/p9NoYYfWvncDQUbgwwhHPKCWvjFiVwewcMQooSHw+egr4nTSWZPsMfwrwLTRD6BXTnofLa8MrhNKjXdp1YR+lrLlBYmL7EPFjxvAhFu1aA77odSMQzLJQNl5/2Ef+m+VnfNFKrB+m6VjELAA5VNvQ2qni3jcYbYrr9mjxQkZnDlkZNz9iIwbw/GSUaAH9gYtUNcClFZaZR0POp96C5L5Jc0tyO41Zzj77UlpLYDlUUK8iX9U507/HgHNsA9fvJDt+lGfa+0xgHCN3gzdxsgNFVAF1A/RRW0/d/QnQ8g7PE4oNiYwMyWUuAHZMtLZqI0xdUQ8SVPtNFtDeyOkrm3vpYlQE2S8cBof96oLR8wDyPzAU6QYdS2QPxWNumdi2fK0iQbcEs+qLIY5+pD0f+60OV5YVz8QsVejp/rtrGPb39o9tAuDdwGYeRs0Agn6DnyZzcafk16uxzJ4DANZ6N6YX0IbVESFIQf0qYXz7azyOq0ill+CMM= root@flux-77c7d965d-w8sql
```

Notre repository git d'exemple est sur Github, il faut donc ajouter cette clé
dans les "Deploy keys" de notre repository avec les droits de
**lecture/écriture**.

### Création d'une release de notre application

Reprenons notre application clonée plus tôt. Nous allons créer une première
image Docker (version `1.0.0`) à partir de cette application. Nommez là par rapport à votre
compte sur Docker Hub.

```console
$ docker build -t monapp:1.0.0 .
$ docker push monapp
```

## Déploiement de notre application

Voici le yaml à utiliser :

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: helloworld
  labels:
    app: helloworld
  annotations:
    flux.weave.works/automated: "true"
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
        image: monapp:1.0.0
```

Commitez et pushez ce yaml dans notre repository git.

* Que constatez-vous dans les logs du pod Flux ?

Vérifiez le déploiement de votre application.

## Modification du déploiement

### Modification du nombre de réplicas

Vous souhaitez avoir 5 réplicas de votre pod au lieu de 3.

- Modifiez le fichier de déploiement en conséquence
- Commitez
- Pushez

Constatez le succès du déploiement sur le cluster.

### Ajout d'une ressource Kubernetes

Ajoutez, commitez et pushez cette ressource Service :

```yaml
---
apiVersion: v1
kind: Service
metadata:
  name: helloworld
spec:
  type: NodePort
  ports:
  - port: 80
  selector:
    app: helloworld
```

Constatez que vous pouvez joindre votre application via son NodePort.

## Upgrade de l'application

Modifiez l'application en changeant la couleur du background dans le fichier
index.php

```css
body {
  background-color:red;

[...]
```

Utilisez une autre couleur et rebuildez l'application en la tagant avec un
nouveau numéro de version.

```console
$ docker build -t monapp:2.0.0
$ docker push monapp:2.0.0
```

- Que constatez vous dans les logs du pod Flux ?

- Que constatez vous sur votre Deployment

- Que constatez vous sur votre repository Git ?

## Upgrade conditionnel

Avec notre configuration simpliste de Flux, n'importe quelle nouvelle image
remplace la précédente. Mais il est possible d'utiliser des filtres Semantic
Versionning pour ne déployer que certaines versions.

Ajoutez cette nouvelle annotation à notre Deployment :

```yaml
flux.weave.works/tag.helloworld: "semver:~2.0"
```

Cette règle indique que Flux ne déploiera que des images avec une version `>=
2.0 et < 2.1`.

- Construisez une nouvelle image en changeant de nouveau la couleur
- Taggez l'image `monapp:2.0.1`
- Pushez l'image

Que constatez vous sur le Deployment ? La couleur est-elle à jour ?

Maintenant :

- Construisez une nouvelle image en changeant de nouveau la couleur
- Taggez l'image `monapp:3.0.0`
- Pushez l'image

Que constatez vous sur le Deployment ? La couleur est-elle à jour ?


