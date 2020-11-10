# Istio: Observabilité

### Observabilité

Istio fournit par défaut un service de télémétrie pour toutes les communication au sein du mesh:

- Métriques applicative: dashboard et compatibilité [prometheus](https://prometheus.io/)
- Traçage applicatif : integration avec les solutions les plus utilisées:
    - [Zipkin](https://istio.io/latest/docs/tasks/observability/distributed-tracing/zipkin/)
    - [Jaeger](https://istio.io/latest/docs/tasks/observability/distributed-tracing/jaeger/)
    - [Lightstep](https://istio.io/latest/docs/tasks/observability/distributed-tracing/lightstep/)
    - [Datadog](https://www.datadoghq.com/blog/monitor-istio-with-datadog/)
- Logs d'accès

### Dashboard

Istio ne fourni pas d'interface graphique par défaut, il est cependant possible de visualiser graphiquement le mesh :

- Avec [Kiali](https://github.com/kiali/kiali)
- Avec [Prometheus et Grafana](https://istio.io/latest/docs/tasks/observability/metrics/using-istio-dashboard/)

### Dashboard: Kiali

![](images/istio/kiali-graph.png){height="500px"}

### Dashboard: Grafana

![](images/istio/istio-service-dashboard.png){height="500px"}

