# Kubernetes : Service Mesh

### Problématique

- Découpage des applications en micro services
- Communication inter service (est-west) accrue

![](images/kubernetes/mesh-01.png){height="300px"}

### Problématique

- Sans service mesh la logique de communication est codée dans chaque service
- Problématiques de sécurité ? Comment implémenter TLS entre les micro services ?
- Chaque micro service doit implémenter la logique métier ainsi les fonctions réseau, sécurité et fiabilité
- Augmente la charge sur les équipes de développement
- Disparité des langages de programmation : implémentation de la même logique N fois

### Problématique

L'augmentation du nombre du nombre de micro services peut provoquer :

- Une latence entre les services
- Peu de visibilité sur la santé des services individuels
- Peu de visibilité sur l'inter dépendance des services

### Kubernetes : service minimum

- L'objet *Service* supporte uniquement TCP/UDP ainsi que de la répartition de charge basique
- L'objet *Ingress* utilise un point central de communication : l'ingress contrôleur
- Pas d'objets natifs pour faire du routage applicatif poussé
- Nécessité d'augmenter les fonctionnalités par un service tiers

### Service Mesh

Les service mesh déportent la logique de communication au niveau de l'infrastructure et non plus au niveau de l'application. Les service mesh sont en général composés de deux plans:

- Un plan de données : effectue la communication entre les micro services.
- Un plan de contrôle : Programme le data plane et fourni des outils de configuration et de visualisation (CLI/Dashboard)

### Service Mesh : Plan de données

- Se basent sur un réseau de proxy
- Ne modifient pas l'application
- S'exécutent "à coté" : concept de sidecars
- Ces sidecars s'exécutent dans les même pods que l'application mais dans un conteneur différent

### Service Mesh : Plan de données

![](images/kubernetes/mesh-02.png){height="400px"}

### Service Mesh : Plan de contrôle

- Pilote le plan de donnée
- Permet la configuration de règles de routage applicatives
- Cartographie la communication entre les micro services
- Fourni des métriques applicatives :
    - Latences
    - Défaillances
    - Logique de retry (désengorgement du réseau)

### Service Mesh : Avantages

- Permettent aux développeurs de se focaliser sur l'application et non pas sur la communication des services
- Couche commune de communication qui facilite le débogage et l'identification des problèmes
- Évite automatiquement certaines défaillances grâce à du routage intelligent

### Service Mesh : Inconvénients

- Ajoute une surcouche à Kubernetes qui est déjà complexe
- Difficulté de migrer d'un service mesh à un autre
- Augmentent la nombre de conteneurs et de ressources consommées sur un cluster
- Paradoxalement les proxy rajoutent de la latence

### Service Mesh : Les solutions

Aujourd'hui les solutions sont multiples et offrent toutes plus ou moins les même fonctionnalités :

- Gestion du TLS mutuel et des certificats
- Authentification et autorisation
- Monitoring et traçage applicatif
- Routage du trafic via des règles applicatives

### Service Mesh : Les solutions

- [Istio](https://istio.io/) : Plus connu et le plus complexe, open sourcé par Google
- [Linkerd](https://linkerd.io/) : Hébergé dans la CNCF en incubation, open sourcé par Twitter
- [Consul](https://www.consul.io/use-cases/multi-platform-service-mesh) : Développé par Hashicorp
- [Traefik Maesh](https://traefik.io/traefik-mesh/) : Développé par Traefik Lab

