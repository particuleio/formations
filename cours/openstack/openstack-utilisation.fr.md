# OpenStack : utilisation

## Généralités

### Principes

- Toutes les fonctionnalités sont accessibles par l’**API**
- Les clients (y compris le dashboard Horizon) utilisent l’API
- Des **identifiants** sont nécessaires :
  - utilisateur
  - mot de passe
  - projet (aka tenant)
  - domaine

### Les APIs OpenStack

- Une API par service OpenStack :
  - Versionnée, la rétro-compatibilité est assurée
  - Le corps des requêtes et réponses est formatté avec JSON
  - Architecture REST
- Les ressources gérées sont spécifiques à un projet

```Un cloud OpenStack déployé dans les règles de l'art fournit des APIs hautement disponibles.```

(La haute-disponibilité des instances est un autre sujet)

<https://developer.openstack.org/#api>

### Accès aux APIs

- Direct, en HTTP, via des outils comme *curl*
- En mode programmatique, avec une bibliothèque :
  - OpenStackSDK
  - D’autres implémentations, y compris pour d’autres langages (gophercloud, jclouds,...)
- Avec le CLI officiel
- Avec le dashboard Horizon (WUI)
- Avec des outils tiers de plus haut niveau tels que *Terraform*

### Clients officiels

- OpenStack fournit des clients officiels
  - Historiquement : `python-PROJETclient` (bibliothèque Python et CLI)
  - Aujourd'hui : `openstackclient` (CLI)
- CLI
  - L’authentification se fait en passant les identifiants par paramètres, variables d’environnement ou fichier de configuration (yaml)
  - L’option `--debug` affiche les requêtes et les réponses

### OpenStack Client

- CLI unifié
- Commandes du type `openstack <ressource> <action>` (mode interactif disponible)
  `openstack server list`
- Vise à remplacer les clients CLI spécifiques
- Permet une expérience utilisateur plus homogène
- Fichier de configuration `clouds.yaml`

<https://docs.openstack.org/python-openstackclient/latest/configuration/index.html#configuration-files>

## Keystone : identité et catalogue de services

### Principes

![](images/openstack/mascot-keystone.png){ width=75 height=37 }

Keystone est responsable de l'authentification, des autorisations et du catalogue de services.

- L'utilisateur standard s'authentifie auprès de Keystone
- L'administrateur intéragit régulièrement avec Keystone (pour gérer les projets, utilisateurs, autorisations,...)

### APIs

- API keystone v3 --> port 5000
- Gère :
  - **Domaines**
  - **Projets**
  - **Utilisateurs**, **groupes**
  - **Rôles** (lien entre utilisateur et projet)
  - **Services** et **endpoints** (catalogue de services)
- Fournit :
  - **Tokens** d'authentification

### Catalogue de services

- Pour chaque service, plusieurs **endpoints** (URLs) sont possibles en fonction de :
  - la **région**
  - le type d'interface (public, internal, admin)

### Scénario d’utilisation typique

![Interactions avec Keystone](images/keystone-scenario.png){ width=400 height=265 }

## Nova : Compute

### Principes

![](images/openstack/mascot-nova.png){ width=75 height=37 }

- Gère principalement les **instances**
- Les instances sont créées à partir des **images** fournies par Glance
- Les interfaces réseau des instances sont connectées à des **ports** Neutron
- Du stockage **block** peut être fourni aux instances par Cinder

### Propriétés d’une instance

- Éphémère, a priori non hautement disponible
- Définie par une **flavor**
- Construite à partir d’une **image**
- Optionnel : attachement de **volumes**
- Optionnel : boot depuis un volume
- Optionnel : une **clé** SSH publique
- Optionnel : des ports réseaux

### API

Ressources gérées :

- **Instances**
- **Flavors** : vcpu, ram, disque de boot
- **Keypairs** (clés ssh) : ressource propre à l'utilisateur (et non au projet)

### Actions sur les instances

- Reboot / shutdown
- Snapshot
- Resize
- Migration (admin)
- Deletion
- Lecture des logs
- Accès console

### Affinity/anti-affinity

- Demander à Nova de démarrer 2 ou plus instances :
  - le plus proche possible (affinity)
  - le plus éloigné possible (anti-affinity)
- Besoin de performances ou besoin de distribution/résistance aux pannes

### Service metadata

