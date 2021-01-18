# Kubernetes : Architecture

### Kubernetes : Composants

- Kubernetes est écrit en Go, compilé statiquement.
- Un ensemble de binaires sans dépendance
- Faciles à conteneuriser et à packager
- Peut se déployer uniquement avec des conteneurs sans dépendance d'OS

### Kubernetes : Composants du Control Plane

- etcd: Base de données
- kube-apiserver : API server qui permet la configuration d'objets Kubernetes (Pod, Service, Deployment, etc.)
- kube-proxy : Permet le forwarding TCP/UDP et le load balancing entre les services et les backends (Pods)
- kube-scheduler : Implémente les fonctionnalités de scheduling
- kube-controller-manager : Responsable de l'état du cluster, boucle infinie qui régule l'état du cluster afin d'atteindre un état désiré

### Kubernetes : Composants du Control Plane

![](images/kubernetes/kubernetes-architecture.png){height="500px"}

### Kubernetes : Composants du Control Plane

![](images/kubernetes/architecture-2.png){height="500px"}

### Kubernetes : etcd

- Base de données de type Clé/Valeur (_Key Value Store_)
- Stocke l'état d'un cluster Kubernetes
- Point sensible (stateful) d'un cluster Kubernetes
- Projet intégré à la CNCF

### Kubernetes : kube-apiserver

- Les configurations d'objets (Pods, Service, RC, etc.) se font via l'API server
- Un point d'accès à l'état du cluster aux autres composants via une API REST
- Tous les composants sont reliés à l'API server

### Kubernetes : kube-scheduler

- Planifie les ressources sur le cluster
- En fonction de règles implicites (CPU, RAM, stockage disponible, etc.)
- En fonction de règles explicites (règles d'affinité et anti-affinité, labels, etc.)

### Kubernetes : kube-proxy

- Responsable de la publication des Services
- Utilise *iptables*
- Route les paquets à destination des conteneurs et réalise le load balancing TCP/UDP

### Kubernetes : kube-controller-manager

- Boucle infinie qui contrôle l'état d'un cluster
- Effectue des opérations pour atteindre un état donné
- De base dans Kubernetes : replication controller, endpoints controller, namespace controller et serviceaccounts controller

### Kubernetes : Autres composants

- kubelet : Service "agent" fonctionnant sur tous les nœuds et assure le fonctionnement des autres services
- kubectl : Ligne de commande permettant de piloter un cluster Kubernetes

### Kubernetes : Kubelet

- Service principal de Kubernetes
- Permet à Kubernetes de s'auto configurer :
    - Surveille un dossier contenant les *manifests* (fichiers YAML des différents composant de Kubernetes).
    - Applique les modifications si besoin (upgrade, rollback).
- Surveille l'état des services du cluster via l'API server (*kube-apiserver*).

### Kubernetes : Kubelet

- Assure la communication entre les nodes et l'apiserver
- En charge de créer les conteneurs au travers de l'interface Container Runtime
  Interface (CRI)
- Peut fonctionner avec différentes container runtimes

### Kubernetes : Kubelet

![](images/kubernetes/kubelet-cri.png){height="500px"}

### Kubernetes: Network

Kubernetes n'implémente pas de solution réseau par défaut, mais s'appuie sur des solutions tierces qui implémentent les fonctionnalités suivantes :

- Chaque pods reçoit sa propre adresse IP
- Les pods peuvent communiquer directement sans NAT

