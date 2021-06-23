# EKS : Integrations AWS

## EKS Intégrations AWS : Composants

  - Gestion de l'authentification / permissions
  - Stockage d'Images
  - Intégration network
    - Création de Load Balancers
    - aws-vpc-cni
  - Monitoring
    - Logs
    - Metrics
  - EKS Helm Charts

## EKS Intégrations AWS : IAM

`aws-iam-authenticator` permet d'utiliser les rôles / utilisateurs IAM
comme source de vérité pour l'authentification.

## EKS Intégrations AWS : ECR

Il est possible d'autoriser un Cluster EKS à utiliser un Elastic Container Registry
(ECR) sans authentification via un `Secret` en accordant les permissions ci-dessous
aux noeuds workers.

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:BatchCheckLayerAvailability",
                "ecr:BatchGetImage",
                "ecr:GetDownloadUrlForLayer",
                "ecr:GetAuthorizationToken"
            ],
            "Resource": "*"
        }
    ]
}
```

## EKS Intégrations AWS : Networking

  - CNI VPC-native: `aws-vpc-cni`
    - Permet d'assigner des IPs AWS aux Pods
  - Création dynamique de Load Balancer via le Load Balancer Controller
    - Les ressources `Ingress` provisionnent des Application Load Balancer
    - Les ressources `Service` provisionnent des Network Load Balancer

## EKS Intégrations AWS : Monitoring

Afin d'observer l'état du Cluster et des applications qui y sont déployées,
il est important de mettre en place du monitoring.

AWS propose des intégrations entre EKS et CloudWatch permettant de centraliser
la gestion des métriques du Cluster et des logs applicatifs, mais il existe
de nombreuses alternatives Open Source.

### EKS AWS Monitoring : Metriques

  - AWS Container Insights CloudWatch metrics
  - SaaS
    - logit.io
    - InfluxData
  - Prometheus Stack
    - Prometheus, Alertmanager, Grafana

### EKS AWS Monitoring : Logs

  - AWS: CloudWatch/ContainerInsights/Fluentd bit
  - SaaS
    - logz.io
    - datadog
  - Suite Elastic
    - Filebeat en agent de collection
    - Elasticsearch, Logstash, Kibana
  - Stack Grafana
    - Promtail, Loki, Grafana

## EKS Intégrations AWS : EKS Helm Charts

De nombreuses intégrations sont disponibles via des Charts Helm aws.github.io/eks-charts.

```console
$ helm repo add eks https://aws.github.io/eks-charts
"eks" has been added to your repositories
$ helm search repo eks
NAME                        CHART VERSION APP VERSION DESCRIPTION
eks/appmesh-controller      1.3.0         1.3.0       App Mesh controller ...
...
eks/aws-calico              0.3.4         3.15.1      A Helm chart for ins...
eks/aws-cloudwatch-metrics  0.0.4         1.247345    A Helm chart to depl...
eks/aws-for-fluent-bit      0.1.6         2.7.0       A Helm chart to depl...
```

## EKS Intégrations AWS : Exemples de Charts EKS

  - Intégrations avec le service AWS App Mesh
  - Déploiement d'agent de collection de metrics CloudWatch
  - Gestion des network policies (calico, aws-vpc-cni)
  - Automatisation du décomissionnement des instances
    - `AWS Node Termination Handler` automatise les opérations de maintenances
    côté ressources Kubernetes (cordon, drain)

