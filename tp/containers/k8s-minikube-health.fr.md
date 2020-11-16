# Travaux Pratiques: Kubernetes - Minikube

## Introduction

Dans ce TP nous allons observer le comportement des deux types de sondes
disponibles dans Kubernetes :

- liveness
- readiness

Nous allons dans un premier temps créer deux déploiements.

Créez et appliquez le fichier `good-de.yaml` :

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  labels:
    app: frontend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: frontend
        image: katacoda/docker-http-server:health
        ports:
        - containerPort: 80
        readinessProbe:
            httpGet:
              path: /
              port: 80
            initialDelaySeconds: 1
            timeoutSeconds: 1
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 1
          timeoutSeconds: 1
```

Créez et appliquez le fichier `bad-de.yaml` :

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: bad-frontend
  labels:
    app: bad-frontend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: bad-frontend
  template:
    metadata:
      labels:
        app: bad-frontend
    spec:
      containers:
      - name: bad-frontend
        image: katacoda/docker-http-server:unhealthy
        ports:
        - containerPort: 80
        readinessProbe:
            httpGet:
              path: /
              port: 80
            initialDelaySeconds: 1
            timeoutSeconds: 1
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 1
          timeoutSeconds: 1
```

Créez et appliquez le service `service.yaml` :

```yaml
kind: Service
apiVersion: v1
metadata:
  labels:
    app: frontend
  name: frontend
spec:
  type: NodePort
  ports:
  - port: 80
    nodePort: 30080
  selector:
    app: frontend
```

Ici les checks sont réalisés via le protocole HTTP sur l'URL `/`.  Il est possible d'exécuter le check sur un autre chemin ou même d'utiliser TCP comme protocole par exemple (cf. cours).

Regardez le status des pods du deployment `bad-frontend`. Que remarquez vous ?

Décrivez les pods pour voir ce qu'il se passe en détail.

Comme les healthcheck ne passent pas, kubernetes indique que 0/1 conteneur est prêt. Décrivez les pods issus du déploiement `frontend` et regardez l'état des healthcheck.

Nous allons maintenant provoquer un crash d'un pod `frontend` :

```console
$ kubectl exec -it $FRONTEND_POD -- /usr/bin/curl -s localhost/unhealthy
```

Que se passe t- il ? (regardez le compteur de restart).
