# Istio: Introduction

### Présentation

- Fournit une implémentation du concept de service mesh
- Open Sourcé en 2017 par Google, IBM et Lyft

![](images/istio/logo.png){height="200px"}

### Fonctionnalités

- Load balancing  TCP, gRPC, HTTP et websocket
- Gestion de politiques de sécurité et de routage applicatif
- Métriques, logs et traçage applicatif au sein des clusters Kubernetes
- Sécurisation des communication via mTLS

### Architecture

![](images/istio/arch.svg){height="400px"}

### Management du trafic

- Configuration de règles de routage applicatives :
    - Timeout
    - Retry
    - Circuit Breaker
- Simplifie la mise en place de mises à jour automatiques :
    - Canary
    - Blue Green
- Réparation automatisée

### Sécurité

- Déporte la gestion de la sécurité à l'infrastructure sans impacter la couche applicative
- Authentification, autorisation et chiffrement entre les micro services
- Mise en place de politiques de sécurité entre les différents micro services

### Observabilité

- Map des communications entre micro services
- Tracing applicatif
- Monitoring et logging avec possibilité de réaliser des dashboard personnalisés
- Détection d'erreurs

### Plateforme

Istio fonctionne nativement avec Kubernetes mais peut s'intégrer à d'autres systèmes comme :

- Services enregistrés avec Consul
- Machines virtuelles


