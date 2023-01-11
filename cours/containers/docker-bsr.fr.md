# Build, Ship and Run !

### Build

### Le conteneur et son image

- Flexibilité et élasticité

- Analogie avec les VMs: instance et snapshot/image

- Instanciation illimitée

### Construction d'une image

- Possibilité de construire à la base d'un conteneur

- Suivi de version et construction d'images de manière automatisée

- Utilisation de *Dockerfile* afin de garantir l'idempotence des images

### Dockerfile

- Suite d'instructions qui définit une image

- Permet de vérifier le contenu d'une image

- Chaque commande Dockerfile génère un nouveau layer

```bash
FROM alpine:3.4
MAINTAINER Particule <admin@particule.io>
RUN apk -U add nginx
EXPOSE 80 443
CMD ["nginx"]
```

### Dockerfile : principales instructions

- `FROM` : baseimage utilisée

- `RUN` : Commandes effectuées lors du build de l'image

- `EXPOSE` : Ports exposées lors du run (si `-P` est précisé)

- `ENV` : Variables d'environnement du conteneur à l'instanciation

- `CMD` : Commande unique lancée par le conteneur

- `ENTRYPOINT` : "Préfixe" de la commande unique lancée par le conteneur

### Dockerfile : best practices

- Bien choisir sa baseimage

- Bien organiser les layers: mettre ce qui change à la fin

- Comptez vos layers !

### Dockerfile : Bad Layering

```bash
VOLUME /config /downloads

ENV PORT=8081

EXPOSE 8081
RUN apk --update add \
    git \
    tzdata \
    python \
    unrar \
    zip \
    libxslt \
    py-pip \

RUN rm -rf /var/cache/apk/*

CMD ["--datadir=/config", "--nolaunch"]

ENTRYPOINT ["/usr/bin/env","python2","/sickrage/SickBeard.py"]
```

### Dockerfile : Good Layering

```bash
RUN apk --update add \
    git \
    tzdata \
    python \
    unrar \
    zip \
    libxslt \
    py-pip \
    && rm -rf /var/cache/apk/*

VOLUME /config /downloads

EXPOSE 8081

CMD ["--datadir=/config", "--nolaunch"]

ENTRYPOINT ["/usr/bin/env","python2","/sickrage/SickBeard.py"]
```

### Dockerfile : DockerHub

- Build automatisée d'images Docker

- Intégration GitHub / DockerHub

- Plateforme de stockage et de distribution d'images Docker

### Ship

### Ship : Les conteneurs sont manipulables

- Sauvegarder un conteneur :

```bash
docker commit mon-conteneur backup/mon-conteneur
```

```bash
docker run -it backup/mon-conteneur
```

### Ship : Save and export

- Exporter une image :

```bash
docker save -o mon-image.tar backup/mon-conteneur
```

- Importer un conteneur :

```bash
docker import mon-image.tar backup/mon-conteneur
```

### Ship : Pull & Push
- DockerHub n’est qu’au Docker registry ce que GitHub est à git

- Des images officiels

- Authentification au registre docker.io

```bash
docker login
```

### Ship : Pull & Push
- Ajouter un tag avec l’adresse du registre
```bash
docker tag docker.io/username/mon-conteneur:v1
```

- Push d'une image :

```bash
docker push docker.io/username/mon-conteneur:v1
```

- Pull d'une image :

```bash
docker pull docker.io/username/mon-conteneur:v1
```


### Run

### Run : lancer un conteneur

- docker run

  - `-d` (detach)

  - `-i` (interactive)

  - `-t` (pseudo tty)

### Run : beaucoup d’options...

- `-v` /directory/host:/directory/container

- `-p` portHost:portContainer

- `-P`

- `-e` “VARIABLE=valeur”

- `--restart=always`

- `--name=mon-conteneur`

### Run : ...dont certaines un peu dangereuses

- `--privileged` (Accès à tous les devices)

- `--pid=host` (Accès aux PID de l’host)

- `--net=host` (Accès à la stack IP de l’host)

### Run : se “connecter” à un conteneur

- docker exec

- docker attach

### Run : Détruire un conteneur

- docker kill (SIGKILL)

- docker stop (SIGTERM puis SIGKILL)

- docker rm (détruit complètement)

### Run : Les conteneurs en production 
- Les conteneurs à très grand échelle
- Les conteneurs sont éphémères
- Besoin de contrôler l'état des conteneurs

### Run : Les conteneurs en production 
- Il y a d'autres besoins pour les applis
  - scaling
  - networking
  - stockage
  - dns
  - config
  - gestion de traffic
  - ...


### Build, Ship and Run : Conclusions

- Écosystème de gestion d'images

- Construction automatisée d'images

- Contrôle au niveau conteneurs

- Besoin d'un outil gestion des conteneurs à grande échelle


