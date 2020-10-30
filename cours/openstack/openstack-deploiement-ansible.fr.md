# OpenStack : déployer avec Ansible

### Rappels : Ansible

- Déploiement de configuration
- Masterless, agentless
- Tâches, playbooks, rôles, variables (yaml)
- Inventaire
- Collections de modules
- Écrit en Python

### OpenStack-Ansible (OSA)

- Projet officiel OpenStack : <https://opendev.org/openstack/openstack-ansible>
- Déployer et maintenir un cloud OpenStack en production, choix de la release
- Ansible : ensemble de playbooks, de rôles et de scripts (python, bash)
- Support de Debian/Ubuntu, CentOS, openSUSE
- Déploiement à partir des sources (git clone)
- Services déployés dans des conteneurs LXC
- Nécessité de créer des bridges sur les hosts : support LinuxBridge et Open vSwitch
- Déploiement de Ceph via `ceph-ansible` : <https://github.com/ceph/ceph-ansible>

### Principaux composants supportés

- Keystone
- Nova
- Cinder
- Glance
- Neutron
- Octavia
- Swift
- Heat
- Horizon
- Ceilometer, Aodh
- Tempest

### Mise en oeuvre de la haute disponibilité

- HAProxy -> Keepalived
- MySQL -> Galera cluster
- RabbitMQ -> Clustering
- Memcached -> Farming 

### Réseau

- L2 : LinuxBridge ou Open vSwitch
- Routeur virtuel : centralisé ou distribué (DVR)

### Rsyslog centralisé (optionnel)

- Un conteneur `rsyslog`
- Tous les services lui transmettent les logs
- Ce `rsyslog` peut lui même transférer les logs ailleurs

### OSA en multi-régions

- Un déploiement OSA par région
- Un déploiement pour le Keystone central

### OSA workflow

![](images/openstack/osa-workflow.png)

### Machine de déploiement

- Composant principal : `openstack-ansible`
  - Scripts
  - Playbooks
  - Inventaire dynamique

```
$ git clone https://opendev.org/openstack/openstack-ansible /opt/openstack-ansible
$ cd /opt/openstack-ansible
$ git checkout stable/<release>
```

### Récupérer les rôles

- Un rôle par service
- URLs et versions définies dans __`openstack-ansible`/`ansible-role-requirements.yml`__
- `openstack-ansible/scripts/bootstrap-ansible.sh` installe ansible et télécharge les rôles dans __`/etc/ansible/roles`__

### Configurer

- __`/etc/openstack_deploy/`__
  - __`./openstack_user_config.yml`__ -> description de l'infra et des réseaux
  - __`./user_variables.yml`__ -> configuration des services
  - __`./user_secrets.yml`__

### Déployer

Dans __`/opt/openstack-ansible/playbooks`__, avec le wrapper `openstack-ansible` :

- `openstack-ansible setup-hosts.yml` -> création des conteneurs
- `openstack-ansible setup-infrastructure.yml` -> déploiement des services infra
- `openstack-ansible setup-openstack.yml` -> déploiement des services OpenStack
-  enchaînement automatique avec `openstack-ansible setup-everything.yml`

### Mettre à jour

Dans __`/opt/openstack-ansible`__ :

- `git pull`
- `git checkout` de la release cible
- Relancer `scripts/bootstrap-ansible.sh`
- Relancer `playbooks/openstack-ansible setup-everything.yml`

### Sécurité

- Rôle `ansible-hardening` <http://docs.openstack.org/developer/ansible-hardening/>

- Lancée par `setup-hosts.yml`

- Durcissement des hosts

- Implémente les exigences exprimées dans le _Security Technical Implementation Guide_

### openstack-ansible-ops

- Outils pour OSA
- Exemples :
  - Supprimer les anciens *venvs*
  - Restaurer RabbitMQ
  - Simuler des pannes

<https://opendev.org/openstack/openstack-ansible-ops>

