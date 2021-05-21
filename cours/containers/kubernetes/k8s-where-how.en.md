# Kubernetes: Where and how ?

### Bare metal, private and public Clouds

![azure](images/kubernetes/azure_h.png){height="50px"}
![aws](images/kubernetes/aws_h.png){height="50px"}
![gcp](images/kubernetes/gcp_h.png){height="50px"}
![magnum](images/kubernetes/magnum_h.png){height="50px"}

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

### Reference implementation

![](images/kubernetes/infra_ref.png){height="500px"}

### Running Kubernetes

**Hey, I want to use Kubernetes**

*Do you want to run on Cloud infrastructure ?*

*Can you run on public cloud ?*

*Do you need to customize Kubernetes ?*

*Do you want to run on multiple cloud ?*

*Do you want a single deployment tool ?*

### Local Kubernetes

- [Minikube](https://github.com/kubernetes/minikube): local virtual machine
- [Kind](https://github.com/kubernetes-sigs/kind): Kubernetes in Docker
- [k3s](https://github.com/rancher/k3s): Lightweight Kubernetes
- [Docker for Mac/Windows](https://docs.docker.com/docker-for-mac/)

### Managed Kubernetes

### AWS EKS

![](images/kubernetes/eks_v.png){height="200px"}

- Managed Control Plane by AWS
- Quite new
- Amazon Linux / Ubuntu
- CloudFormation / [Terraform](https://github.com/terraform-aws-modules/terraform-aws-eks) / [eksctl](https://eksctl.io/)

### GKE

![](images/kubernetes/gke.png){height="200px"}

- Managed Control Plane by GCP
- First managed Kubernetes
- COS / Ubuntu
- Terraform / Google Cloud SDK

### AZURE AKS

![](images/kubernetes/aks_v.png){height="200px"}

- Managed Control Plane by Azure
- Quite new

### OPENSTACK MAGNUM

![](images/kubernetes/magnum_v.png){height="200px"}

- Managed Control Plane on OpenStack Cloud
- Based on Heat Stacks
- Available on some public Clouds

### Cloud specific deployment tools

### kube-aws

- Pure AWS CloudFormation Stack
- Slow development
- Easily tunable
- Uses CoreOS ❤

### kops

- Deploys AWS/GCP/OpenStack and Digital Ocean
- Heavy development
- Easily tunable
- Multiple OS
- Supports Cloudformation and Terraform

### Infrastructure agnostic deployment tools

### kubeadm

- Official community installer
- Stable since v1.13.0
- Does not take care of bootstrapping machines
- Best practice configuration and tunable
- Multiple OS
- Can be automated and used by other tools

### kubespray

- Based on Ansible
- Quite dense
- Multiple OS
- Kubeadm support

### symplegma

- Based on Ansible
- Inspired by Kubespray but streamlined
- CoreOS but basically agnostic (from source)
- Does not officially take care of infrastructure
- Full Kubeadm

