# Supports de formation Particule

[![Build Status](https://travis-ci.com/particuleio/formations.svg?branch=master)](https://travis-ci.com/particuleio/formations)

Supports de formation (sous forme de slides) écrits en Français et traduits en Anglais et réalisés originellement par les employés d'[alter way Cloud Consulting](https://cloud-consulting.alterway.fr/) (ex Osones) et repris depuis 2020 par [Particule](https://particule.io) pour ses offres de [formation](https://particule.io/trainings).

Sont notamment abordés les sujets suivants : le cloud, sa philosophie, le projet Kubernetes, l'administration et l'utilisation de Kubernetes, le principe des conteneurs, l'utilisation de Docker, le projet OpenStack, l'utilisation d'OpenStack, le déploiement d'OpenStack.

Sources : <https://github.com/particuleio/formations/>

Auteurs originaux :

* Adrien Cunin <adrien@adriencunin.fr>
* Pierre Freund <pierre.freund@gmail.com>
* Romain Guichard <romain@particule.io>
* Kevin Lefevre <kevin@particule.io>
* Jean-François Taltavull <jftalta@gmail.com>

HTML et PDF construits automatiquement : <https://particule.io/formations/>

* Kubernetes [PDF](https://particule.io/formations/pdf/kubernetes-ube.fr.pdf)/[HTML](https://particule.io/formations/kubernetes-ube.fr.html)
* Conteneurs [PDF](https://particule.io/formations/pdf/conteneurs-ccb.fr.pdf)/[HTML](https://particule.io/formations/conteners-ccb.fr.html)
* Cloud [PDF](https://particule.io/formations/pdf/cloud.fr.pdf)/[HTML](https://particule.io/formations/cloud.fr.html)
* Docker [PDF](https://particule.io/formations/pdf/docker.fr.pdf)/[HTML](https://particule.io/formations/docker.fr.html)
* OpenStack User [PDF](https://particule.io/formations/pdf/openstack-user.fr.pdf)/[HTML](https://particule.io/formations/openstack-user.fr.html)
* OpenStack Ops [PDF](https://particule.io/formations/pdf/openstack-ops.fr.pdf)/[HTML](https://particule.io/formations/openstack-ops.fr.html)

## Prérequis


### Option 1 : Utiliser le script build.sh

* Docker : <https://docs.docker.com/install>
* jq : <https://github.com/stedolan/jq>

### Option 2 : Utiliser le Makefile

* make : <https://www.gnu.org/software/make/>
* jq : <https://github.com/stedolan/jq>
* pandoc : <https://pandoc.org>
* TeX Live : <https://www.tug.org/texlive/>

## Fonctionnement

Les supports de formation (slides) sont écrits en Markdown. Chaque fichier dans `cours/` est un module indépendant.

`cours.json` définit les cours à partir des modules et des TP.

```
{
  "kubernetes": {
    "course_name": "kubernetes",
    "course_description": "Formation Kubernetes",
    "modules": [
      "kubernetes-intro",
      "kubernetes-architecture",
      "kubernetes-usage",
      "kubernetes-conclusion"
    ],
    "tp": [
      "k8s-install",
      "k8s-scheduling",
      "k8s-secrets"
    ]
  }
}
```

Il est possible de générer ces slides sous différents formats :

1. HTML (`reveal.js` pour les cours, `grip` pour les TP)
2. PDF à partir du HTML
3. PDF à partir de LaTeX / Beamer

Deux méthodes de build sont disponibles :

* build.sh : supporte 1. et 2.
* Makefile : supporte 1. et 3.

### Build.sh

Le build utilise des conteneurs Docker.
L'utilisation de conteneurs Docker ne vise qu'à fournir un environnement stable (version des paquets fixes)
et de ne pas "encrasser" le système hôte avec des paquets dont l'utilisation est faible.

Les Dockerfiles des images Docker sont disponibles ici :

- [revealjs-builder](https://hub.docker.com/r/particule/revealjs-builder)
- [wkhtmltopdf](https://hub.docker.com/r/particule/wkhtmltopdf)

```
 USAGE : ./build.sh options

    -o output           Output format (html, pdf or all). Default: all

    -t theme            Theme to use. Default: particule

    -u revealjsURL      RevealJS URL that need to be use. If you build formation
                        supports on local environment you should git
                        clone https://github.com/hakimel/reveal.js and set
                        this variable to your local copy.
                        This option is also necessary even if you only want PDF
                        output. Default: https://particule.io/formations/revealjs

    -c course           Course to build, "all" for build them all !

    -l language         Language in which you want the course to be built. Default: fr
```

#### Thème

Les thèmes sont stockés dans `styles/`. Un thème est constitué de :

- un fichier CSS
- un dossier (nom du thème) contenant les assets (images, font, etc)

#### Reveal.js

Par défaut, nous utilisons une version forkée de reveal.js. Pour utiliser votre
propre version, vous devez spécifier son chemin avec le paramètre `-u`. Les
fichiers de votre thème seront copiés dans ce chemin. Si le chemin est distant
(uptream version par exemple), vous ne pourrez utiliser votre propre thème.

#### Language

Nous supportons le multi langage. Le script `build.sh` est conçu pour
rebasculer sur le contenu français si le cours n'existe pas dans la langue
demandée.

#### Exemples


```console
./build.sh -c docker -l fr -o html
./build.sh -o pdf
./build.sh -c openstack-user -u ~/reveal.js
./build.sh -c kubernetes -l en -t customer
```

- Les fichiers HTML se trouvent dans `output-html/`
- Les TP HTML dans `output-html/tp/`
- Les PDF se trouvent dans `output-pdf/`
- Les TP PDF dans `output-pdf/tp/`

En ayant puller au préalable les deux images Docker et en ayant une copie
locale de reveal.js (spécifié avec `-u`), les builds se font uniquement en
local.

### Makefile

Le build se fait entièrement en local.

* Voir le header du Makefile pour les dépendances nécessaires.
* Voir `make help` pour l'utilisation.

Quelques exemples :

```console
make openstack.pdf
make docker-handout.pdf
make docker-print.pdf
make openstack.html
```

## Copyright et licence

Tous les contenus originaux (Makefile, scripts, fichiers dans `cours/`) sont :

* Copyright © 2014-2019 alter way Cloud Consulting
* Depuis 2020, tous les commits sont la propriété de leurs auteurs respectifs
* Distribués sous licence Creative Commons BY-SA 4.0 (<https://creativecommons.org/licenses/by-sa/4.0/>)

![Creative Commons BY-SA](https://mirrors.creativecommons.org/presskit/buttons/88x31/png/by-sa.png)

Les autres fichiers du répertoire `images/` sont soumis à leur copyright et licence respectifs.

