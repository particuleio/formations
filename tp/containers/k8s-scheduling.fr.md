# Travaux Pratiques: Kubernetes - Scheduling

## Introduction

Les options de scheduling permettent de placer intelligemment et
automatiquement des pods sur des noeuds.

Nous allons voir les différentes options offertes par Kubernetes :

- *NodeSelector*
- *Affinity/AntiAffinity*
- *Taints* et *Tolerations*

## Prérequis

- Cluster Kubernetes avec au moins 2 nodes

Si vous avez un noeud `master`, il est probable que vous ne puissiez schéduler
de pod dessus. Vous pouvez supprimer cettte limite :

```console
$ kubectl taint nodes --all node-role.kubernetes.io/master-
```

Vous devriez comprendre cette commande à la fin du TP ;)

## NodeSelector

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      manager: robert
  template:
    metadata:
      labels:
        manager: robert
    spec:
      nodeSelector:
        datacenter: alpha
      containers:
      - name: nginx
        image: particule/helloworld
        ports:
        - containerPort: 80
```

`nodeSelector` fait partie de la spec du pod et défini de façon très simple
l'assignation du pod à un node possédant un label `datacenter=alpha`.

Si on applique, on voit que notre pod reste en pending car aucun node ne
possède un label à cette valeur.

```console
$ kubectl get pod
NAME                                   READY   STATUS    RESTARTS   AGE
pod-datacenter-alpha-dbfd46f9d-7xns5   0/1     Pending   0          10s
```

Appliquons le label sur un node et regardons :

```console
$ kubectl get node
NAME     STATUS   ROLES    AGE     VERSION
master   Ready    master   46h     v1.19.0
worker     Ready    <none>   9m53s   v1.19.0
root@master:~# kubectl label node worker datacenter=alpha
node/worker labeled
root@master:~# kubectl get pod -o wide
NAME                                   READY   STATUS    RESTARTS   AGE    IP                NODE   NOMINATED NODE   READINESS GATES
pod-datacenter-alpha-dbfd46f9d-7xns5   1/1     Running   0          2m5s   192.168.167.129   worker   <none>           <none>
```

Notre pod a bien été assigné au node `worker`.

Par défaut, un node possède des labels prédéfinis que vous pouvez utiliser :

```console
$ kubectl describe node worker
Name:               worker
Roles:              <none>
Labels:             beta.kubernetes.io/arch=amd64
                    beta.kubernetes.io/os=linux
                    datacenter=alpha
                    kubernetes.io/arch=amd64
                    kubernetes.io/hostname=worker
                    kubernetes.io/os=linux
```

On peut donc utiliser directement le nom d'un node avec
`kubernetes.io/hostname=worker` pour assigner de façon extrêmement statique un
pod à un node.

## Affinity / Anti Affinity

Les règles d'affinité permettent de définir le scheduling pour un groupe de
pod. Elles vont permettent de placer des pods sur le même node ou, au
contraire, de les forcer sur des nodes différents.


On va ici souhaiter placer tous les pods de ce deployment sur des nodes ayant
un label `datacenter=alpha`. On se rappelle par rapport à l'exemple précédent
que seul `worker` à ce label.

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pod-affinity-alpha
spec:
  replicas: 2
  selector:
    matchLabels:
      app: scheduling
  template:
    metadata:
      labels:
        app: scheduling
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: datacenter
                operator: In
                values:
                - alpha
      containers:
      - name: alpha
        image: particule/helloworld
        ports:
        - containerPort: 80
```

On applique :

```console
# kubectl get pod -o wide
NAME                                   READY   STATUS        RESTARTS   AGE   IP                NODE   NOMINATED NODE   READINESS GATES
pod-affinity-alpha-697b9f5f-d5hhg      1/1     Running       0          23s   192.168.167.131   worker   <none>           <none>
pod-affinity-alpha-697b9f5f-wvjpd      1/1     Running       0          23s   192.168.167.130   worker   <none>           <none>
pod-datacenter-alpha-dbfd46f9d-7xns5   1/1     Terminating   0          17m   192.168.167.129   worker   <none>           <none>
root@master:~# kubectl scale deploy/pod-affinity-alpha --replicas=5
deployment.apps/pod-affinity-alpha scaled
root@master:~# kubectl get pod -o wide
NAME                                READY   STATUS    RESTARTS   AGE   IP                NODE   NOMINATED NODE   READINESS GATES
pod-affinity-alpha-697b9f5f-6497d   1/1     Running   0          6s    192.168.167.133   worker   <none>           <none>
pod-affinity-alpha-697b9f5f-c2tqt   1/1     Running   0          6s    192.168.167.134   worker   <none>           <none>
pod-affinity-alpha-697b9f5f-d5hhg   1/1     Running   0          58s   192.168.167.131   worker   <none>           <none>
pod-affinity-alpha-697b9f5f-qq8nv   1/1     Running   0          7s    192.168.167.132   worker   <none>           <none>
pod-affinity-alpha-697b9f5f-wvjpd   1/1     Running   0          58s   192.168.167.130   worker   <none>           <none>
```

