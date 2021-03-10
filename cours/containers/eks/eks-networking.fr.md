# EKS : Networking

## EKS Networking : Concepts

- Configuration du VPC
- ENI: Elastic Network Interfaces d'AWS
- CNI: Container Network Interface
- Les Load-balancers AWS

## EKS Networking : VPC

![](images/aws-eks-vpc.png)

## EKS Networking : Sous-réseaux

  - Sous-réseaux publics
    - Permettent d'exposer les Load Balancers
    - Accès au control plane
  - Sous-réseaux privés
    - Empêchent d'accéder directement aux Nodes
    - Isolation des ressources
    - Communication interne au Cluster

## EKS Networking : Groupes de securité

- Groupe de securité du Cluster EKS
- Groupe de securité du plan de contrôle Kubernetes
- Groupe de securité des noeuds Kubernetes

## EKS Networking : Point d'accès au Cluster

- Accès public
- Accès privé
- Accès hybride (public et privé)

## EKS Networking : ENIs

AWS permet d'utiliser des Interfaces réseau Elastic, qui peuvent être
ajoutées aux EC2, ainsi qu'à différents services.

Les Elastic Network Interfaces (ENIs) représentent des cartes réseau
virtuelles, ce sont des ressources administrées en parallèle de la
gestion des EC2.

## EKS Networking : CNIs

- amazon-vpc-cni-k8s: permet d'utiliser les ENIs pour le networking Kubernetes
- calico: CNI open-source sans dépendance tierce

## EKS Networking : AWS CNI

La CNI aws `aws-vpc-cni-k8s` permet d'attribuer des IPs AWS directement
aux Pods via des ENIs.

La limite du maximum de Pods par noeud dépend du type d'instance. Cette limite
est définie d'après la formule suivante:

`(Nombre d'interfaces × (IP par interface - 1)) + 2`

### EKS AWS CNI : Exemples de calcul de Pods par instance

`(Interfaces × (IP par interface - 1)) + 2`

| Type d'instance | Nombre d'interfaces | IP par interface | Max Pods |
|-----------------|---------------------|------------------|----------|
| m4.large        |                  2  |               10 |       20 |
| t3.xlarge       |                  4  |               15 |       58 |
| m4.4xlarge      |                  8  |               30 |      234 |
| m5a.16xlarge    |                 15  |               50 |      737 |

## EKS Networking : Calico

Calico est un projet Open Source permettant:

- d'outrepasser la limite de Pods par noeud
- d'éviter l'enfermement propriétaire (_vendor lock-in_)

## EKS Networking : Load balancers

AWS Load Balancer Controller

- Application Load Balancer via les `Ingress`
- Network Load Balancer via les `Service`

