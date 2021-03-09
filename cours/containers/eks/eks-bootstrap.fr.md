# EKS : bootstrapping

## EKS bootstrapping : Prérequis

- Configuration du réseau
- Configuration des tags
- Configuration des rôles IAM

## EKS bootstrapping: Configuration des tags

- Définir ou intégrer une politique de gestion des tags
(permet une gestion plus fine des ressources)

## EKS bootstrapping: Configuration réseau

  - Configurer un VPC
  - Configurer les sous-réseaux
    - Sous-réseaux publics uniquement
    - Sous-réseaux privés uniquement
    - Configuration de sous-réseaux publics et privés

## EKS bootstrapping: Configuration IAM

- Créer rôle IAM pour le cluster EKS

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

