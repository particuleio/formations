# Kubernetes : Best practices



### Ne pas utiliser latests
- Parmi les recommendations pour les contenenurs est d'éviter les images
sans tag ou avec le tag `latest`.
- Il est recommendé d'utiliser une version spécifque:
    - on évite les changements de comportement
    - la version `latest` n'est pas la plus stable 


### Specification des ressources
En cas d'absence des spécifications des ressources, les pods peuvent consommer
autant de mémoire disponible et laisser les autres pod en "famine".


### L'utilisation des policies
Chaque requête vers l'api de kubernetes passe par l'`admission controller`.
La validation des objets à déployer passe se fait au de l'`admission controller`.
Ceci permet de forcer des policies (critères d'acceptances) sur les manifests.


### L'utilisation des policies
Examples des outils de policies 
- `keyverno`
- `Gatekeeper`/`Open Policy Agent`
