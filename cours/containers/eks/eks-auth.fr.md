# EKS : Authentification

## EKS Authentification : EKS

L'authentification au Cluster EKS se fait via IAM.

Cependant, l'utilisation des ressources et l'authentification au Cluster Kubernetes
s'effectue tout de même via RBAC.

## EKS Authentification : oidc

- EKS supporte OpenID Connect
- Permet d'associer un identity provider au Cluster

## EKS oidc : configuration

```bash
eksctl associate identityprovider
```

## EKS Authentification : IAM Authenticator

AWS IAM Authenticator pour Kubernetes permet d'administrer
l'accès au Cluster via les roles IAM.

## EKS IAM Authentificator : Intégration RBAC et IAM

- Création d'un rôle IAM
- Création d'un compte de service dans le Cluster
- Les comptes sont liés via un ConfigMap

## EKS IAM Authentificator : Connexion

- Authentification via `aws-iam-authenticator token`
- `aws-iam-authenticator server` valide l'auth via le rôle IAM
- Le `Role` Kubernetes correspondant est attribué au user

