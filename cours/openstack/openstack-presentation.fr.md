# OpenStack : le projet

### Vue haut niveau (1/2)

![Vue haut niveau](images/openstack/openstack-software-diagram.png)

### Vue haut niveau (2/2)

![Vue haut niveau](images/openstack/openstack-user-overview.png){ width=400 height=300 }

### Historique

-   Démarrage du projet en 2010
-   Objectif : le Cloud Operating System libre
-   Fusion de deux projets : Rackspace (Storage) et la NASA (Compute)
-   Logiciel libre distribué sous licence Apache 2.0
-   Naissance de l'*OpenStack Foundation* en 2012, rebaptisée *Open Infrastructure Foundation* en octobre 2020

### Mission

"To produce an ubiquitous Open Source Cloud Computing platform that is
easy to use, simple to implement, interoperable between deployments,
works well at all scales, and meets the needs of users and operators of
both public and private clouds."

### OpenStack en 2021

"OpenStack is one of the top 3 most active open source projects and manages 10 million compute cores."

<https://www.openstack.org/software/>

### Les releases

-   Austin (2010.1)
-   Bexar (2011.1), Cactus (2011.2), Diablo (2011.3)
-   Essex (2012.1), Folsom (2012.2)
-   Grizzly (2013.1), Havana (2013.2)
-   Icehouse (2014.1), Juno (2014.2)
-   Kilo (2015.1), Liberty (2015.2)
-   Mitaka (2016.1), Newton (2016.2)
-   Ocata (2017.1), Pike (2017.2)
-   Queens (2018.1), Rocky (2018.2)
-   Stein (2019.1), Train (2019.2)
-   Ussuri (2020.1), **Victoria** (2020.2)
-   Premier semestre 2021 : Wallaby
-   Second semestre 2021 : Xena

### Sponsors/contributeurs ...

-   Editeurs : Red Hat, Canonical, Mirantis, VMware, ...
-   Constructeurs/puces et serveurs : IBM, Intel
-   Constructeurs/réseau : Cisco, Huawei, ...
-   Constructeurs/stockage : Dell EMC
-   Fournisseurs de services cloud et telco : Rackspace, Vexxhost, OVH, ...
-   Telco : Deutsche Telekom, Tencent, China Mobile, NTT, ATT, ...
-   Google (depuis juillet 2015)

### ... et utilisateurs

-   BBC
-   Banco Santander, Société Générale
-   BMW, Volkswagen AG
-   Cathay Pacific
-   CERN
-   China Railway
-   Ministère de l'Intérieur (France)
-   Walmart
-   Wikimedia
-   et beaucoup d'autres

<https://www.openstack.org/user-stories/>

### Les principaux composants d'OpenStack  (1/3)

-   Identity : Keystone
-   Compute : Nova, Placement
-   Storage : Cinder (block), Swift (object)
-   Networking : Neutron (sdn), Octavia (lbaas), Designate (dns)
-   Image : Glance
-   Dashboard : Horizon
-   Telemetry : Ceilometer
-   Alerting : AODH
-   Orchestration : Heat

<https://www.openstack.org/software/project-navigator/>

### Les principaux composants d'OpenStack (2/3)

Et aussi :

-   Bare metal : Ironic
-   Container : Magnum
-   Message Queue : Zaqar
-   Function : Qinling
-   Database : Trove
-   Data processing : Sahara
-   Shared File System : Manila
-   Key management : Barbican
-   Billing : Cloudkitty
-   ...

### Les principaux composants OpenStack (3/3)

Autres :

-   OpenStack **sdk** (bibliothèque python) et OpenStack **client** (CLI)
-   Les outils de déploiement d'OpenStack (OSA)
-   Les bibliothèques utilisées par OpenStack (Oslo)
-   Les outils utilisés pour développer OpenStack (git, gerrit, zuul,...)

### APIs

-   Chaque composant maintient sa propre API OpenStack
-   Certains composants supportent l'API AWS équivalente (Nova/EC2, Swift/S3)

