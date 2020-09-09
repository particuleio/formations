# Travaux Pratiques: Kubernetes - Scheduling

## Introduction

Les options de scheduling permettent de placer intelligemment et
automatiquement des pods sur des noeuds.

Nous allons voir les différentes options offertes par Kubernetes :

- *NodeSelector*
- *Affinity/AntiAffinity*
- *Taints* et *Tolerations*

## Prérequis

- Cluster Kubernetes `kubeadm` du TP précédent.

## NodeSelector

```
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

```
# k get pod
NAME                                   READY   STATUS    RESTARTS   AGE
pod-datacenter-alpha-dbfd46f9d-7xns5   0/1     Pending   0          10s
```

Appliquons le label sur un node et regardons :

```
$ kubectl get node
NAME     STATUS   ROLES    AGE     VERSION
master   Ready    master   46h     v1.19.0
node     Ready    <none>   9m53s   v1.19.0
root@master:~# kubectl label node node datacenter=alpha
node/node labeled
root@master:~# kubectl get pod -o wide
NAME                                   READY   STATUS    RESTARTS   AGE    IP                NODE   NOMINATED NODE   READINESS GATES
pod-datacenter-alpha-dbfd46f9d-7xns5   1/1     Running   0          2m5s   192.168.167.129   node   <none>           <none>
```

Notre pod a bien été assigné au node `node`.

Par défaut, un node possède des labels prédéfinis que vous pouvez utiliser :

```
$ kubectl describe node node
Name:               node
Roles:              <none>
Labels:             beta.kubernetes.io/arch=amd64
                    beta.kubernetes.io/os=linux
                    datacenter=alpha
                    kubernetes.io/arch=amd64
                    kubernetes.io/hostname=node
                    kubernetes.io/os=linux
```

On peut donc utiliser directement le nom d'un node avec
`kubernetes.io/hostname=node` pour assigner de façon extrêmement statique un
pod à un node.

## Affinity / Anti Affinity

Les règles d'affinité permettent de définir le scheduling pour un groupe de
pod. Elles vont permettent de placer des pods sur le même node ou, au
contraire, de les forcer sur des nodes différents.


On va ici souhaiter placer tous les pods de ce deployment sur des nodes ayant
un label `datacenter=alpha`. On se rappelle par rapport à l'exemple précédent
que seul `node` a ce label.

```
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

```
# k get pod -o wide
NAME                                   READY   STATUS        RESTARTS   AGE   IP                NODE   NOMINATED NODE   READINESS GATES
pod-affinity-alpha-697b9f5f-d5hhg      1/1     Running       0          23s   192.168.167.131   node   <none>           <none>
pod-affinity-alpha-697b9f5f-wvjpd      1/1     Running       0          23s   192.168.167.130   node   <none>           <none>
pod-datacenter-alpha-dbfd46f9d-7xns5   1/1     Terminating   0          17m   192.168.167.129   node   <none>           <none>
root@master:~# kubectl scale deploy/pod-affinity-alpha --replicas=5
deployment.apps/pod-affinity-alpha scaled
root@master:~# k get pod -o wide
NAME                                READY   STATUS    RESTARTS   AGE   IP                NODE   NOMINATED NODE   READINESS GATES
pod-affinity-alpha-697b9f5f-6497d   1/1     Running   0          6s    192.168.167.133   node   <none>           <none>
pod-affinity-alpha-697b9f5f-c2tqt   1/1     Running   0          6s    192.168.167.134   node   <none>           <none>
pod-affinity-alpha-697b9f5f-d5hhg   1/1     Running   0          58s   192.168.167.131   node   <none>           <none>
pod-affinity-alpha-697b9f5f-qq8nv   1/1     Running   0          7s    192.168.167.132   node   <none>           <none>
pod-affinity-alpha-697b9f5f-wvjpd   1/1     Running   0          58s   192.168.167.130   node   <none>           <none>
```

On confirme deux choses ici :

- Les deux premiers pods ont bien été schédulés sur `node`
- En cas de scale out, les nouveaux pods ont bien été schédulés, aussi, sur
  `node`


Changeons le code de notre Deployment :

```
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
              topologyKey: "kubernetes.io/hostname"
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

```
$ k get pod -o wide
NAME                           READY   STATUS    RESTARTS   AGE   IP                NODE     NOMINATED NODE   READINESS GATES
pod-antiaff-5d64c764f7-9rjq4   1/1     Running   0          94s   192.168.167.135   node     <none>           <none>
pod-antiaff-5d64c764f7-flvv7   1/1     Running   0          94s   192.168.219.74    master   <none>           <none>
```

Nos deux pods sont bien sur deux nodes différents. Et si nous scalons ?

```
# kubectl scale deploy/pod-antiaff  --replicas=5
deployment.apps/pod-antiaff scaled
root@master:~# kubectl get pod
NAME                           READY   STATUS    RESTARTS   AGE
pod-antiaff-5d64c764f7-2m5df   0/1     Pending   0          4s
pod-antiaff-5d64c764f7-7kthw   0/1     Pending   0          4s
pod-antiaff-5d64c764f7-7vlxm   0/1     Pending   0          4s
pod-antiaff-5d64c764f7-9rjq4   1/1     Running   0          4m26s
pod-antiaff-5d64c764f7-flvv7   1/1     Running   0          4m26s
```

Aucun node n'est disponible pour héberger ces nouveaux pods :

```
$ kubectl describe pod pod-antiaff-5d64c764f7-2m5df
[...]
Events:
  Type     Reason            Age   From  Message
  ----     ------            ----  ----  -------
  Warning  FailedScheduling  53s         0/2 nodes are available: 2 node(s) didn't match pod affinity/anti-affinity, 2 node(s) didn't match pod anti-affinity rules.
```


## Taints et Tolerations

Ces deux éléments permettent à l'inverse du nodeSelector et des (anti)affinity
d'empêcher un pod d'être schédulé sur un node. Première règle :

- Les taints sont appliqués aux nodes
- Les tolerations sont appliqués aux pods

Plaçons une taint sur nos deux nodes `node` :

```
$ kubectl taint node node region=secret:NoSchedule
$ kubectl taint node master region=secret:NoSchedule
```

Cela signifie que si un pod ne tolère pas cette taint, il ne pourra être
schédulé sur ce node.

Exemple :

```
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

```
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
tains des nodes.

Si on ajoute une Toleration :

```
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

```
$ kubectl get pod
NAME    READY   STATUS    RESTARTS   AGE
alpha   1/1     Running   0          4s
```

La Taint est toléré, le scheduling est autorisé.

Des effets autre que `NoSchedule` existe, notamment `NoExecute`. Celui ci
permet notamment de supprimer les pods *déjà* schédulés qui tournent sur un
node.

Ajoutons une nouvelle Taint à nos nodes :

```
$ kubectl taint node node security=topdefense:NoExecute
$ kubectl taint node master security=topdefense:NoExecute
```

```
$ kubectl get pod -o wide
NAME    READY   STATUS        RESTARTS   AGE     IP                NODE   NOMINATED NODE   READINESS GATES
alpha   1/1     Terminating   0          2m42s   192.168.167.136   node   <none>           <none>

$ kubectl get events
27s         Normal    TaintManagerEviction   pod/alpha                               Marking for deletion Pod default/alpha
27s         Normal    Killing                pod/alpha                               Stopping container alpha
```

On voit que notre pod est arrêté et grâce aux logs, on peut voir que ce pod a
été *évicté* par le TaintManagerEviction.
