# Travaux Pratiques: Kubernetes - ConfigMap et Secrets

## Introduction

Dans ce TP nous allons utiliser les objets notions de *Secrets* et de *ConfigMap*:

- Créer et utiliser une *ConfigMap* en variable d'environnement
- Utiliser une *ConfigMap* en tant que volume
- Créer et utiliser un *Secret* en tant que secret
- Utiliser un *Secret* en tant que volume

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

Avec `kubectl exec`, regardez les variables d'environnement disponibles dans
le conteneur.

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

Décrivez le pod. Avec `kubectl exec`, observez le comportement à l'intérieur du conteneur.

## *Secret*

Les *Secrets* fonctionnent exactement de la même manière que les *ConfigMap* à l'exception qu'ils sont stockés encodés en `base64`.

Les valeurs stockées dans un *Secret* au format `yaml` doivent être encodées au préalable.

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

Reprenez les déploiements utilisés pour les *ConfigMap* et ajoutez une variable d'environnement à partir d'un *Secret* :

```yaml
- name: SECRET_USERNAME
  valueFrom:
    secretKeyRef:
      name: test-secret
      key: username
```

Observez ensuite le comportement dans le pod avec `kubectl exec`.

Changer la valeur de l'username et réappliquez votre *Secret*. Que se passe t-il
dans votre pod ?

### Utiliser un *Secret* en tant que volume

Reprenez les déploiements utilisés pour les *ConfigMap* et ajoutez un volume à partir d'un secret :

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
