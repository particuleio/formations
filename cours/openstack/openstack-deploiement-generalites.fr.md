# OpenStack : généralités sur le déploiement

### Architecture simplifiée et principaux composants

![](images/openstack/openstack-archi-main-components.png)

### Quelques éléments de configuration généraux

- Il s'agit de fournir un catalogue de services (APIs) hautement disponibles
- Tous les composants doivent être configurés pour communiquer avec Keystone
- La plupart doivent être configurés pour communiquer avec MariaDB et RabbitMQ
- Les composants découpés en plusieurs services ont parfois un fichier de configuration par service
- Le fichier de configuration `policy.json` précise les droits nécessaires pour chaque appel API

### Infrastructure physique

OpenStack nodes :

- Controller (control plane, APIs, haute disponibilité)
- Compute (hyperviseur)
- Storage (bloc et objet)
- Network (optionnels)

Management nodes :

- Deploiement
- Logs
- Backup

### Système d’exploitation

- OS Linux avec Python
- Ubuntu
- Red Hat
- SUSE
- Debian, Fedora, CentOS, etc.

### Python

![Logo Python](images/python-powered.png){ height=50s }

- OpenStack est compatible Python 3
- Rupture avec Python 2.7 depuis release Ussuri (2020.1)
- Afin de ne pas réinventer la roue, beaucoup de dépendances sont nécessaires

### Services d'infrastructure

- Base de données : MariaDB
- Cache : Memcached
- File de messages : AMQP (RabbitMQ)
- Load balancing : HAProxy et keepalived

### Core services

- Identity : Keystone
- Compute : Nova
- Network : Neutron
- Image : Glance
- Stockage : Cinder

### Dashboard : Horizon

- Horizon est un module Django
- Déployé en mode HA sur les controlleurs

