# Travaux Pratiques: Kubernetes - Dashboard


## Installation du dashboard

``` bash
$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
$ # The following will create a serviceaccount with role admin
$ kubectl apply -f https://raw.githubusercontent.com/particuleio/k8s_dashboard_role/main/all.yaml
```

```
kubectl port-forward -n kubernetes-dashboard svc/kubernetes-dashboard --address 0.0.0.0 8443:443
```
Le dashboard est disponible sur ce lien <http://<HOST_IP>:8443/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/>


Lancez cette commande pour récupérer le token d'accès au dashboard:
```
kubectl --namespace kubernetes-dashboard get secrets cluster-admin-token -o=jsonpath="{.data.token}" | base64 -d; echo 
```

