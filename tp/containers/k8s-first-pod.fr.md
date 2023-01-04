# Travaux Pratiques: Kubernetes - Intro déploiement

## Introduction

Créer des Namespaces, Déployer des Pods et tester les Services de base.

## Prérequis

- Cluster Kubernetes
- kubectl


## Création des ressources avec les commandes kubectl
### Création et exposition d'un pod
``` bash
$ # Create pod named helloworld
$ kubectl run --image=docker.io/particule/helloworld:latest --port=80 helloworld
pod/helloworld created
$ # List pods
$ kubectl get pods
NAME         READY   STATUS    RESTARTS   AGE
helloworld   1/1     Running   0          13s
$ # Expose pod
$ kubectl expose pod helloworld --port=80 --target-port=80 --type=ClusterIP
service/helloworld exposed
$ # List services
$ kubectl get services
NAME            TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
kubernetes      ClusterIP   10.96.0.1      <none>        443/TCP   5m25s
helloworld   ClusterIP   10.96.61.159   <none>        80/TCP    3s
```

Le port du pod 80 est exposé via le service `helloworld`.
Le service est de type ClusterIP. C'est-à-dire que le service est disponible
au niveau du cluster.


``` bash
$ # Port forward to localhost
$ kubectl port-forward svc/helloworld --address 0.0.0.0  8081:80
Forwarding from 0.0.0.0:8081 -> 80
```

Maintenant le service est accessible via le navigateur sur le port 8080.

> PS: `Ctrl+C` pour arrêter le port forwarding.

### Découvrir les commandes de kubectl describe, exec et delete

Pour récupérer des informations sur les ressource créés, on peut utiliser
la commande `kubectl describe <RESOURCE_TYPE> <RESOURCE_NAME>`


On utilise souvent des abbréviations des types des ressources.
On peut trouver une liste des ressources qu'on peut créer ainsi que les abbréviation
avec la commande suivante:

``` bash
$ kubectl api-resources
NAME                              SHORTNAMES   APIVERSION                             NAMESPACED   KIND
...
pods                              po           v1                                     true         Pod
namespaces                        ns           v1                                     false        Namespace
services                          svc          v1                                     true         Service
...
```

On peut accéder au pod avec la commande `kubectl exec <OPTIONS> <POD_NAME> -- <COMMAND>`
```bash
$ # Print /www/index.php file
$ kubectl exec helloworld -- cat /www/index.php
$ # Access to container shell
$ kubectl exec -it helloworld -- sh
/ # ls 
bin           home          media         product_name  run           srv           usr
dev           lib           mnt           product_uuid  run.sh        sys           var
etc           linuxrc       proc          root          sbin          tmp           www
```


Pour supprimer un ressource, on peut utliser la commande `kubectl delete <RESOURCE_TYPE> <RESOURCE_NAME>`

### Création d'un namespace
Par défaut, les ressources sont créés dans le namespace `default`.
Kubernetes utilise les namespaces pour regrouper les ressources.

On peut créer un namespace avec la commande suivante :
```bash
$ kubectl create namespace test2
namespace/test2 created
```

Maintenant on peut céer un pod dans le namespace test2 en ajoutant l'option `--namespace=test2`.
On peut utiliser cette option avec les autres commande de kubectl `describe`, `create`, `delete`...

Si on supprime un namespace, tous les ressources créés dans ce namespace seront supprimés.

```bash
$ kubectl run --image=docker.io/particule/helloworld --namespace=test2 --port=80 helloworld2
pod/helloworld2 created
$ kubectl get pods --namespace test2
NAME          READY   STATUS    RESTARTS   AGE
helloworld2   1/1     Running   0          15s
```

## Méthode déclarative avec les manifests
Une autre méthode utilisée pour créer des ressources dans kubernetes est l'approche
déclarative avec des fichiers yaml appelés manifests.
Généralement on déploie les ressources avec cette méthode.


On peut consulter la description d'un ressource déjà déploié.
``` bash
kubectl get pod helloworld -o=yaml
```
``` yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: helloworld
  name: helloworld
  namespace: default
  ...
spec:
  containers:
  - image: docker.io/particule/helloworld
    imagePullPolicy: Always
    name: helloworld
    ...
    volumeMounts:
      ...
  volumes:
    ...
status:
  ...
```

Voici le manifest yaml pour créer un pod appelé `demoserver` dans le namespace
`default` avec le label `app: server` et avec l'image
`docker.io/sametma/server:1` :

```yaml
---
apiVersion: v1
kind: Pod
metadata:
  name: demoserver
  namespace: default
  labels:
    app: server
spec:
  containers:
    - name: demoserver
      image: docker.io/sametma/server:1
      ports:
      - containerPort: 80
        protocol: TCP
```

> On peut déployer les manifests avec la commande `kubectl apply -f <PATH>`.

Appliquez ce pod avec la commande `kubectl apply -f pod.yaml`.

Vérifier que le pod est bien `Running` avec la commande `kubectl get pod`.


```yaml
---
apiVersion: v1
kind: Service
metadata:
  name: demoserver
  namespace: default
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 80
  selector:
    app: server
```

Exposez le service avec cette commande:

```
$ kubectl port-forward svc/demoserver --address 0.0.0.0 8082:80
```

Vérifiez la disponibilité de l'application sur le chemin `/api/ping`


## Debug

Créer et exposer un pod avec l'image `docker.io/particule/simplecolorapi:1.0`

Est-ce que l'application est disponible ?

Regardez les logs du conteneur

Sur quel port l'application est disponible ?

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
    image: docker.io/rguichard/debug:amd64
    command: ["sleep", "36000"]
```


```
$ kubectl apply -f debug.yaml
$ kubectl exec -it debug -- /bin/bash
```

On peut vérifier la disponiblité de l'application 


## Installation du dashboard

``` bash
$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
$ # The following will create a serviceaccount with role admin
$ kubectl apply -f https://raw.githubusercontent.com/particuleio/k8s_dashboard_role/main/all.yaml
```

```
kubectl port-forward -n kubernetes-dashboard svc/kubernetes-dashboard --address 0.0.0.0 8443:443
```
Le dashboard est disponible sur ce lien <http://<HOST_IP>:8443/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/>


Lancez cette commande pour récupérer le token d'accès au dashboard:
```
kubectl --namespace kubernetes-dashboard get secrets cluster-admin-token -o=jsonpath="{.data.token}" | base64 -d; echo 
```

