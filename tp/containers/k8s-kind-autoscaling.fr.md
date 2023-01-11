# Travaux Pratiques: Kubernetes - Intro déploiement


## Ajout des metrics

``` bash
curl -LO https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.6.2/components.yaml
sed '/args:/a \        - --kubelet-insecure-tls' -i components.yaml
kubectl apply -f components.yaml
```

Les metrics des pods:

```
kubectl top pods
```

Les metrics des noeuds:

```
kubectl top nodes
```


## Déploiement

Nous allons créer un déploiement avec une image contenant le programme `stress-ng` qui
permet de simuler un test de charge de consommation de CPU.

Il y a deux variables à configurer:
- `WAIT_TIME`: temps d'attente en secondes avant de lancer le test de charge
- `CPU_PERCENT`: consommation de CPU


Créez ce déploiement et observez la consommation de CPU

``` yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: stress
spec:
  replicas: 1
  selector:
    matchLabels:
      app: stress
  template:
    metadata:
      labels:
        app: stress
    spec:
      containers:
      -
        name: stress
        image: docker.io/sametma/stress-ng
        command:
        - sh
        - -c
        - sleep $WAIT_TIME; stress-ng -c 1 -l $CPU_PERCENT
        env:
          -
            name: WAIT_TIME
            value: "10"
          -
            name: CPU_PERCENT
            value: "7"
        resources:
          requests:
            memory: "64Mi"
            cpu: "100m"
          limits:
            memory: "128Mi"
            cpu: "500m"
```


Changer la valeur de `CPU_PERCENT` et observez la consommation de CPU


## L'autoscaling Horizontale
Mettez une valeur > 5 pour `CPU_PERCENT` puis créez le HPA suivant:

``` yaml
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: hpa-demo
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: stress
  minReplicas: 1
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
```


Lancez dans un autre terminal la commande suivante:
```
watch -n 1 kubectl top pods --selector app=stress
```


Lancez dans un autre terminal la commande suivante:
```
watch -n 1 kubectl get hpa
```


Que constatez-vous ?

Qu'est ce qui ce passe si on met `CPU_PERCENT` à 2 ?

## Conclusion et perspectives
Kubernetes nativement l'autoscaling horizontale pour les metrics de CPU et de RAM.
Ceci permet une meilleure adaptation des replicas face au charge.

Mais, selon vous est ce que c'est suffisant ?

