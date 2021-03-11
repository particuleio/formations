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

- Abstraction des Pods sous forme d'une IP virtuelle de Service
- Rendre un ensemble de Pods accessibles depuis l'extérieur ou l'intérieur du
  cluster
- Load Balancing entre les Pods d'un même Service
- Sélection des Pods faisant parti d'un Service grâce aux labels

### Kubernetes : Services

![](images/kubernetes/service.png){height=400px}

### Kubernetes : Services ClusterIP

- Exemple de Service (on remarque la sélection sur le label et le mode d'exposition):

```yaml
apiVersion: v1
kind: Service
metadata:
  name: frontend
spec:
  type: ClusterIP
  ports:
  - port: 80
  selector:
    app: guestbook
```

### Kubernetes : Service NodePort

`NodePort` : chaque noeud du cluster ouvre un port statique et redirige le trafic vers le port indiqué

![](images/kubernetes/nodeport.png){height=400px}

### Kubernetes : Service LoadBalancer

- `LoadBalancer` :  expose le Service en externe en utilisant le loadbalancer d'un cloud provider
    - AWS ELB/ALB/NLB
    - GCP LoadBalancer
    - Azure Balancer
    - OpenStack Octavia

### Kubernetes : Service LoadBalancer

![](images/kubernetes/svc-loadbalancer.png){height=400px}

### Kubernetes : Services

Il est aussi possible de mapper un Service avec un nom de domaine en spécifiant le paramètre `spec.externalName`.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
  namespace: prod
spec:
  type: ExternalName
  externalName: my.database.example.com
```

### Kubernetes: Ingress

- L'objet `Ingress` permet d'exposer un Service à l'extérieur d'un cluster Kubernetes
- Il permet de fournir une URL visible permettant d'accéder un Service Kubernetes
- Il permet d'avoir des terminations TLS, de faire du _Load Balancing_, etc...

### Kubernetes: Ingress

![](images/kubernetes/ingress.png){height=400px}

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