### Software map

![Software map](images/openstack/openstack-software-map.png)

### La Fondation OpenStack

-   Rebaptisée **Open Infrastructure Foundation** en 2020
-   Entité de gouvernance principale et représentation juridique
-   Les membres du "Board of Directors" sont issus des entreprises sponsors et des membres individuels élus
-   Tout le monde peut devenir membre individuel (gratuit, pas de cotisation)
-   Ressources humaines : marketing, événementiel, release management, quelques développeurs (principalement sur l’infrastructure)
-   710 organisations dans le monde, 110 000 membres, 182 pays
-   Rapport annuel: <https://www.openstack.org/annual-reports/2020-openinfra-foundation-annual-report/>
-   <https://osf.dev>

### Open Infrastructure Foundation

![Les principales entités de la Fondation](images/foundation.png)

### Open Infrastructure

-   En 2018, la Fondation OpenStack s'élargit à l'**Open Infrastructure**

<https://openinfra.dev/about/open-infrastructure/>

"The integration of open alternatives for all the different forms that compute storage
 and networking are taking now and in the future.  The interoperable open source components
 are production ready, scale easily, and businesses can rely on them for real and emerging workloads."

-   Au-delà d'OpenStack, des nouveaux projets sont incubés :
    -   Airship
    -   Kata Containers
    -   StarlingX
    -   Zuul

### Les 4 Opens

-   Open Source
-   Open Design
-   Open Development
-   Open Community

<https://governance.openstack.org/tc/reference/opens.html>
<https://www.openstack.org/four-opens/>

### Ressources (1/3)

-   Membres et contributeurs :
    - <https://www.openstack.org/community/>
-   Annonces (nouvelles versions, avis de sécurité) :
    - <openstack-announce@lists.openstack.org>
-   Documentation : <https://docs.openstack.org/>
-   API/SDK : <https://developer.openstack.org/>
-   Bug report : <https://bugs.launchpad.net/openstack>
-   Gouvernance : <https://governance.openstack.org/>
-   Versions : <https://releases.openstack.org/>

### Ressources (2/3)
-   Support :
    -   <https://stackoverflow.com/questions/tagged/openstack>
    -   <https://serverfault.com/tags/openstack/info>
    -   openstack-discuss@lists.openstack.org
    -   \#openstack@Freenode

-   Actualités :
    -   Blog officiel : <https://www.openstack.org/blog/>
    -   Planet : <http://planet.openstack.org/>
    -   Expériences utilisateurs : <http://superuser.openstack.org/>

### Ressources (3/3)

-   Ressources commerciales :
    - <https://www.openstack.org/marketplace/>

-   Job board :
    - <https://www.openstack.org/community/jobs/>

### User Survey

-   Enquête réalisée chaque année par la Fondation
-   Auprès des déployeurs et utilisateurs
-   Résultats publiés :
    - <https://www.openstack.org/analytics>

### Certification :  Certified OpenStack Administrator (COA)

-   Seule certification OpenStack existante
-   Validée par la Fondation OpenStack
-   Contenu :
    -   Essentiellement orienté *utilisateur*
    -   Pré-requis : <https://www.openstack.org/coa/requirements/>
-   Modalités :
    -   Examen pratique (hands on), à distance, durée 3 heures maxi
    -   Coût : USD 400
    -   Inscription : <https://www.openstack.org/coa/>
-   Ressources :
    -   Handbook : <https://www.openstack.org/coa/handbook/>

### Communauté francophone et association

![Logo OpenStack-fr](images/openstackfr.png){height=50px}

-   <https://openstack.fr> - <https://asso.openstack.fr>
-   Meetups : Paris, Lyon, Toulouse, Montréal, etc.
-   Présence à des événements tels que *Paris Open Source Summit*
-   Canaux de communication :
    -   openstack-fr@lists.openstack.org
    -   \#openstack-fr@Freenode

