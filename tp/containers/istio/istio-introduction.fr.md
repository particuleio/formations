# Travaux Pratiques: Istio - installation

## Introduction

Dans ce TP, nous allons installer Istio version 1.7 en mode CNI avec `istioctl`
ainsi que l'opérateur `istio`.

## Prérequis

Nous allons réutiliser le cluster `kubeadm` déployé avec Vagrant et déployer sur
celui ci. Nous allons travailler sur le nœud contrôleur avec `kubectl` installé.

Nettoyez les ressources crées précédemment afin d'avoir un cluster vide.

## Untaint du master

Pour des questions de ressources, nous allons utiliser également le contrôleur,
pour cela nous allons le `untaint`:

```console
kubectl taint nodes --all node-role.kubernetes.io/master-
```

## Installation de metallb

Afin de disposer de la fonctionnalité de Load Balancing pour les services
Kubernetes, nous allons déployer [metallb](https://metallb.universe.tf/installation/) :

```console
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.5/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.5/manifests/metallb.yaml
# On first install only
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 10.42.42.10-10.42.42.30
EOF
```

Vérifiez l'état des pods metallb :

```console
k -n metallb-system get pods
NAME                          READY   STATUS    RESTARTS   AGE
controller-65db86ddc6-rj5m4   1/1     Running   0          3m1s
speaker-f2xzp                 1/1     Running   0          3m1s
speaker-w4sjp                 1/1     Running   0          3m1s
```

## Installation de `istioctl`

```console
curl -sL https://istio.io/downloadIstioctl | sh -
export PATH=$PATH:$HOME/.istioctl/bin

istioctl
Istio configuration command line utility for service operators to
debug and diagnose their Istio mesh.

Usage:
  istioctl [command]

Available Commands:
  analyze         Analyze Istio configuration and print validation messages
  authz           (authz is experimental. Use `istioctl experimental authz`)
  convert-ingress Convert Ingress configuration into Istio VirtualService configuration
  dashboard       Access to Istio web UIs
  deregister      De-registers a service instance
  experimental    Experimental commands that may be modified or deprecated
  help            Help about any command
  install         Applies an Istio manifest, installing or reconfiguring Istio on a cluster.
  kube-inject     Inject Envoy sidecar into Kubernetes pod resources
  manifest        Commands related to Istio manifests
  operator        Commands related to Istio operator controller.
  profile         Commands related to Istio configuration profiles
  proxy-config    Retrieve information about proxy configuration from Envoy [kube only]
  proxy-status    Retrieves the synchronization status of each Envoy in the mesh [kube only]
  register        Registers a service instance (e.g. VM) joining the mesh
  upgrade         Upgrade Istio control plane in-place
  validate        Validate Istio policy and rules files
  verify-install  Verifies Istio Installation Status
  version         Prints out build version information

Flags:
      --context string          The name of the kubeconfig context to use
  -h, --help                    help for istioctl
  -i, --istioNamespace string   Istio system namespace (default "istio-system")
  -c, --kubeconfig string       Kubernetes configuration file
  -n, --namespace string        Config namespace

Additional help topics:
  istioctl options         Displays istioctl global options

Use "istioctl [command] --help" for more information about a command.
```

## Installation de l'opérateur `istio`

```console
istioctl operator init
```

## Installation de Istio

Il est ensuite possible de decrire un fichier YAML avec la configuration de
`istio`, par example :

```console
vim istio-install.yaml
```

```yaml
---
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  namespace: istio-system
  name: default
spec:
  profile: default
  components:
    cni:
      enabled: true
  values:
    cni:
      excludeNamespaces:
       - istio-system
       - kube-system
      logLevel: info
```

Créons ensuite le namespace `istio-system` pour appliquer le manifeste:

```console
kubectl create ns istio-system

kubectl apply -f istio-install.yaml
```

Vérifiez que les pods Istio démarrent bien dans le namespace `istio-system`:

```console
kubectl -n istio-system get pods
```

Vérifiez que les *Custom Resources Definition* sont bien présentes:

```console
kubectl get crds | grep istio
```

Nous allons activer l'injection de sidecar automatiquement sur le namespace
`default`:

```console
kubectl label namespace default istio-injection=enabled
```

Téléchargez ensuite Istio ainsi que les démonstrations associées:

```
curl -L https://istio.io/downloadIstio | sh -
```

Un dossier `istio-1.7.4` est créé dans le répertoire en cours.

## Deploiement des addons

Nous allons installer prometheus, grafana et Kiali afin de pouvoir visualiser la
suite du TP.

Kiali:

```console
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.7/samples/addons/kiali.yaml

# attendre quelques secondes que les CRD soient installées puis lancer une
# seconde fois

kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.7/samples/addons/kiali.yaml
```

Prometheus et Grafana:

```console
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.7/samples/addons/grafana.yaml

kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.7/samples/addons/prometheus.yaml
```

Vérifiez que les pods sont bien UP :

```console
kubectl -n istio-system get pods
NAME                                    READY   STATUS    RESTARTS   AGE
grafana-57bb676c4c-fssps                1/1     Running   0          37s
istio-cni-node-59t8g                    2/2     Running   4          40h
istio-cni-node-g667k                    2/2     Running   4          40h
istio-ingressgateway-55f67b4b7f-79w59   1/1     Running   1          40h
istiod-7c487bdcd7-kfwzr                 1/1     Running   1          41h
kiali-7d5cb68b45-zbtdq                  1/1     Running   0          3m2s
prometheus-7c8bf6df84-74jrh             2/2     Running   0          22s
```