- API pour les instances
- Pour obtenir la clé publique, l'adresse IP, les user data,...
- URL spécifique : `curl http://169.254.169.254/openstack

## Cinder : Stockage block

### Principes

![](images/openstack/mascot-cinder.png){ width=75 height=37 }

- Fournit des **volumes** (stockage block) attachables aux instances (/dev)
- Gère différents types de volume
- Gère snapshots et backups de volumes

### Utilisation

- Volume supplémentaire (et stockage persistant) sur une instance
- Boot from volume : l’OS est sur le volume
- Fonctionnalité de backup vers un object store (Swift ou Ceph)

## Glance : registre d'images

### Principes

![](images/openstack/mascot-glance.png){ width=75 height=37 }

- Registre d'**images** et de snapshots
- Propriétés sur les images

### API

- API v2 : version courante, gère images et snapshots d'instances

### Types d’images

Glance supporte un large éventail de types d’images, limité par le support de la technologie sous-jacente à Nova :

- raw
- qcow2
- ami
- vmdk
- iso

### Propriétés des images dans Glance

L’utilisateur peut définir un certain nombre de propriétés dont certaines seront utilisées lors de l’instanciation :

- Type d’image
- Architecture
- Distribution
- Version de la distribution
- Espace disque minimum
- RAM minimum

### Visibilité et partage des images

- Image publique : accessible à tous les projets
  - Par défaut, seul l'administrateur peut rendre une image publique
- Image privée : accessible uniquement au projet auquel elle appartient
- Image partagée : accessible à un ou plusieurs autre(s) projet(s)

### Images cloud

Une image cloud c’est :

- Une image disque contenant un OS déjà installé
- Un OS sachant parler à l’API de metadata du cloud (avec `cloud-init`)
- Détails : <https://docs.openstack.org/image-guide/openstack-images.html>

La plupart des distributions Linux fournissent des images régulièrement mises à jour :

- Ubuntu : <https://cloud-images.ubuntu.com/>
- Debian : <https://cdimage.debian.org/cdimage/openstack/>
- CentOS : <https://cloud.centos.org/centos/>

### Cloud-init

- **Cloud-init** est un moyen de tirer parti de l’API de metadata, et notamment des user data
- Intégré par défaut dans la plupart des images cloud
- À partir des **user data**, cloud-init effectue les opérations de personnalisation de l’instance
- **cloud-config** est un format possible de user data

Exemple `cloud-config` :

```bash
#cloud-config
mounts:
 - [ vda2, /var/www ]
packages:
 - apache2
package_update: true
```

## Neutron : réseau

### API

![](images/openstack/mascot-neutron.png){ width=75 height=37 }

L’API permet notamment de manipuler les ressources :

- **Réseau** : niveau 2
- **Sous-réseau** : niveau 3
- **Port** : attachable à une interface sur une instance, un load-balancer, etc.
- **Routeur**
- **IP flottante**
- **Groupe de sécurité**

### Les IP flottantes

- Permettent d'exposer une instance au réseau externe
- En plus des **fixed IPs** portées par les instances
- Non portées directement par les instances
- **Allocation** (réservation par le projet) d'une IP depuis un **pool**
- **Association** à un port d'une IP allouée

### Les groupes de sécurité

- Équivalents à un pare-feu devant chaque instance
- Une instance peut être associée à un ou plusieurs groupes de sécurité
- Gestion des accès en entrée (ingress) et sortie (egress)
- Règles de filtrage par protocole (TCP/UDP/ICMP) et par port
- La source d'une règle est soit une adresse IP, un réseau ou un autre groupe de sécurité

### Fonctionnalités supplémentaires

Outre les fonctions réseau de base niveaux 2 et 3, Neutron peut fournir d’autres services :

- VPN : permet d’accéder à un réseau privé sans IP flottantes
- QoS : règles de gestion de la bande passante

## Octavia : load balancer

### Principes

![](images/openstack/mascot-octavia.png){ width=75 height=37 }

- Fournit des fonctionnalités de load balancing aux projets
- Load balancing implémenté par des instances spécifiques, les **amphores**
- Gestion de la haute-disponibilité des load balancers eux-mêmes
- Agnostique des technologies sous-jacentes
- Basé par défaut sur HAProxy

### Composants : vue aérienne

![Composants Octavia](images/openstack/octavia-component-overview.png){ width=500 height=300 }

### API

Version courante : V2

L'API Octavia permet de gérer les ressources suivantes :

- **Load balancer**
- **Listener**
- **Pool**
- **Member**
- **Health monitor**
- **Rules**
- **Policies**

## Heat : Orchestration

### Généralités

![](images/openstack/mascot-heat.png){ width=75 height=37 }

- Heat est la solution native OpenStack du service d'orchestration
- Il permet de décrire, dans des templates YAML, des ensembles cohérents de ressources virtuelles
- Heat fournit une API de manipulation de **stacks** à partir de **templates**
- Un template Heat suit le format HOT (*Heat Orchestration Template*)
- Il est possible de générer des templates interactivement avec le dashboard Horizon

### Exemple de template
```yaml
heat_template_version: 2018-08-31
description: Simple template to deploy a single compute instance
parameters:
  instance_name:
    type: string
    label: Instance Name
    default: my_instance
  subnet_id:
     type: string
resources:
  instance:
    type: OS::Nova::Server
    properties:
      name: { get_param: instance_name }
      image: cirros
      flavor: m1.small
      networks:
        - port: { get_resource: instance_port }
  instance_port:
    type: OS::Neutron::Port
    properties:
      network_id: { get_param: subnet_id }
      fixed_ips:
        - subnet_id: { get_param: subnet_id }
outputs:
  fixed_ip: { get_attr: [ instance, first_address ] 
```

## Horizon : Dashboard web

### Principes

![](images/openstack/mascot-horizon.png){ width=75 height=37 }

- Fournit une interface web (WUI) à l'utilisateur et à l'administrateur OpenStack
- S'appuie sur les services déployés pour déterminer les fonctionnalités offertes dans le WUI
- Log in sans préciser un projet : Horizon détermine la liste des projets accessibles

### Utilisation

- Fonctionne bien avec Firefox et Chrome
- Echanges HTTPS
- Authentification de type username/password
- Notion de projet courant, possibilité de basculer d'un projet à l'autre
- Une zone “admin” restreinte
- Support multilingue

