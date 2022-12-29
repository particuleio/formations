# Kubernetes : Custom Resource Defintion


### Kuberentes est extensible
- L'architecture de kubernetes est ouverte
- Kubernetes de se nature est extensible
- On peut définir d'autres ressources dans l'api-service pour les utiliser après
- Potentiellement, l'uilisatuer de kubernetes va rencontrer des CRDs 


### Custom Resource et Custom Resource Definition
- La différence entre CR et CRD est la même différence entre le pod qui tourne et le manifest yaml du pod
- Le CRD est la définiton du ressource
- Le CR est la ressource qui tourne


### Les controlleurs de kubernetes
- Pour chaque objet dans kubernetes il y a un controlleur qui s'assure du bon fonctionnement de l'objet.
- Le controlleur vise à tout moment à converger l'état désiré vers l'état actuelle:
  - L'état désirée représentée par le manifest Yaml puis stocké dans ETCD.
  - L'état actuelle et l'état des ressources et du système
- Pour utiliser des CRs et des CRDs, il faut définir un controlleur qui 


### Exemple de CRD
```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  creationTimestamp: null
  labels:
    prometheus: example
    role: alert-rules
  name: prometheus-example-rules
spec:
  groups:
  - name: ./example.rules
    rules:
    - alert: ExampleAlert
      expr: vector(1)
```

### Utilisation des Custom Resources
- De nos jours, kubernetes est utilisé partout
- C'est l'outil universel de gestion des conteneurs
- Son Controller Pattern est robuste et stable
- Plusieurs services offrent une solution basé sur les CRDs:
  - Il suffit de définir un simple manifest pour créer un ressource !

### Utilisation des Custom Resources
- Exemples:
  - Backups reguliers (Velero)
  - Alerts (Prometheues)
  - VMs (Kubevirt)
  - Infrastructure (Crossplane)
  - CI/CD (Tekton)
