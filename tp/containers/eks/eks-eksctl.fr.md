# Travaux Pratiques: EKS - eksctl

## Introduction

Ce TP permet de se familiariser avec le CLI `eksctl` de WeaveWorks,
qui permet d'administrer des Clusters EKS.

## Prérequis

- Un compte AWS
- `awscli>=1.16.156`
- `kubectl`

## Préparation

- Assurez vous d'avoir un compte AWS avec les permissions suffisantes pour administrer
des clusters EKS
- Configurez le CLI AWS via [fichier de configuration][cli-configure-file]
ou [variables d'environnement][cli-configure-env]

[cli-configure-file]: https://docs.aws.amazon.com/fr_fr/cli/latest/userguide/cli-configure-files.html
[cli-configure-env]: https://docs.aws.amazon.com/fr_fr/cli/latest/userguide/cli-configure-envvars.html

## Installation d'eksctl

Téléchargez et installez la dernière version de `eksctl`.

```bash
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
eksctl version  # 0.40.0
```

D'autres méthodes d'installation sont disponibles dans la [documentation d'eksctl][eksctl-install].

L'authentification de `eksctl` repose sur les méchanismes utilisés par `awscli`,
il n'est pas nécessaire d'effectuer de configuration additionnelle à partir du
moment où la CLI aws peut s'authentifier.

[eksctl-install]: https://eksctl.io/introduction/#installation

## Configuration en ligne de commande

Dans cette première partie du TP, vous allez mettre en place un cluster EKS
via la CLI `eksctl`, y ajouter un groupe de noeuds, mettre à jour ce cluster
et enfin, le supprimer.

### Création d'un cluster EKS en CLI

Créez un cluster EKS avec la version **1.18** de Kubernetes dans la region `eu-west-3`,
sans groupe de noeuds, avec comme nom `eks-tp`.

```bash
eksctl create cluster --region eu-west-3 --name eks-tp --without-nodegroup --version 1.18
```

Quelles ressources AWS sont créées ?

- `aws eks list-clusters --region eu-west-3`
- `aws ec2 describe-subnets --region eu-west-3`
- `kubectl get nodes`

### Ajout d'un group de noeuds géré par AWS (_managed node group_)

Une fois le _control plane_ en place, ajoutez un groupe de noeuds managés
composé de deux EC2 `t3.large`.

```bash
eksctl create nodegroup --name ng-manual --cluster eks-tp --region eu-west-3 \
  --node-type t3.large --nodes 2 \
  --managed --version 1.18
```

- `aws ec2 describe-instances --region eu-west-3`
- `kubectl get nodes`

Lors de la création de ressources, `eksctl` applique des tags automatiquement.

Observez les ressources AWS créées: quels sont les tags en générés par `eksctl` ?

### Mise à niveau de la version Kubernetes

Votre cluster EKS est maintenant prêt à l'emploi. Cependant, il n'utilise pas
la dernière version de Kubernetes.

Dans un premier temps, mettez à jour du control plane du cluster `eks-tp` pour
qu'il soit configuré pour utiliser la version **1.19**.

```bash
eksctl upgrade cluster --name eks-tp --version 1.19
```

Une fois le _control plane_ à jour, mettez à niveau le groupe de noeuds `ng-manual`.

```bash
eksctl upgrade nodegroup --cluster eks-tp --name ng-manual --kubernetes-version 1.19
```

> Quel comportement ont les noeuds durant l'upgrade ?

`kubectl get nodes`

### Suppression du cluster EKS

Dans un premier temps, supprimez le groupe de noeuds `ng-manual`.

```bash
eksctl delete nodegroup --region eu-west-3 --cluster eks-tp --name ng-manual
```

Une fois le groupe de noeuds supprimé, supprimez le cluster EKS `eks-tp`.

```bash
eksctl delete cluster --region eu-west-3 --name eks-tp
```

Note: Il est possible de supprimer directement un Clsuter EKS et les groupes de
noeuds associés en supprimant le Cluster EKS.

## Configuration du Cluster EKS via ClusterConfig

`eksctl` permet la création de clusters EKS via des manifestes YAML,
facile à manipuler et à historiser.

Dans cette seconde partie, vous allez configurer un cluster EKS
avec deux groupes de noeuds managés par AWS, du monitoring, de l'OIDC
ainsi que la CNI AWS. link

### Création d'une ClusterConfig

Créez un fichier `cluster-configuration.yaml` définissant les
metadatas du cluster EKS (nom, région et version de Kubernetes).

```yaml
---
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: eks-tp-config
  region: eu-west-3
  version: "1.19"
```

Ajoutez la définition des groupes de noeuds managés par AWS.

Le groupe "on-demand" permet d'assurer la disponibilité des noeuds et le groupe "spot"
vous permettra d'avoir des noeuds à une tarification plus attractive.

```yaml
managedNodeGroups:
  - name: on-demand
    minSize: 1
    maxSize: 2
    tags:
      Env: demo
    desiredCapacity: 1
    instanceTypes:
      - "t3.large"
      - "t3.xlarge"
  - name: spot
    spot: true
    minSize: 1
    maxSize: 2
    tags:
      Env: demo
    desiredCapacity: 2
    instanceTypes:
      - "t3.large"
      - "t3.xlarge"
```

Activez le support de logging via CloudWatch en definissant l'attribut `cloudwatch`.

```yaml
cloudWatch:
  clusterLogging:
    enableTypes:
      - "audit"
      - "authenticator"
```

`eksctl` peut configurer des addons lors de la creation du cluster EKS.

Configurez l'addon vpc-cni pour utiliser la CNI [vpc-native d'AWS][aws-vpc-cni].

[aws-vpc-cni]: https://github.com/aws/eks-charts/tree/master/stable/aws-vpc-cni

```yaml
addons:
  - name: vpc-cni
```

Pour finir, activez l'OIDC pour votre cluster.

```yaml
iam:
  withOIDC: true
```

Ci-dessous, le manifeste complet.

```yaml
---
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: eks-tp-config
  region: eu-west-3
  version: "1.19"

iam:
  withOIDC: true

addons:
  - name: vpc-cni

managedNodeGroups:
  - name: spot
    minSize: 1
    maxSize: 2
    desiredCapacity: 1
    instanceTypes:
      - "t3.large"
      - "t3.xlarge"
    spot: true

  - name: on-demand
    minSize: 1
    maxSize: 2
    desiredCapacity: 1
    instanceTypes:
      - "t3.large"
      - "t3.xlarge"

cloudWatch:
  clusterLogging:
    enableTypes:
      - "audit"
      - "authenticator"
```

Créez maintenant votre Cluster EKS via le manifeste.

```bash
eksctl create cluster -f clusterconfig.yaml
```

Après un instant, le clusters est disponible, en ligne et configuré.

```bash
kubectl get nodes -o wide
```

> Observez les IPs des Pods

Listez les EC2 du cluster.

```bash
aws ec2 describe-instances --query \
  'Reservations[].Instances[].{Instance:InstanceId,LaunchTime:LaunchTime}' \
  --filters "Name=tag:eks:cluster-name,Values=eks-tp-config"
```

### Suppression du cluster

Avec une utilisation similaire à celle de `kubectl`, la suppression du Cluster
s'effectue simplement en exécutant la commande "eksctl delete cluster" avec
le manifeste correspondant. Seules les métadatas sont prises en compte lors
de la suppression.

```bash
eksctl delete cluster -f clusterconfig.yaml
```
