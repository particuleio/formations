# Travaux Pratiques: Kubernetes - RBAC

## Introduction

Les RBAC contrôlent les accès dans Kubernetes, elles permettent de donner des
droits à la fois à des utilisateurs humains mais aussi directement à des pods.

Nous allons voir les différentes options offertes par Kubernetes :

- *Création d'un utilisateur*
- *Role / RoleBinding*
- *ClusterRole / ClusterRoleBinding*
- *Accès depuis un Pod"*

## Prérequis

- Cluster Kubernetes >= 1.19
- `kubectl`
- `kubeadm`

## Création d'un utilisateur

La notion d'utilisateur n'existe pas vraiment sur Kubernetes. Un utilisateur
généralement représenté par un certificat x509 dont le CommonName est le nom de
l'utilisateur. Pour que ce certificat soit valide, ce certificat doit avoir été
signé par l'autorité de certification interne à Kubernetes.

Pour créer ce certificat, on va utiliser une fonction de `kubeadm`. Pour cela,
connectez vous à un noeud master et lancez les commandes suivantes :

```console
$ kubectl get cm -n kube-system kubeadm-config -o jsonpath='{ .data.ClusterConfiguration }' > cluster-configuration.yaml
$ kubeadm alpha kubeconfig user --client-name red --config=cluster-configuration.yaml > kubeconfig
```

Le kubeconfig généré contient les crédentials pour un user `red`.

Lister les pods avec ce kubeconfig :

```console
$ export KUBECONFIG=kubeconfig
$ kubectl get pod
```

Que constatez vous ? Pourquoi ?


## Role et RoleBinding

Nous allons donner des droits à notre utilisateur.

```yaml
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: access-pod-svc
rules:
- apiGroups: [""]
  resources: ["pods", "services"]
  verbs: ["get", "list"]
```

Ce `Role` donne les droits de `get` et `list` sur les `Pods` et les `Services`.

Il faut maintenant lier ce `Role` avec notre User :

```yaml
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: rb-red
subjects:
- kind: User
  name: red
roleRef:
  kind: Role
  name: access-pod-svc
  apiGroup: rbac.authorization.k8s.io
```

On peut maintenant accéder au cluster :

```console
$ kubectl get pod
$ kubectl get services
$ kubectl get deploy
```

On a aussi la possibilité de donner accès à des ressources par leur nom.

Créons deux pods comme exemple :

```yaml
---
apiVersion: v1
kind: Pod
metadata:
  name: blue
spec:
  containers:
  - name: web
    image: particule/helloworld
---
apiVersion: v1
kind: Pod
metadata:
  name: green
spec:
  containers:
  - name: web
    image: particule/helloworld

```

Et modifions notre Role :

```yaml
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: access-pod-svc
rules:
- apiGroups: [""]
  resources: ["pods"]
  resourceNames: ["blue"]
  verbs: ["get", "list"]
```

Testons le comportement :

```console
$ kubectl get pods
$ kubectl get pods blue
$ kubectl get pods green
```

Que constatez vous ?


## Accès depuis un pod

Il est possible de donner un accès non pas à un User mais à un `ServiceAccount` :

```console
$ kubectl create serviceaccount monserviceaccount
```

```yaml
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: rb-red
subjects:
- kind: ServiceAccount
  name: monserviceaccount
roleRef:
  kind: Role
  name: access-pod-svc
  apiGroup: rbac.authorization.k8s.io
```

On va maintenant crer un `Pod` en le faisant utiliser notre `ServiceAccount`. Le
Pod va automatiquement hériter des droits affectés au `ServiceAccount`.

```yaml
---
apiVersion: v1
kind: Pod
metadata:
  name: kubectl
spec:
  serviceAccountName: monserviceaccount
  containers:
  - name: kubectl
    image: particule/kubectl
    command: ["/bin/sh", "-c", "sleep 1000"]
```

On se connecte ensuite au `Pod` pour effectuer les commandes :

```console
$ kubectl exec -it kubectl -- /bin/sh

/# kubectl get pods
/# kubectl get pods blue
```

Que constatez vous ?

## ClusterRole et ClusterRoleBinding

On souhaite maintenant utiliser des `ClusterRole` pour donner des droits à des
ressources non namespacées ou à l'ensemble des ressources namespacées du
cluster.

On crée un `ClusterRole` :

```yaml
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: access-node
rules:
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["get", "list"]
```

Et le `ClusterRoleBinding` associé :

```yaml
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: crb-sa
subjects:
- kind: ServiceAccount
  namespace: default
  name: monserviceaccount
roleRef:
  kind: ClusterRole
  name: access-node
  apiGroup: rbac.authorization.k8s.io
```

La spécificité ici est que nous devons spécifier le namespace dans lequel
existe notre `ServiceAccount` étant donné que le `ClusterRoleBinding` est non
namespacé.

On se connecte ensuite au `Pod` pour effectuer les commandes :

```console
$ kubectl exec -it kubectl -- /bin/sh

/# kubectl get pv
/# kubectl get nodes
```

Que constatez vous ?

