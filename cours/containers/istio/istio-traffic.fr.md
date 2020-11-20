# Istio: Management de trafic

### Management de trafic

Istio intègre son propre service discovery et le peuple avec les endpoints des
services Kubernetes. Istio étend ensuite Kubernetes via des [*Custom Resources
Definitions*](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/)
afin de configurer des règles de routage applicatives :

- *VirtualServices*
- *DestinationRules*
- *Gateway*
- *ServiceEntries*
- *Sidecars*

### Virtual Services

- Fonctionnent de concert avec les *DestinationRules*
- Similaire à un service Kubernetes mais avec des fonctionnalités étendues
- Routage vers des services différents
- Routage vers le même service mais avec des versions différentes
- Routage en fonctions des paramètres de la requête cliente
- Contrôlent comment le trafic est routé **vers** une destination

### Virtual Services

Un des principaux cas d'usage des Virtual Services est la mise en place de
[*Canary Deployment*](https://rollout.io/blog/canary-deployment/) : routage
entre deux versions d'un même service avec un pourcentage différent.

### Virtual Services

Routage entre deux versions d'un même service :

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: reviews
spec:
  hosts:
  - reviews
  http:
  - match:
    - headers:
        end-user:
          exact: jason
    route:
    - destination:
        host: reviews
        subset: v2
  - route:
    - destination:
        host: reviews
        subset: v3
```

### Virtual Services

Routage entre deux versions d'un même service avec pourcentage :

```yaml
spec:
  hosts:
  - reviews
  http:
  - route:
    - destination:
        host: reviews
        subset: v1
      weight: 75
    - destination:
        host: reviews
        subset: v2
      weight: 25
```

### Virtual Services

Routage entre deux services différents :

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: bookinfo
spec:
  hosts:
    - bookinfo.com
  http:
  - match:
    - uri:
        prefix: /reviews
    route:
    - destination:
        host: reviews
  - match:
    - uri:
        prefix: /ratings
    route:
    - destination:
        host: ratings
```

### Destination Rules

- Contrôlent les opérations réalisées sur le trafic pour une destination donnée
- Groupement des services en *subset* pour utilisation avec les *VirtualServices*
- Techniques de répartition de charge :
    - `random`
    - `weight`
    - `least request`

### Destinations Rules

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: my-destination-rule
spec:
  host: my-svc
  trafficPolicy:
    loadBalancer:
      simple: RANDOM
  subsets:
  - name: v1
    labels:
      version: v1
  - name: v2
    labels:
      version: v2
    trafficPolicy:
      loadBalancer:
        simple: ROUND_ROBIN
  - name: v3
    labels:
      version: v3
```

### Gateways

- Contrôlent le trafic entrant et sortant du mesh
- Similaire à des contrôleurs *Ingress* et *Egress*
- Utilisation de l'API *Ingress*  Kubernetes ou *VirtualService* Istio pour plus de contrôle
- *Egress* gateway est plus rarement utilisées et permet de limiter le trafic sortant du mesh

### Gateways

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: ext-host-gwy
spec:
  selector:
    app: my-gateway-controller
  servers:
  - port:
      number: 443
      name: https
      protocol: HTTPS
    hosts:
    - ext-host.example.com
    tls:
      mode: SIMPLE
      serverCertificate: /tmp/tls.crt
      privateKey: /tmp/tls.key
```

### Service Entries

- Permettent d'ajouter des services en dehors du mesh
- Ajouter des machines virtuelles ou physiques au mesh Kubernetes
- Ajouter des services Istio multi clusters

### Service Entries

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  name: svc-entry
spec:
  hosts:
  - ext-svc.example.com
  ports:
  - number: 443
    name: https
    protocol: HTTPS
  location: MESH_EXTERNAL
  resolution: DNS
```

### Sidecars

Par défaut les sidecar disposent de la connaissance et de la possibilité de
joindre tous les services du mesh. Il est possible de limiter les services
joignables par certains sidecars, par exemple dans le cas de larges clusters où
la consommation CPU/RAM des sidecars peut devenir non négligeable.

### Sidecars

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: Sidecar
metadata:
  name: default
  namespace: bookinfo
spec:
  egress:
  - hosts:
    - "./*"
    - "istio-system/*"
```

### Résilience et tests

- Timeouts : temps d'attente avant la réponse d'un service

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: ratings
spec:
  hosts:
  - ratings
  http:
  - route:
    - destination:
        host: ratings
        subset: v1
    timeout: 10s
```

### Résilience et tests

- Retries : permettent de limiter les failures répétitives

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: ratings
spec:
  hosts:
  - ratings
  http:
  - route:
    - destination:
        host: ratings
        subset: v1
    retries:
      attempts: 3
      perTryTimeout: 2s
```

### Résilience et tests

- Circuit Breakers : permettent de limiter le nombre de connexions à un service en fonction de paramètres afin d'éviter une surcharge

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: reviews
spec:
  host: reviews
  subsets:
  - name: v1
    labels:
      version: v1
    trafficPolicy:
      connectionPool:
        tcp:
          maxConnections: 100
```

### Résilience et tests

Fault Injection :

- Tester la résilience d'une application
- Ajout de latence
- Ajout de failure (HTTP error code ou TCP failure)

### Résilience et tests

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: ratings
spec:
  hosts:
  - ratings
  http:
  - fault:
      delay:
        percentage:
          value: 0.1
        fixedDelay: 5s
    route:
    - destination:
        host: ratings
        subset: v1
```


