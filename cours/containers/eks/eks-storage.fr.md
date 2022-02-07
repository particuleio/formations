# EKS : Storage

## EKS Storage : Concepts

- Classes de stockage
- Les classes incluses dans Kubernetes ("In-tree")
- Les drivers CSI ("Out-of-tree" plugins)

## EKS Storage : Classes

## EKS Storage : Plugins de stockage inclus

Plugin `AWS EBS` disponible nativement dans Kubernetes.

- Type de volume SSD: `io1`, `gp2`
- Type de volume HDD: `sc1`, `st1`

## EKS Storage : Plugins additionnels (CSI)

- EBS CSI driver: Stockage via blocks
- EFS CSI driver: Stockage via NFS

## EKS Storage : EBS CSI driver

  - Utilise les mêmes ressources que le plugin "In-Tree" pour EBS
  - Offre des fonctionnalités additionnelles
    - Provisionnement de Volume "Block"
    - Snapshot de Volume
    - Redimensionnement de Volume

## EKS Storage : EFS CSI driver

  - Permet d'utiliser la solution NFS d'AWS (EFS)
  - Fonctionnalités
    - Chiffrement lors du transfert de données (via TLS)
    - Redimensionnement de volume

