# Kubernetes: scheduling

### Affinité / Anti-affinité

2 types de règles:

- Affinité de nodes
- Affinité / Anti-affinité de pod

### Affinité de nodes

- Permets de scheduler des workloads sur un nœud en particulier
- Paramétrable en fonction de labels

### Affinité de nodes

```yaml
pods/pod-with-node-affinity.yaml

apiVersion: v1
kind: Pod
metadata:
  name: with-node-affinity
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: kubernetes.io/e2e-az-name
            operator: In
            values:
            - e2e-az1
            - e2e-az2
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 1
        preference:
          matchExpressions:
          - key: another-node-label-key
            operator: In
            values:
            - another-node-label-value
  containers:
  - name: with-node-affinity
    image: k8s.gcr.io/pause:2.0
```

### Affinité / Anti-affinité

- Permet de scheduler des pods en fonction des labels
- Sur un même nœud (collocation)
- Sur des nœud différents

### Affinité / Anti-affinité

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: with-pod-affinity
spec:
  affinity:
    podAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: security
            operator: In
            values:
            - S1
        topologyKey: failure-domain.beta.kubernetes.io/zone
    podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchExpressions:
            - key: security
              operator: In
              values:
              - S2
          topologyKey: failure-domain.beta.kubernetes.io/zone
  containers:
  - name: with-pod-affinity
    image: k8s.gcr.io/pause:2.0
```

### Taints et Tolerations

- Une teinte permet l'inverse d'une affinité
- Permet à un nœud de refuser des pods
- Utilise pour dédier des nœud à un certain usage

```bash
kubectl taint nodes node1 key=value:NoSchedule
```

### Taints and Tolerations

Aucun pod ne pourra être schedulé sur ce nœud a moins de *tolérer* la teinte:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    env: test
spec:
  containers:
  - name: nginx
    image: nginx
    imagePullPolicy: IfNotPresent
  tolerations:
  - key: "key"
    operator: "Exists"
    effect: "NoSchedule"
```

