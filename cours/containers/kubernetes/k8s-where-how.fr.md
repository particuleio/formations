# Kubernetes: où deployer et comment ?

### Bare metal, private et public Clouds

![azure](images/kubernetes/azure_h.png){height="50px"}
![aws](images/kubernetes/aws_h.png){height="50px"}
![gcp](images/kubernetes/gcp_h.png){height="50px"}
![magnum](images/kubernetes/magnum_h.png){height="50px"}

Managed - Kops - Kubespray - Kubeadm - Kube-aws - Symplegma - RKE - K3S - openshift
▼

Cluster Deployment

Cluster Lifecycle

### Infrastucture as code

IaC : Infrastructure as Code

▼

Terraform - CloudFormation - Cloud Deployment Manager - OpenStack Heat - Azure Resource Manager

▼

Infrastructure déclarée

Infrastructure immuable

### Implémentation de référence

![](images/kubernetes/infra_ref.png){height="500px"}

### Que choisir ?

**Je veux utiliser Kubernetes**

*Cloud ?*

*Cloud public ou privé ?*

*Configuration particulière ?*

*Multiple cloud providers ?*

*Homogénéité des outils ?*

### Local Kubernetes

- [Minikube](https://github.com/kubernetes/minikube): Machine virtuelle locale
- [Kind](https://github.com/kubernetes-sigs/kind): Kubernetes in Docker
- [k3s](http://github.com/rancher/k3s): Kubernetes léger
- [Docker for Mac/Windows](https://docs.docker.com/docker-for-mac/)

### Kubernetes managé

### AWS EKS

![](images/kubernetes/eks_v.png){height="200px"}

- Control plane managé par AWS
- Amazon Linux / Ubuntu
- CloudFormation / [Terraform](https://github.com/terraform-aws-modules/terraform-aws-eks) / [eksctl](https://eksctl.io/)

### GKE

![](images/kubernetes/gke.png){height="200px"}

- Control plane managé par GCP
- Premier sur le marché
- COS / Ubuntu
- Terraform / Google Cloud SDK

### AZURE AKS

![](images/kubernetes/aks_v.png){height="200px"}

- Control plane managé par Azure

### OPENSTACK MAGNUM

![](images/kubernetes/magnum_v.png){height="200px"}

- Control plane managé par OpenStack
- Basé sur OpenStack Heat
- Proposé sur certains public cloud basés sur OpenStack

### Outils de déploiements agnostiques

### kubeadm

- Outil **officiel** de la communauté
- Stable depuis v1.13.0
- Ne provisionne pas de machine
- Facilement personnalisable
- Respect des best practices
- Peut-être utilisé par d'autres outils

### kubespray

- Basé sur Ansible
- Dense, permet d'installer un nombre important de plugins
- Multiples OS
- Support Kubeadm

### symplegma

- Basé sur Ansible
- Inspiré de Kubespray en plus léger
- CoreOS/Ubuntu
- Full Kubeadm

### Outils de déploiements spécifiques

### kube-aws

- Pure AWS CloudFormation Stack
- Cycle de release lent
- Facilement personnalisable
- CoreOS ❤

### kops

- Déploie sur AWS/GCP/OpenStack et Digital Ocean
- Cycle de release lent
- Facilement personnalisable
- Multiples OS
- Supporte Cloudformation and Terraform

### Openshift
- Distribution de Kubernetes de RedHat
- Pour les entreprises
  - sécurité
  - séparation des rôles
- Dashboard pour gérer la distribution Kubernetes

### RKE
- Facile à utiliser
- Offert par Rancher
- Configuration des clusters avec YAML

### Légers Kubernetes clusters
- exemples:
  - [k3s](https://k3s.io/)
  - [k0s](https://k0sproject.io/)
- Distributions Kubernetes minimalistes
- Support de l'architecture ARM pour les cartes électroniques d'IOT

