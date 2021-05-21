# Kubernetes : Gestion de la configuration des applications

### Kubernetes : ConfigMaps

- Objet Kubernetes permettant de stocker séparément les fichiers de configuration
- Il peut être créé d'un ensemble de valeurs ou d'un fichier resource Kubernetes (YAML ou JSON)
- Un `ConfigMap` peut sollicité par plusieurs `pods`

### Kubernetes : ConfigMap environnement (1/2)

```yaml
apiVersion: v1
data:
  username: admin
  url: https://api.particule.io
kind: ConfigMap
metadata:
  name: web-config
```

### Kubernetes : ConfigMap environnement (2/2)

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: configmap-env
spec:
  containers:
    - name: test-container
      image: k8s.gcr.io/busybox
      command: [ "/bin/sh", "-c", "env" ]
      env:
        - name: USERNAME
          valueFrom:
            configMapKeyRef:
              name: web-config
              key: username
        - name: URL
          valueFrom:
            configMapKeyRef:
              name: web-config
              key: url
  restartPolicy: Never
```

### Kubernetes : ConfigMap volume (1/2)

```yaml
apiVersion: v1
data:
  redis-config: |
    maxmemory 2mb
    maxmemory-policy allkeys-lru
kind: ConfigMap
metadata:
  name: redis-config
```

### Kubernetes : ConfigMap volume (2/2)

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: configmap-volume
spec:
  containers:
    - name: test-container
      image: k8s.gcr.io/busybox
      command: [ "/bin/sh", "-c", "head -v /etc/config/*" ]
      volumeMounts:
      - name: config-volume
        mountPath: /etc/config
  volumes:
    - name: config-volume
      configMap:
        name: redis-config
  restartPolicy: Never
```

### Kubernetes : Secrets

- Objet Kubernetes de type `secret` utilisé pour stocker des informations sensibles comme les mots de passe, les _tokens_, les clés SSH...
- Similaire à un `ConfigMap`, à la seule différence que le contenu des entrées présentes dans le champ `data` sont encodés en base64.
- Il est possible de directement créer un `Secret` spécifique à l'authentification sur une registry Docker privée.
- Il est possible de directement créer un `Secret` à partir d'un compte utilisateur et d'un mot de passe.

### Kubernets : Secrets

- S'utilisent de la même façon que les `ConfigMap`
- La seule différence est le stockage en base64
- 3 types de secrets:
  - `Generic`: valeurs arbitraire comme dans une `ConfigMap`
  - `tls`: certificat et clé pour utilisation avec un serveur web
  - `docker-registry`: utilisé en tant que `imagePullSecret` par un pod pour pouvoir pull les images d'une registry privée

### Kubernetes : Secrets


```console
kubectl create secret generic monSuperSecret --from-literal=username='monUser' --from-literal=password='monSuperPassword"
```

### Kubernetes : Secrets

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysecret
type: Opaque
data:
  username: YWRtaW4=
  password: MWYyZDFlMmU2N2Rm
```

Les valeurs doivent être encodées en base64.

