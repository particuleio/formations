# Istio : Architecture

### Composants

- Plan de données : composé de proxy [Envoy](https://www.envoyproxy.io/)
- Plan de contrôle : `Istiod` qui pilote la configuration du plan de donnée

### Topologies

Istio supporte de multiples méthodes de déploiement :

- un ou plusieurs clusters
- un ou plusieurs réseaux
- un ou plusieurs plan de contrôle
- un ou plusieurs mesh

Toutes les combinaisons sont possibles

### Topologies

Single cluster : la configuration la plus simple et communément utilisée

![](images/istio/single-cluster.svg){height="400px"}

### Topologies

Multi cluster :

![](images/istio/multi-cluster.svg){height="400px"}

### Sidecar

Un sidecar est un conteneur fonctionnant à coté d'un autre conteneur au sein
d'un même pod. Dans un mesh Istio, chaque pods dispose d'un conteneur Envoy
qui proxy le trafic et s'intègre à Istio. C'est grâce à ce conteneur que le
code de l'application n'a pas besoin d'être modifié et que l'intégration
devient transparente pour l'application.

### Sidecar

Il existe plusieurs façons d'injecter ce sidecar dans les pods :

- manuellement via `istioctl`
- automatiquement via Kubernetes et un `MutatingAdmissionWebhook`
- automatiquement via webhook + CNI : recommandée


