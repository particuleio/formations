# Kubernetes: Where and how ?

### Bare metal, private and public Clouds

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

### Reference implementation

![](images/kubernetes/infra_ref.png){height="500px"}

### Running Kubernetes

*Hey, I want to use Kubernetes*

*Do you want to run on Cloud infrastructure ?*

*Can you run on public cloud ?*

*Do you need to customize Kubernetes ?*

*Do you want to run on multiple cloud ?*

*Do you want a single deployment tool ?*

### Local Kubernetes

- [Minikube](https://github.com/kubernetes/minikube): local virtual machine
- [Kind](https://github.com/kubernetes-sigs/kind): Kubernetes in Docker
- [Docker for Mac/Windows](https://docs.docker.com/docker-for-mac/)

### Managed Kubernetes

### AWS EKS

![](images/kubernetes/eks_v.png){height="200px"}

- Managed Control Plane by AWS
- Quite new
- Amazon Linux / Ubuntu
- CloudFormation / [Terraform](https://github.com/terraform-aws-modules/terraform-aws-eks) / [eksctl](https://eksctl.io/)
- Kubernetes v1.14.X

### GKE

![](images/kubernetes/gke.png){height="200px"}

- Managed Control Plane by GCP
- First managed Kubernetes
- COS / Ubuntu
- Terraform / Google Cloud SDK
- Kubernetes v1.15.X

### AZURE AKS

![](images/kubernetes/aks_v.png){height="200px"}

- Managed Control Plane by Azure
- Quite new
- Kubernetes v1.15.X

### OPENSTACK MAGNUM

![](images/kubernetes/magnum_v.png){height="200px"}

- Managed Control Plane on OpenStack Cloud
- Based on Heat Stacks
- Kubernetes v1.16.X on Stein release
- Available on some public Clouds

### Cloud specific deployment tools

### kube-aws

- Pure AWS CloudFormation Stack
- Sloe development
- Easily tunable
- Uses CoreOS ❤
- Kubernetes v1.15.X

### kops

- Deploys AWS/GCP/OpenStack and Digital Ocean
- Heavy development
- Easily tunable
- Multiple OS
- Kubernetes v1.15.X
- Supports Cloudformation and Terraform

### Infrastructure agnostic deployment tools

### kubeadm

- Official community installer
- Stable since v1.13.0
- Does not take care of bootstrapping machines
- Best practice configuration and tunable
- Multiple OS
- Kubernetes v1.17.X
- Can be automated and used by other tools

### kubespray

- Based on Ansible
- Quite dense
- A bit hard to understand
- Multiple OS
- Does not officially take care of infrastructure
- Kubeadm support
- Kubernetes v1.16.X

### symplegma

- Based on Ansible
- Inspired by Kubespray but streamlined
- CoreOS but basically agnostic (from source)
- Does not officially take care of infrastructure
- Full Kubeadm
- Kubernetes v1.17.X

