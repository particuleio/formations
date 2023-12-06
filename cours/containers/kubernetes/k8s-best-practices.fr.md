# Kubernetes : Best practices



### Ne pas utiliser le tag `latest`
- Parmi les recommendations pour les conteneurs est d'éviter les images
sans tag ou avec le tag `latest`.
- Il est recommandé d'utiliser une version spécifique:
    - on évite les changements de comportement
    - la version `latest` n'est pas la plus stable 


### Spécification des ressources
En cas d'absence des spécifications des ressources, les pods peuvent consommer
autant de mémoire disponible et laisser les autres pod en "famine".


### L'utilisation des policies
- Chaque requête vers l'api de Kubernetes passe par l'`admission controller`.
- Il y a un  mécanisme dans l'`admission controller` qui  permet de valider les requêtes
- Ceci permet de forcer des policies (critères d'acceptation) sur les manifests.


### L'utilisation des policies
Exemples des outils de policies

- `Gatekeeper`/`Open Policy Agent`
- `keyverno`

### Recommendations
- Construire des petits conteneurs:
  - des images de petites bases
  - builder pattern
- Éviter le namespace `default` en production
- Health Check avec `Readiness` et `Liveness`
- `Network Security Policy`
- Hook des conteneurs `PreStop`



