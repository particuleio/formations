# Travaux Pratiques : Istio - observabilité

## Introduction

Dans ce TP nous allons voir comment accéder au dashboard Grafana, Jaeger et
Kiali

## Prérequis

Nous allons réutiliser le cluster kubeadm ainsi que le TP Istio - Management de
trafic avec l'application bookinfo.

## Visualisation avec Kiali

[Kiali](https://kiali.io/) est un dashboard pour Istio qui permet de visualiser
l'état d'un mesh Istio.

Pour accéder à Kiali :

```console
$ istioctl dashboard kiali --address 0.0.0.0
```

Il est ensuite possible d'accéder a Kiali depuis l'IP du master à l'URL
[http://10.42.42.42:20001](http://10.42.42.42:20001) :

![](../../images/istio/kiali-v1.png)

## Visualisation avec Grafana

Pour accéder à Grafana :

```console
$ istioctl dashboard grafana --address 0.0.0.0
```

Il est ensuite possible d'accéder à Grafana depuis l'IP du master à l'URL
[http://10.42.42.42:3000](http://10.42.42.42:3000) :

![](../../images/istio/grafana-1.png)

![](../../images/istio/grafana-2.png)

Par défaut, Grafana contient des dashboards fourni par Istio afin de visualiser
diffèrent type de métrique telles que :

- Le plan de contrôle
- Les services virtuels
- Les workloads directement

## Traçage applicatif

Installez [`Jaeger`](https://www.jaegertracing.io/) qui est une solution open
source dans la CNCF et intégré à Istio.

```console
$ kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.7/samples/addons/jaeger.yaml
```

Il faut ensuite générer du trafic à destination de l'application. Par défaut, la
valeur d'échantillonnage est de 1% :

```console
$ for i in $(seq 1 100); do
  curl -s -o /dev/null "http://$GATEWAY_URL/productpage";
done
```

Accédez ensuite au dashboard de Jaeger :

```console
$ istioctl dashboard jaeger --address 0.0.0.0
```

Il est ensuite possible d'accéder à Jaeger depuis l'IP du master à l'URL
[http://10.42.42.42:3000](http://10.42.42.42:16686) :

![](../../images/istio/jaeger-1.png)

![](../../images/istio/jaeger-2.png)


