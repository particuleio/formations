# Travaux Pratiques: Istio - securité

## Introduction

Dans ce TP nous allons voir plus en détail le fonctionnement de mTLS

## Prérequis

Nous allons réutiliser le cluster kubeadm ainsi que le TP Istio - Introduction

## Déploiement de services

Nous allons activer mTLS de manière globale (mesh complet).

L'exemple qui suit utilise deux namespaces `foo` et `bar`, avec deux services,
httpbin et sleep, fonctionnant tous les deux avec un proxy Envoy sidecar.

Nous allons également deployer des services sans sidecar Envoy dans un namespace
`legacy` ou l'injection de sidecar est désactivée.

Créez les namespaces :

```console
$ kubectl create ns foo
$ kubectl create ns bar
$ kubectl create ns legacy
$ kubectl label namespace foo istio-injection=enabled
$ kubectl label namespace bar istio-injection=enabled
```

Déployez ensuite les services :

```console
$ kubectl apply -f ~/istio-1.7.4/samples/sleep/sleep.yaml -n foo
$ kubectl apply -f ~/istio-1.7.4/samples/sleep/sleep.yaml -n bar
$ kubectl apply -f ~/istio-1.7.4/samples/httpbin/httpbin.yaml -n foo
$ kubectl apply -f ~/istio-1.7.4/samples/httpbin/httpbin.yaml -n bar
```

Et enfin dans le namespace `legacy` :

```console
$ kubectl apply -f ~/istio-1.7.4/samples/sleep/sleep.yaml -n legacy
```

Vérifiez l'état des pods. La commande suivant permet de vérifier la
communication entre les différents pods `sleep` et les pods `httpbin` afin de
retourner un code d'erreur.

```console
for from in "foo" "bar" "legacy"; do for to in "foo" "bar"; do kubectl exec "$(kubectl get pod -l app=sleep -n ${from} -o jsonpath={.items..metadata.name})" -c sleep -n ${from} -- curl http://httpbin.${to}:8000/ip -s -o /dev/null -w "sleep.${from} to httpbin.${to}: %{http_code}\n"; done; done
sleep.foo to httpbin.foo: 200
sleep.foo to httpbin.bar: 200
sleep.bar to httpbin.foo: 200
sleep.bar to httpbin.bar: 200
sleep.legacy to httpbin.foo: 200
sleep.legacy to httpbin.bar: 200
```

## Activation du mTLS pour tout le cluster

```console
cat <<EOF | kubectl apply -f -
EOF
apiVersion: "security.istio.io/v1beta1"
kind: "PeerAuthentication"
metadata:
  name: "default"
spec:
  mtls:
    mode: STRICT
EOF
```

Que remarquez vous ?


