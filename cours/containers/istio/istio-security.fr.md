# Istio : Sécurité

### Sécurité

Istio fournit des composants pour :

- Se défendre contre les attaques *man in the middle* : chiffrement
- Mettre en place des politiques d'accès par authentification et autorisation
- Disposer d'un audit des flux au sein du mesh

### Sécurité

Ces fonctionnalités sont principalement mises en place grâce au
[mTLS](https://en.wikipedia.org/wiki/Mutual_authentication): mutual TLS entre
les différents services.

### Sécurité

- Le plan de contrôle `istiod` gère la création et distribution des certificats TLS aux différents composants
- Les proxys `Envoy` reçoivent les certificats et mettent en place les politiques de sécurité définies dans le plan de contrôle :
    - Authentification
    - Autorisation

### Sécurité

![](images/istio/arch-sec.svg){height="400px"}

### Sécurité

![](images/istio/id-prov.svg){height="400px"}

### Sécurité : authentification

Istio fourni 2 méthodes d'authentification :

- Service to Service: via mTLS
- End User: via des fournisseur d'identités compatibles avec [OpenID connect](https://openid.net/connect/):
    - Keycloak
    - Auth0
    - Firebase
    - Google Auth
    - ORY Hydra

### Sécurité : mTLS

Le chiffrement du trafic ainsi que l'authentification est réalisé via mTLS. Il
existe 3 modes:

- PERMISSIVE : accepte du trafic en clair ainsi qu'en mTLS, recommandé lorsque tous les services ne sont pas encore migrés en mTLS
- STRICT: mTLS uniquement
- DISABLE: mTLS est désactivé

### Sécurité : mTLS

L'authentification est réalisée grâce à des *Authentication Policy* :

![](images/istio/authn.svg){height="400px"}

### Sécurité : Authentication Policy

Permettent de définir l'usage ou non de mTLS des services spécifiques :

```yaml
apiVersion: "security.istio.io/v1beta1"
kind: "PeerAuthentication"
metadata:
  name: "example-peer-policy"
  namespace: "foo"
spec:
  selector:
    matchLabels:
      app: reviews
  mtls:
    mode: STRICT
```

### Sécurité : Authentication Policy

S'appliquent:

- Au niveau du cluster/mesh global: non namespacées
- Au sein d'un namespace: namespacées
- Au sein d'un namespace: namespacées + selector :

```yaml
selector:
  matchLabels:
    app: product-page
```

### Sécurité : Autorisation

En plus de l'authentification, Istio fournit une couche d'autorisation qui permet de définir des règles de sécurité applicatives

![](images/istio/authn.svg){height="400px"}

### Sécurité : Authorization policies

- Fonctionnent avec les protocoles HTTP, HTTPS, HTTP2, GRPC et TCP
- ALLOW and DENY
- Sont scopées de la même façon que les *Authentication Policy*

### Sécurité : Authorization policies

```yaml
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
 name: httpbin
 namespace: foo
spec:
 selector:
   matchLabels:
     app: httpbin
     version: v1
 action: ALLOW
 rules:
 - from:
   - source:
       principals: ["cluster.local/ns/default/sa/sleep"]
   - source:
       namespaces: ["dev"]
   to:
   - operation:
       methods: ["GET"]
   when:
   - key: request.auth.claims[iss]
     values: ["https://accounts.google.com"]
```

### Sécurité : Remarques

- Comme pour les *NetworkPolicy*, par défaut aucune politique n'est activée
- Possibilité d'appliquer des règles globales au service mesh tel qu'un `deny-all` pour sécuriser par défaut
- Les *Authorization policies* sont équivalentes à des pare feu applicatifs et peuvent s'overlapper avec la solution de CNI utilisée
- Possibilité d'intégration avec certains CNI: [Calico et Istio](https://docs.projectcalico.org/security/tutorials/app-layer-policy/enforce-policy-istio)


