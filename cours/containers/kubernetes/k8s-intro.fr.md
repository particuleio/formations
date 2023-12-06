# Kubernetes : Introduction


### Kubernetes : Introduction

- Kubernetes est écrit en Go, compilé statiquement.
- Un ensemble de binaires sans dépendance
- Faciles à conteneuriser et à packager
- Peut se déployer uniquement avec des conteneurs sans dépendance d'OS

### Kubernetes : Architecuture simplifiée
![](./images/kubernetes_simple_arch.svg)


### Kubernetes : Clusters
- Kubernetes fonctionne en cluster
- Un cluster est un groupement des noeuds
- Les noeuds ont des rôles:
    - Master
    - Worker
    - ...
- Communication des noeuds workers avec les noeuds masters à travers API.


### Kubernetes : Noeuds Workers
- C'est là où les applications tournent !
- Les applications sont des conteneurs: besoin d'un Container Runtime.
- Service "agent" appelé `kubelet`:
    - assure le fonctionnement des services.
    - assure le fonctionnement des applications.
    - Communique avec les noeuds workers pour connaître qu'est ce qu'il faut faire.

### Kubernetes : Noeuds Masters
- Appelés aussi `Control Plane`
- Contrôlent le cluster Kubernetes
- Exposent une API

### Se connecter aux Clusters
- Communication à travers API
- Kubectl:
    - Outil pour interagir avec des Clusters Kubernetes
    - Configuration des clusters dans le fichier `kubeconfig`
- Des interfaces graphiques, tableaux de bords (Dashboards)

### Kubernetes : Pods
- Les unités déployables les plus petites dans Kubernetes représentant un ou plusieurs conteneurs

![](./images/kubernetes_simple_arch_pod.svg)


### Kubernetes : Service
- Un moyen de rendre un ensemble de pods accessible sur le réseau, soit à l'intérieur du cluster ou à l'extérieur.
- `Load Balancing` entre les Pods d'un même Service


### Kubernetes : Namespaces

- Fournissent une séparation logique des ressources :
    - Par utilisateurs
    - Par projet / applications
    - Autres...
- Les objets existent uniquement au sein d'un namespace donné
- Évitent la collision de nom d'objets



### Kubernetes : API Objects
- Les objets API de Kubernetes sont les briques de base du système Kubernetes. Ils incluent :
    - Les pods
    - Les services
    - Les namespaces
- Kubernetes dispose de nombreux autres types de ressources, comme Volume, ConfigMaps, Secrets, etc.




