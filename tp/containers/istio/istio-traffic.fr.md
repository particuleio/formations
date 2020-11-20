# Travaux Pratiques : Istio - Management de trafic

## Prérequis

Le cluster Kubeadm ainsi que le TP Istio - Introduction

## Déploiement de l'application bookinfo

L'application "bookinfo" déploie un exemple d'application composée de quatre
microservices distincts utilisés pour démontrer diverses fonctionnalités
d'Istio. L'application affiche des informations sur un livre, semblable à une
entrée de catalogue unique d'une librairie en ligne. La page affiche une
description du livre, les détails du livre et quelques avis sur le livre.

L'application Bookinfo est divisée en quatre microservices distincts :

- productpage : Le microservice de la page produit appelle les détails et examine les microservices pour remplir la page.
- details : Le microservice de détails contient des informations sur le livre.
- reviews : Le microservice des avis contient des critiques de livres. Il appelle également le microservice ratings.
- ratings : Le microservice de notation contient des informations sur la notes des livres qui accompagnent une critique de livre.

Il y a 3 versions du microservice reviews :

- Version v1 n'appelle pas le service de notation ratings.
- Version v2 appelle le service de notation ratings et affiche chaque note de 1 à 5 étoiles noires.
- Version v3 appelle le service de notation ratings et affiche chaque note de 1 à 5 étoiles rouges.

L'architecture de l'application est présentée ci-dessous :

![](https://istio.io/latest/docs/examples/bookinfo/withistio.svg)

Pendant le TP, il est important de bien regarder et comprendre les fichiers YAML
Istio déployés sur le cluster.

Déployez l'application :

```console
$ kubectl apply -f ~/istio-1.7.4/samples/bookinfo/platform/kube/bookinfo.yaml
service/details created
serviceaccount/bookinfo-details created
deployment.apps/details-v1 created
service/ratings created
serviceaccount/bookinfo-ratings created
deployment.apps/ratings-v1 created
service/reviews created
serviceaccount/bookinfo-reviews created
deployment.apps/reviews-v1 created
deployment.apps/reviews-v2 created
deployment.apps/reviews-v3 created
service/productpage created
serviceaccount/bookinfo-productpage created
deployment.apps/productpage-v1 created
```

Vérifiez l'état des pods et des services :

```console
$ kubectl get pods
NAME                              READY   STATUS    RESTARTS   AGE
details-v1-79c697d759-tcxsb       2/2     Running   0          4m11s
productpage-v1-65576bb7bf-8sxjc   2/2     Running   0          4m11s
ratings-v1-7d99676f7f-5gjvr       2/2     Running   0          4m10s
reviews-v1-987d495c-d7qp9         2/2     Running   0          4m11s
reviews-v2-6c5bf657cf-6zqdr       2/2     Running   0          4m11s
reviews-v3-5f7b9f4f77-pz959       2/2     Running   0          4m11s

$ kubectl get svc
NAME          TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
details       ClusterIP   10.97.94.201     <none>        9080/TCP   4m46s
kubernetes    ClusterIP   10.96.0.1        <none>        443/TCP    43h
productpage   ClusterIP   10.110.243.213   <none>        9080/TCP   4m46s
ratings       ClusterIP   10.108.2.80      <none>        9080/TCP   4m46s
reviews       ClusterIP   10.101.162.86    <none>        9080/TCP   4m46s
```

Pour accéder à l'application depuis l'extérieur il est nécessaire de déployer
une gateway Istio :

```console
$ kubectl apply -f ~/istio-1.7.4/samples/bookinfo/networking/bookinfo-gateway.yaml
```

Lors du déploiement de Istio, une Ingress gateway a été déployée automatiquement
dans le namespace `istio-system` :

```console
$ kubectl -n istio-system get svc

NAME                   TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                                                      AGE
grafana                ClusterIP      10.106.53.68     <none>        3000/TCP                                                     20m
istio-ingressgateway   LoadBalancer   10.100.188.234   10.42.42.10   15021:31119/TCP,80:30187/TCP,443:30371/TCP,15443:32343/TCP   41h
istiod                 ClusterIP      10.98.17.47      <none>        15010/TCP,15012/TCP,443/TCP,15014/TCP,853/TCP                41h
kiali                  ClusterIP      10.108.189.251   <none>        20001/TCP,9090/TCP                                           23m
prometheus             ClusterIP      10.108.53.116    <none>        9090/TCP                                                     20m
```

L'application est accessible depuis l'URL [http://10.42.42.10/productpage](http://10.42.42.10/productpage) :

![](https://particule.io/formations/images/istio/bookinfo.png)

Nous allons ensuite appliquer les règles de destinations vue pendant le cours
afin de définir les `subset` des différents services :

```console
$ kubectl apply -f  ~/istio-1.7.4/samples/bookinfo/networking/destination-rule-all.yaml
destinationrule.networking.istio.io/productpage created
destinationrule.networking.istio.io/reviews created
destinationrule.networking.istio.io/ratings created
destinationrule.networking.istio.io/details created
```

Par défaut, étant donné qu'il n'y a pas de règles de routage définies, le trafic
Sest acheminé de manière aléatoire entre les différentes version du service du
review : v1, v2 et v3.

## Variation du trafic avec les virtual services

Le dossier `~/istio-1.7.4/samples/bookinfo/networking` contient différents
exemples de management de trafic. Par exemple le fichier
`~/istio-1.7.4/samples/bookinfo/networking/virtual-service-all-v1.yaml` contient
les virtual services pour router vers les services en version 1 :

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: productpage
spec:
  hosts:
  - productpage
  http:
  - route:
    - destination:
        host: productpageG
        subset: v1
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: reviews
spec:
  hosts:
  - reviews
  http:
  - route:
    - destination:
        host: reviews
        subset: v1
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: ratings
spec:
  hosts:
  - ratings
  http:
  - route:
    - destination:
        host: ratings
        subset: v1
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: details
spec:
  hosts:
  - details
  http:
  - route:
    - destination:
        host: details
        subset: v1
```

Si vous appliquez ces fichiers :

```console
$ kubectl apply -f ~/istio-1.7.4/samples/bookinfo/networking/virtual-service-all-v1.yaml
```

Le trafic sera uniquement routé vers le service review en v1 et non plus en
round robin (vous ne verrez plus d'étoile pour les notations des livres).

## Visualisation avec Kiali

[Kiali](https://kiali.io/) est un dashboard pour Istio qui permet de visualiser
l'état d'un mesh Istio.

Pour accéder à Kiali :

```console
$ istioctl dashboard kiali --address 0.0.0.0
```

Il est ensuite possible d'accéder à Kiali depuis l'IP du master à l'URL
[http://10.42.42.42:20001](http://10.42.42.42:20001) :

![](https://particule.io/formations/images/istio/kiali-v1.png)

Déployez maintenant le fichier `virtual-service-reviews-v2-v3.yaml`, que
remarquez vous ?

Idem pour le fichier `virtual-service-reviews-v3.yaml`.

## A propos du mTLS

Par défaut la configuration du cluster est en permissive, les services pouvant
communiquer en mTLS via Envoy le font par défaut, tout en acceptant encore du
trafic en clair.


