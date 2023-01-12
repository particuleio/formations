# Travaux Pratiques: Kubernetes - ConfigMap, Secrets et Volumes

## Introduction

Dans ce TP nous allons utiliser les objets notions de *Secrets* et de
*ConfigMap*:

- Créer et utiliser une *ConfigMap* en variable d'environnement
- Utiliser une *ConfigMap* en tant que volume
- Créer et utiliser un *Secret* en tant que secret
- Utiliser un *Secret* en tant que volume
- Créer et utiliser un volume persistant

## Prérequis

- Un cluster Kubernetes
- `kubectl`

## ConfigMap

Créez et appliquez le fichier `configmap.yaml` :

```yaml
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: log-config
data:
  log.level: WARNING
  log.location: LOCAL
```

### Utiliser une *ConfigMap* en tant que ENV

Créez et appliquez le déploiement suivant :

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: helloworld-cm-env
  labels:
    app: helloworld-cm-env
spec:
  replicas: 1
  selector:
    matchLabels:
      app: helloworld-cm-env
  template:
    metadata:
      labels:
        app: helloworld-cm-env
    spec:
      containers:
      - name: helloworld
        image: particule/helloworld
        ports:
        - containerPort: 80
        env:
          - name: LOG_LEVEL
            valueFrom:
              configMapKeyRef:
                name: log-config
                key: log.level
          - name: LOG_LOCATION
            valueFrom:
              configMapKeyRef:
                name: log-config
                key: log.location
```

Avec `kubectl exec`, regardez les variables d'environnement disponibles dans le
conteneur.

### Utiliser une *ConfigMap* en tant que volume

Créez et appliquez le déploiement suivant :

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: helloworld-cm-vol
  labels:
    app: helloworld-cm-vol
spec:
  replicas: 1
  selector:
    matchLabels:
      app: helloworld-cm-vol
  template:
    metadata:
      labels:
        app: helloworld-cm-vol
    spec:
      containers:
      - name: helloworld
        image: particule/helloworld
        ports:
        - containerPort: 80
        volumeMounts:
        - name: config-volume
          mountPath: /etc/config
      volumes:
      - name: config-volume
        configMap:
          name: log-config
```

Décrivez le pod. Avec `kubectl exec`, observez le comportement à l'intérieur du
conteneur.

## *Secret*

Les *Secrets* fonctionnent exactement de la même manière que les *ConfigMap* à
l'exception qu'ils sont stockés encodés en `base64`.

Les valeurs stockées dans un *Secret* au format `yaml` doivent être encodées au
préalable.

```console
$ echo -n "admin" | base64
$ echo -n "password" | base64
```

Créez le fichier `secret.yaml` et appliquez :

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: test-secret
type: Opaque
data:
  username: ADMIN_BASE64
  password: PASSWORD_BASE64
```

### Utiliser un *Secret* en tant que ENV

Reprenez les déploiements utilisés pour les *ConfigMap* et ajoutez une variable
d'environnement à partir d'un *Secret* :

```yaml
- name: SECRET_USERNAME
  valueFrom:
    secretKeyRef:
      name: test-secret
      key: username
```

Observez ensuite le comportement dans le pod avec `kubectl exec`.

Changez la valeur de l'username et réappliquez votre *Secret*. Que se passe t-il
dans votre pod ?

### Utiliser un *Secret* en tant que volume

Reprenez les déploiements utilisés pour les *ConfigMap* et ajoutez un volume à
partir d'un secret :

```yaml
volumes:
 - name: secret-volume
   secret:
     secretName: test-secret
```

```yaml
volumeMounts:
 - name: secret-volume
   mountPath: /etc/secret-volume
```

Avec `kubectl exec`, observez le comportement dans le pod.


## Les volumes persistants
La configuration suivante de redis ne permet le stockage persistant des données.

``` yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis
  labels:
    app: redis
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
      - name: redis
        image: docker.io/library/redis:7
        command:
          - sh
          - -c
          - |-
            redis-server --save 30 1
```

Si le pod s'arrête, on perd toutes les données parce que les données ne sont pas
enregistrées dans un volume persistant.

Pour créer un volume persistant il nous faut un `StorageClass`

Dans notre cluster kind, on a déjà un `StorageClass` avec le nom standard qui
permet de créer des volumes en local dans le Système de fichiers des noeuds.


``` bash
$ k get storageclasses.storage.k8s.io
NAME                 PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
standard (default)   rancher.io/local-path   Delete          WaitForFirstConsumer   false                  3d1h
```

Voici un exemple de `PersistentVolume` et `PersistentVolumeClaim`

``` yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-standard
spec:
  persistentVolumeReclaimPolicy: Retain
  storageClassName: standard
  capacity:
    storage: 500Mi
  accessModes:
    - ReadWriteOnce
  local:
    path: "/var/lib/test"
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - kind-control-plane
```


``` yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-loc-sc
spec:
  storageClassName: standard
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
  accessModes:
    - ReadWriteOnce
```



Ce qu'il faut faire:
1. Créez un objet de type `PersistentVolume`
2. Créez un objet de type `PersistentVolumeClaim`
3. Vérifiez l'état des PV et PVC avec la commande: `k get pv,pvc`
4. Ajoutez le volume au déploiement 
5. Associez le volume au conteneur redis avec l'option `volumeMounts`
6. Revérifiez l'état des PV et PVC avec la commande: `k get pv,pvc`



<!-- 
## Récupérer un secret externe avec un `init-container`
Dans certains cas, les secrets sont stockés dans un serveur externe.
Pour cela, il faut récupérer les secrets avant de lancer le conteneur principal.
On peut faire ça avec un `init-container` qui va exécuter un traitement juste avant le lancement du conteneur principal.

Voici un exemple d'un déploiement redis:


``` yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis
  labels:
    app: redis
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
      - name: redis
        image: docker.io/library/redis:7
        command:
          - sh
          - -c
          - |-
            redis-server --save 30 1 --requirepass $(cat /creds/password)
```

Le conteneur redis cherche le mot de passe dans le chemin `/creds/passwd`.


Ce qu'il faut faire:
1. Ajoutez un init conteneur
  - avec l'image `docker.io/sametma/tools:v1`
  - avec la commande:
``` bash
PASSWORD=$(curl https://dummyjson.com/users/1 | jq -r '.password')
echo PASSWORD=$PASSWORD
echo -e $PASSWORD > /creds/password
```
2. Ajoutez un volume éphémère (type `emptyDir`)
3. Partagez le volume avec l'init conteneur le conteneur redis avec le paramètre `volumeMounts` sur le chemin `creds`


<!-- 
      initContainers:
      -
        name: init
        image: docker.io/sametma/tools:v1
        command:
          - sh
          - -c
          - |-
            PASSWORD=$(curl https://dummyjson.com/users/1 | jq -r '.password')
            echo PASSWORD=$PASSWORD
            echo -e $PASSWORD > /creds/password
        volumeMounts:
          -
            name: creds
            mountPath: /creds
...
        volumeMounts:
        - name: creds
          mountPath: /creds
      volumes:
      - name: creds
        emptyDir: {}
 -->