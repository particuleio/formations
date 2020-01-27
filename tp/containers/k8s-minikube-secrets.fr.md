# Travaux Pratiques: Kubernetes - Minikube - Configuration

## Introduction

Dans ce TP nous allons utiliser les objets notions de *Secrets* et de *ConfigMap*:

- Créer et utiliser une ConfigMap en variable d'environnement
- Utiliser une *ConfigMap* en tant que volume
- Créer et utiliser un *Secret* en tant que secret
- Utiliser un *Secret* en tant que volume

## *ConfigMap*

Créez et appliquez le fichier `configmap.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: log-config
data:
  log.level: WARNING
  log.location: LOCAL
```

### Utiliser une *ConfigMap* en tant que ENV

Créez et appliquez le déploiement suivant:

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
        image: dockercloud/hello-world
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

Observez la description du pods. Avec `kubectl exec`, regardez les variables d'environnement disponibles dans le conteneur.

### Utiliser une *ConfigMap* en tant que volume

Créez et appliquez le déploiement suivant:

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
        image: dockercloud/hello-world
        ports:
        - containerPort: 80
        volumeMounts:
        - name: config-volume
          path: /etc/config
      volumes:
      - name: config-volume
        configMap:
          name: log-config
```

Décrivez le pods. Avec `kubectl exec`, observez le comportement a l'intérieur du conteneur.

## *Secret*

Les *Secrets*  fonctionnent exactement de la même manière que les *ConfigMap*  a l'exception qu'ils sont stockés encodés en `base64`.

Les valeurs stockées dans un *Secret* au format `yaml` doivent être encodées au préalable.

```bash
username=$(echo -n "admin" | base64)
password=$(echo -n "a62fjbd37942dcs" | base64)
```

Créez et appliquez:

```bash
echo "apiVersion: v1
kind: Secret
metadata:
  name: test-secret
type: Opaque
data:
  username: $username
  password: $password" >> secret.yaml
```

### Utiliser un *Secret* en tant que ENV

Reprenez les déploiement utilisés pour les *ConfigMap* et ajoutez une variable d'environnement à partir d'un secret:

```yaml
- name: SECRET_USERNAME
  valueFrom:
    secretKeyRef:
      name: test-secret
      key: username
```

Observez ensuite le comportement dans le pod avec `kubectl exec`.

### Utiliser un *Secret* en tant que volume

Reprenez les déploiements utilisés pour les *ConfigMap* et ajoutez un volume à partir d'un secret:

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
