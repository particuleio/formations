# Kubernetes : Best practices



### Ne pas utiliser latests
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

- `keyverno`

- `Gatekeeper`/`Open Policy Agent`
