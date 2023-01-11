# Les conteneurs : Introduction


### Déploiement des applications

- Cycle de vie d'une application
- Plusieurs environnements:
    - local
    - test
    - production

### Déploiement des applications

- Chaque environnement est différent des autres:
    - système d'exploitation
    - dépendances
    - configuration
    - réseau
    - ...
- Des prérequis
- Conflit éternel entre les devs et les ops: "ça fonctionnait en local !"

### Ère de la virtualisation !

- Environnement isolé => plus de sécurité
- Création de plusieurs VMs sur la même machine
- Snapshot des VMs
    - Portabilité
    - Dupliquer les VMs
    - S'assurer d'avoir le même comportement n'importe où
- Problème des dépendances/prérequis

### Problèmes des VMs

- Les VMs sont lourdes
    - Un système d'exploitation !
    - La taille d'une VMs est de l'ordre des Go
    - Difficulté de partage des VMs
    - L'arrêt/relance des VMs prend beaucoup de temps
    - Le processus de création d'une VM est long

### Problèmes des VMs

- Couche d'hyperviseur et allocation des ressources
- L'application et toutes les dépendances sont installées dans une VM
    - Pas de séparation des services
    - Conflit des dépendances des services

### Les conteneurs !

- Sont légers de l'ordre des Mo
- Se connectent directement au kernel du système
- Se lancent rapidement
- Facile à partager
- Single purpose

### VM Vs Conteneurs

![](./images/virtual-machines-vs-containers.png)
<!-- source: https://dzone.com/articles/container-technologies-overview -->

