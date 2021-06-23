# EKS : Déploiement

## Déploiement EKS : Outils

  - CloudFormation, le service de déploiement Infrastructure as Code d'AWS
  - `eksctl` par WeaveWorks
  - Terraform de HashiCorp
    - Module EKS
    - Module tEKS
  - Autre outils de deploiement IaC
    - AWS CDK
    - Pulumi
    - Ansible

## EKS Déploiement : CloudFormation

- Service d'IaC d'AWS
- Template prêt à l'emploi disponible pour EKS
- Permet de réutiliser

### EKS CloudFormation : EKS

```yaml
---
Resources:
  EKSCluster:
    Type: 'AWS::EKS::Cluster'
    Properties:
      Name: 'eks-prod'
      Version: '1.18'
      RoleArn: >-
        arn:aws:iam::012345678910:role/eks-service-role-AWSServiceRoleForAmazonEKS-EXAMPLEBQ4PI
      ResourcesVpcConfig:
        SubnetIds:
          - subnet-eks-prod-a
          - subnet-eks-prod-b
          - subnet-eks-prod-c
```

_Définition du Cluster EKS_

### EKS CloudFormation : Node Group

```yaml
---
Resources:
  # ...
  EKSNodegroup:
    Type: 'AWS::EKS::Nodegroup'
    Properties:
      ClusterName: 'eks-prod'
      NodeRole: 'arn:aws:iam::012345678910:role/eksInstanceRole'
      ScalingConfig:
        MinSize: 1
        MaxSize: 5
      Subnets:
        - subnet-eks-prod-a
        - subnet-eks-prod-b
        - subnet-eks-prod-c
```

_Définition du NodeGroup EKS_

## Déploiement EKS : eksctl

- CLI officiel pour EKS (développé par WeaveWorks)
- Permet d'administrer les clusters EKS via une interface unique
- Opère via des stacks CloudFormations _under the hood_
- Configuration des addons EKS
- Bootstrapping GitOps - Flux

### EKS eksctl : Créer un Cluster (CLI)

```console
$ eksctl create cluster --name my-cluster \
  --region eu-west-3 --with-oidc \
  --nodes-min 1 --nodes-max 5 \
  --ssh-access --ssh-public-key eks --managed
[ℹ]  eksctl version 0.40.0
[ℹ]  using region eu-west-3
[ℹ]  setting availability zones to [eu-west-3c eu-west-3a eu-west-3b]
[ℹ]  subnets for eu-west-3c - public:192.168.0.0/19 private:192.168.96.0/19
[ℹ]  subnets for eu-west-3a - public:192.168.32.0/19 private:192.168.128.0/19
[ℹ]  subnets for eu-west-3b - public:192.168.64.0/19 private:192.168.160.0/19
...
[✔]  EKS cluster "my-cluster" in "eu-west-3" region is ready
```

_Création via `eksctl` en définissant le Cluster via les arguments en ligne de commande_

### EKS eksctl : Supprimer un Cluster (CLI)

```console
$ eksctl delete cluster --name my-cluster
[ℹ]  eksctl version 0.40.0
[ℹ]  using region eu-west-3
[ℹ]  deleting EKS cluster "my-cluster"
[ℹ]  deleted 0 Fargate profile(s)
...
[ℹ]  will delete stack "eksctl-my-cluster-cluster"
[✔]  all cluster resources were deleted
```

_Suppression du Cluster "my-cluster" via `eksctl`_

### EKS eksctl : Créer un Cluster (ClusterConfig)

```yaml
---
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: eks-prod
  region: eu-west-3

nodeGroups:
  - name: eks-1-workers
    instanceType: m5.xlarge
    minSize: 1
    maxSize: 5
    privateNetworking: true
```

```console
$ eksctl create cluster -f clusterConfigEKS.yaml
[ℹ]  eksctl version 0.40.0
[ℹ]  using region eu-west-3
[ℹ]  setting availability zones to [eu-west-3b eu-west-3c eu-west-3a]
...
[✔]  EKS cluster "eks-prod" in "eu-west-3" region is ready
```

_Création via `eksctl` en définissant le Cluster via ClusterConfig_

### EKS eksctl : Supprimer un Cluster (ClusterConfig)

```console
$ eksctl delete cluster -f clusterConfigEKS.yaml
[ℹ]  eksctl version 0.40.0
[ℹ]  using region eu-west-3
[ℹ]  deleting EKS cluster "eks-prod"
...
[ℹ]  will delete stack "eksctl-eks-prod-cluster"
[✔]  all cluster resources were deleted
```

_Suppression du Cluster via `eksctl` via ClusterConfig_

## Déploiement EKS : Terraform

  - Terraform de HashiCorp est un outil CLI pour l'IaC
  - Différents modules permettent de mettre en place des clusters EKS
    - `terraform-aws-modules/eks/aws/`
    - `cloudposse/eks-cluster/aws/`
  - Exemple d'utilisation dans `particuleio/teks`

### EKS Terraform : module EKS/aws

```hcl
module "eks-prod" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "eks-prod"
  cluster_version = "1.18"
  subnets         = [
    "subnet-eks-prod-a",
    "subnet-eks-prod-b",
    "subnet-eks-prod-c"
  ]
  vpc_id          = "vpc-eks-prod"

  worker_groups   = [
    {
      instance_type = "m4.large"
      asg_max_size  = 5
    }
  ]
}
```

### EKS Terraform : tEKS

![](images/teks-logo.png "tEKS logo"){height="200px"}

[particuleio/tEKS][github-teks] est un ensemble de modules
terraform et terragrunt pré-configurés pour une utilisation en production.

[github-teks]: https://github.com/particuleio/teks

### EKS Terraform : Composants tEKS

| Utilisation |                Module Terraform |
|-------------|---------------------------------|
|         VPC | `terraform-aws-modules/vpc/aws` |
|         EKS | `terraform-aws-modules/eks/aws` |
|      addons | `particuleio/addons/kubernetes` |

## Déploiement EKS : Autres outils de déploiement IaC

  - AWS CDK
    - CDK pour Cloud Development Kit
    - Génération de templates CloudFormation

  - Pulumi
    - Composants disponible dans différents langages
    - Composant dédié à EKS: pulumi/eks

  - Ansible
    - Outil d'IaC Open Source en Python
    - module EKS de la collection Community AWS