On confirme deux choses ici :

- Les deux premiers pods ont bien été schédulés sur `worker`
- En cas de scale out, les nouveaux pods ont bien été schédulés, aussi, sur
  `worker`


Changeons le code de notre Deployment :

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pod-antiaff
spec:
  replicas: 2
  selector:
    matchLabels:
      app: scheduling
  template:
    metadata:
      labels:
        app: scheduling
    spec:
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - scheduling
      containers:
      - name: alpha
        image: particule/helloworld
        ports:
        - containerPort: 80
```

Contrairement à précédemment on nous avons utilisé une affinité de *node*, ici
nous utilisons une anti affinité de *pod*. La règle dit "il est interdit de
schéduler un pod sur un node possédant déjà un pod avec un label
app=scheduling".

Appliquons :

```console
$ kubectl get pod -o wide
NAME                           READY   STATUS    RESTARTS   AGE   IP                NODE     NOMINATED NODE   READINESS GATES
pod-antiaff-5d64c764f7-9rjq4   1/1     Running   0          94s   192.168.167.135   worker     <none>           <none>
pod-antiaff-5d64c764f7-flvv7   1/1     Running   0          94s   192.168.219.74    master   <none>           <none>
```

Que constate t-on ?

Si on scale notre deployment avec la commande `kubectl scale`, le comportement
est il logique par rapport à notre première observation ?

```console
$ kubectl describe pod pod-antiaff-5d64c764f7-2m5df
[...]
Events:
  Type     Reason            Age   From  Message
  ----     ------            ----  ----  -------
  Warning  FailedScheduling  53s         0/2 nodes are available: 2 node(s) didn't match pod affinity/anti-affinity, 2 node(s) didn't match pod anti-affinity rules.
```


## Taints et Tolerations

Ces deux éléments permettent à l'inverse du nodeSelector et des (anti)affinity
d'empêcher un pod d'être schédulé sur un node. Premières règles :

- Les taints sont appliquées aux nodes
- Les tolerations sont appliquées aux pods

Plaçons une taint sur nos deux nodes `worker` :

```console
$ kubectl taint node worker region=secret:NoSchedule
$ kubectl taint node master region=secret:NoSchedule
```

Une taint est toujours de la forme `key=value:effect` avec `value` optionnelle.

Cela signifie que si un pod ne tolère pas cette taint, il ne pourra être
schédulé sur ce node.

Exemple :

```yaml
---
apiVersion: v1
kind: Pod
metadata:
  name: alpha
spec:
  containers:
  - name: alpha
    image: particule/helloworld
```

```console
$ kubectl get pod
NAME    READY   STATUS    RESTARTS   AGE
alpha   0/1     Pending   0          3s
root@master:~# kubectl describe pod alpha
Name:         alpha
Namespace:    default
Priority:     0
Node:         <none>
Labels:       <none>
Annotations:  <none>
Status:       Pending
IP:
IPs:          <none>
[...]
Events:
  Type     Reason            Age   From  Message
  ----     ------            ----  ----  -------
  Warning  FailedScheduling  9s          0/2 nodes are available: 2 node(s) had taint {region: secret}, that the pod didn't tolerate.
```

On voit que le pod ne peut être schédulé nul part car il ne tolère aucune des
taints des nodes.

Si on ajoute une Toleration :

```yaml
---
apiVersion: v1
kind: Pod
metadata:
  name: alpha
spec:
  containers:
  - name: alpha
    image: particule/helloworld
  tolerations:
  - key: "region"
    operator: "Equal"
    value: "secret"
    effect: "NoSchedule"
```

```console
$ kubectl get pod
NAME    READY   STATUS    RESTARTS   AGE
alpha   1/1     Running   0          4s
```

Que se passe t-il ?

Des effets autre que `NoSchedule` existe, notamment `NoExecute`. Celui ci
permet notamment de supprimer les pods *déjà* schédulés qui tournent sur un
node.

Ajoutons une nouvelle Taint à nos nodes :

```console
$ kubectl taint node worker security=topdefense:NoExecute
$ kubectl taint node master security=topdefense:NoExecute
```

```console
$ kubectl get pod -o wide
NAME    READY   STATUS        RESTARTS   AGE     IP                NODE   NOMINATED NODE   READINESS GATES
alpha   1/1     Terminating   0          2m42s   192.168.167.136   worker   <none>           <none>

$ kubectl get events
27s         Normal    TaintManagerEviction   pod/alpha                               Marking for deletion Pod default/alpha
27s         Normal    Killing                pod/alpha                               Stopping container alpha
```

On voit que notre pod est arrêté et grâce aux logs, on peut voir que ce pod a
été *évicté* par le TaintManagerEviction.
