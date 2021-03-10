# EKS : Noeuds

## Noeuds EKS : Types de noeuds

- Groupe de noeuds gérés par AWS (noeuds managés)
- Noeuds autogérés (noeuds self-managés)
- Les Profiles Fargate

### Noeuds EKS : Noeuds managés

- AWS administre la création, mise en service et mise à jours des noeuds managés.
- Utilisent l'AMI Amazon EKS basée sur Amazon Linux 2
- Configuration du groupe de noeuds (type d'instance, taille du groupe)
- Configuration du groupe d'autoscaling
- Gestion via le groupe de noeuds EKS

### Noeuds EKS : Noeuds self-managés

  - EC2 administrées manuellement qui rejoindront le Cluster
    - Le noeud doit se déclarer en tant que worker auprès de l'API Kubernetes
  - Le groupe de noeud est crée et configuré par AWS
  - Le provisionnement des noeuds se fait manuellement
    - Configuration de l'OS, du système, `kubelet`

### Noeuds EKS : Fargate

- Déploiement des Pods directement sur Fargate
- Paiement à l'utilisation des ressources (vCPU, RAM) par Pod
- Administration via des Profiles Fargates
- Type de noeud ne nécessitant pas d'EC2

## Noeuds EKS : Types de capacité de réservation

Comme les EC2 classiques, il est possible de provisionner
des instances via deux types de réservations:

- On-Demand: Réservation classique en paiment à l'utilisation
- Spot instances: Instances disponibles à prix réduit

### Noeuds EKS : Instances On-Demand

Le type de réservation "On-demand" permet d'avoir un contrôle
total sur le cycle de vie des EC2.

- Prix standard basé sur la Region AWS
- Instances disponibles par défaut
- Contrôle sur le cycle de vie des Noeuds (provisionnement, suppression, ...)
- Type de réservation stable mais onéreux

### Noeuds EKS : Instances Spot

Les instances "Spot" permettent d'optimiser les dépenses
liées au provisionnement des noeuds du Cluster.

  - Prix réduit, jusqu'à 1/10ème du prix On-demand
    - Basé sur la disponibilité au niveau de l'Availability Zone
  - Disponibilité dépend du "Spot Price", le prix maximum
  - Type de réservation moins stable mais _cost-effective_

