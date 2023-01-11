# Les conteneurs

### Définition

- Les conteneurs fournissent un environnement isolé sur un système hôte, semblable à un chroot sous Linux ou une jail sous BSD, mais en proposant plus de fonctionnalités en matière d'isolation et de configuration. Ces fonctionnalités sont dépendantes du système hôte et notamment du kernel.

### Le Kernel Linux

- Namespaces

- Cgroups (control groups)

![](images/docker/kernel.png){height="100px"}

### Les namespaces

### Mount namespaces ( Linux 2.4.19)

- Permet de créer un arbre des points de montage indépendants de celui du système hôte.

### UTS namespaces (Linux 2.6.19)

- Unix Time Sharing : Permet à un conteneur de disposer de son propre nom de domaine et d’identité NIS sur laquelle certains protocoles tel que LDAP peuvent se baser.

### IPC namespaces (Linux 2.6.19)

- Inter Process Communication : Permet d’isoler les bus de communication entre les processus d’un conteneur.

### PID namespaces (Linux 2.6.24)

- Isole l’arbre d’exécution des processus et permet donc à chaque conteneur de disposer de son propre processus maître (PID 0) qui pourra ensuite exécuter et manager d'autres processus avec des droits illimités tout en étant un processus restreint au sein du système hôte.

### User namespaces (Linux 2.6.23-3.8)

- Permet l’isolation  des utilisateurs et des groupes au sein d’un conteneur. Cela permet notamment de gérer des utilisateurs tels que l’UID 0 et GID 0, le root qui aurait des permissions absolues au sein d’un namespace mais pas au sein du système hôte.

### Network namespaces (Linux 2.6.29)

- Permet l’isolation des ressources associées au réseau, chaque namespace dispose de ses propres cartes réseaux, plan IP, table de routage, etc.

### Cgroups : Control Croups

```bash
CGroup: /
           |--docker
           |  |--7a977a50f48f2970b6ede780d687e72c0416d9ab6e0b02030698c1633fdde956
           |  |--6807 nginx: master process ngin
           |  |  |--6847 nginx: worker proces
```

### Cgroups : Limitation de ressources

- Limitation des ressources : des groupes peuvent être mis en place afin de ne pas dépasser une limite de mémoire.

### Cgroups : Priorisation

- Priorisation : certains groupes peuvent obtenir une plus grande part de ressources processeur ou de bande passante d'entrée-sortie.

### Cgroups : Comptabilité

- Comptabilité : permet de mesurer la quantité de ressources consommées par certains systèmes, en vue de leur facturation par exemple.

### Cgroups : Isolation

- Isolation : séparation par espace de nommage pour les groupes, afin qu'ils ne puissent pas voir les processus des autres, leurs connexions réseaux ou leurs fichiers.

### Cgroups : Contrôle

- Contrôle : figer les groupes ou créer un point de sauvegarde et redémarrer.

### Encore plus “cloud” qu’une instance

- Partage du kernel

- Un seul processus par conteneur

- Le conteneur est encore plus éphémère que l’instance

- Le turnover des conteneurs est élevé : orchestration

### Container runtime

Permettent d'exécuter des conteneurs sur un système

- docker: container engine - historique

- containerd: implémentation de référence

- podman: container engine - dans les systèmes RHEL 

- runc: lightweight container runtime

- cri-o: implémentation Open Source développée par RedHat

- ...


### Les conteneurs: conclusion
- Fonctionnalités offertes par le Kernel
- Les conteneurs engine fournissent des interfaces d'abstraction
- Plusieurs types de runtimes






