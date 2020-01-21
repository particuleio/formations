# Kubernetes: ou deployer et comment ?

### Bare metal, private et public Clouds

![](images/kubernetes/azure_h.png){height="50px"}
![](images/kubernetes/aws_h.png){height="50px"}
![](images/kubernetes/gcp_h.png){height="50px"}
![](images/kubernetes/magnum_h.png){height="50px"}

Managed - Kops - Kubespray - Kubeadm - Kube-aws - Symplegma

▼

Cluster Deployment

Cluster Lifecycle

### Infrastucture as code

IaC: Infrastructure as Code

▼

Terraform - CloudFormation - Cloud Deployment Manager - OpenStack Heat - Azure Resource Manager

▼

Declarative infrastructure

Immutable infrastructure

### Implémentation de référence

![](images/kubernetes/infra_ref.png){height="500px"}

### Que choisir ?

*Je veux utiliser Kubernetes*

*Cloud ?*

*Cloud public ou privé ?*

*Configuration particulière ?*

*Multiple cloud providers ?*

*Homogénéité des outils ?*

### Local Kubernetes

- [Minikube](https://github.com/kubernetes/minikube): Machines virtuelle locale
- [Kind](https://github.com/kubernetes-sigs/kind): Kubernetes in Docker
- [Docker for Mac/Windows](https://docs.docker.com/docker-for-mac/)

### Kubernetes managé

### AWS EKS

![](images/kubernetes/eks_v.png){height="200px"}

- Control plane managé par AWS
- Amazon Linux / Ubuntu
- CloudFormation / [Terraform](https://github.com/terraform-aws-modules/terraform-aws-eks) / [eksctl](https://eksctl.io/)
- Kubernetes v1.14.X

### GKE

![](images/kubernetes/gke.png){height="200px"}

- Control plane managé par GCP
- Premier sur le marché
- COS / Ubuntu
- Terraform / Google Cloud SDK
- Kubernetes v1.15.X

### AZURE AKS

![](images/kubernetes/aks_v.png){height="200px"}

- Control plane managé par Azure
- Kubernetes v1.15.X

### OPENSTACK MAGNUM

![](images/kubernetes/magnum_v.png){height="200px"}

- Control plane managé par OpenStack
- Basé sur OpenStack Heat
- Kubernetes v1.16.X : Stein release
- Proposé sur certains public cloud basés sur OpenStack

### Outils de déploiements spécifiques

### kube-aws

- Pure AWS CloudFormation Stack
- Cycle de release lent
- Facilement personnalisable
- CoreOS ❤
- Kubernetes v1.15.X

### kops

- Déploie sur AWS/GCP/OpenStack et Digital Ocean
- Cycle de release lent
- Facilement personnalisable
- Multiple OS
- Kubernetes v1.15.X
- Supporte Cloudformation and Terraform

### Outils de déploiements agnostiques

### kubeadm

- Outil officiel de la communauté
- Stable depuis v1.13.0
- Ne provisionne pas de machine
- Facilement personnalisabe
- Respect des best practice
- Kubernetes v1.17.X
- Peut être utilisé par d'autres outils

### kubespray

- Basé sur Ansible
- Assez dense et difficile a comprendre
- Multiple OS
- Support Kubeadm
- Kubernetes v1.16.X

### symplegma

- Basé sur Ansible
- Inspiré de Kubespray en plus light
- CoreOS/Ubuntu
- Full Kubeadm
- Kubernetes v1.17.X

