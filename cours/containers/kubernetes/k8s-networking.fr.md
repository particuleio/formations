# Kubernetes : Networking

### Kubernetes : Network plugins

- Kubernetes n'implémente pas de solution de gestion de réseau par défaut
- Le réseau est implémenté par des solutions tierces :
  - [Calico](https://www.projectcalico.org/) : IPinIP + BGP
  - [Cilium](https://cilium.io/) : eBPF
  - [Weave](https://www.weave.works/) : VXLAN
  - Bien [d'autres](https://kubernetes.io/docs/concepts/cluster-administration/networking/)

### Kubernetes : CNI

- [Container Network Interface](https://github.com/containernetworking/cni)
- Projet dans la CNCF
- Standard pour la gestion du réseau en environnement conteneurisé
- Les solutions précédentes s'appuient sur CNI

### Kubernetes : Services

- Abstraction des pods sous forme d'une IP virtuelle de service
- Rendre un ensemble de pods accessibles depuis l'extérieur ou l'intérieur du
  cluster
- Load Balancing entre les pods d'un même service
- Selection grâce aux labels

### Kubernetes : Services

- `ClusterIP` : IP dans le réseau privé Kubernetes (VIP)
- `NodePort` : chaque noeud du cluster ouvre un port statique et redirige le trafic vers le port indiqué
- `LoadBalancer` :  expose le service en externe en utilisant le loadbalancer d'un cloud provider (AWS, Google, Azure)
    - AWS ELB/ALB/NLB
    - GCP LoadBalancer
    - Azure Balancer
    - OpenStack Octavia

### Kubernetes : Services

![](images/kubernetes/services-1.png){height=500px}

### Kubernetes : Services

- Exemple de service (on remarque la sélection sur le label et le mode d'exposition):

```yaml
apiVersion: v1
kind: Service
metadata:
  name: frontend
spec:
  type: NodePort
  ports:
  - port: 80
  selector:
    app: guestbook
```

### Kubernetes : Services

Il est aussi possible de mapper un service avec un nom de domaine en spécifiant le paramètre `spec.externalName`.

```yaml
kind: Service
apiVersion: v1
metadata:
  name: my-service
  namespace: prod
spec:
  type: ExternalName
  externalName: my.database.example.com
```

### Kubernetes: Ingress

- L'objet `Ingress` permet d'exposer un service à l'extérieur d'un cluster Kubernetes
- Il permet de fournir une URL visible permettant d'accéder un Service Kubernetes
- Il permet d'avoir des terminations TLS, de faire du _Load Balancing_, etc...

### Kubernetes: Ingress

![](images/kubernetes/ingress-1.png){height=500px}

### Kubernetes : Ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: particule
spec:
  rules:
  - host: blog.particule.io
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend
            port:
              number: 80
```

### Kubernetes : Ingress Controller

Pour utiliser un `Ingress`, il faut un Ingress Controller. Un `Ingress` permet
de configurer une règle de reverse proxy sur l'Ingress Controller.

- Nginx Controller : <https://github.com/kubernetes/ingress-nginx>
- Traefik : <https://github.com/containous/traefik>
- Istio : <https://github.com/istio/istio>
- Linkerd : <https://github.com/linkerd/linkerd>
- Contour : <https://www.github.com/heptio/contour/>


