# Travaux Pratiques : Docker

## Introduction

Ce TP permet de se familiariser avec la CLI Docker
et sur les fonctions de base des conteneurs Docker.

Nous montrerons comment :
- créer une image
- lancer un conteneur
- exposer des ports
- monter des volumes

## Installation

Plusieurs méthodes d’installation sont disponibles pour Docker. La plupart des
distributions possèdent un package officiel. Néanmoins ce package n’est pas tout
le temps à jour, il peut apparaitre utile d’utiliser les dépots fournis par
Docker afin de disposer d’un package à jour.

Exemple pour Ubuntu :
[https://docs.docker.com/engine/installation/linux/ubuntu/#install-docker](https://docs.docker.com/engine/installation/linux/ubuntu/#install-docker)


## Afficher les images et conteneurs
On peut utiliser le client docker pour afficher les images et conteneurs dans 
le système

Pour afficher les images : 
```bash
$ # list images
$ docker images
```
```bash
$ # list conatiners
$ docker container ls
```

On note bien qu'il y a pas ni des images docker ni de conteneurs dans le système.


## Construire une image Docker

Nous allon créer une image docker pour lancer un serveur nginx.
Voici un exemple d'un Dockerfile.

```bash
FROM ubuntu:16.04
RUN apt update \
	&& apt install -yf \
	nginx
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

Par convention, un Dockerfile ne prend jamais d'extension et commence par une
majuscule.

Pour construire notre image nommée `mynginx` :

```bash
$ docker build -t mynginx .
```

Notez bien le point à la fin de la commande ! Il permet de dire à Docker que le
Dockerfile à builder se trouve dans notre répertoire courant. Si on veut
construire plusieurs images, la bonne pratique est de créer un dossier par
image et d'y placer les Dockerfile correspondants.

Il est possible de renommer une image avec la commande `tag` :

```bash
$ docker tag mynginx masuperimagenginx
```

Une fois que les différentes layers ont été construites, vous devriez retrouver
votre image en local :

```bash
$ docker image ls
REPOSITORY            	TAG             	IMAGE ID        	CREATED          	SIZE
mynginx               	latest          	62d27f54b98b    	About a minute ago   212MB
masuperimagenginx      	latest          	62d27f54b98b    	About a minute ago   212MB
```

On voit bien que nos deux images ont exactement le même ID (ce sont les
**mêmes** images !) mais avec deux noms différents.


```bash
$ # list conatiners
$ docker container ls
```

On note bien qu'on n'a pas des conteneurs lancés.

## Lancer un conteneur

```bash
$ docker [OPTIONS] COMMAND [ARG…]
$ docker run -i -t ubuntu /bin/bash
root@ebc138d8cdc9:/# ls
bin  boot  dev  etc  home  lib  lib64  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
```

Les premières options à exploiter sont : -t , -i et -d
Elles permettent de choisir le “mode” du conteneur. Notamment entre le fait
d’être exécuté au premier plan ou en arrière plan.

Sur un autre terminal, on peut vérifier qu'on a un conteneur lancé
```bash
$ # list conatiners
$ docker container ls
```


### Exposer un port

Reprenons notre image mynginx

```bash
$ docker run -d -p 8001:80 mynginx
```

Nous avons exposé le port 8001 de notre host vers le port 80 de notre conteneur.

Vérifions que notre conteneur est bien en écoute :
```
$ curl http://localhost:8001

[...]

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

Que se passe t-il si vous essayer d'accéder à `http://localhost:80` depuis
votre host ? Pourquoi ?

### Monter un fichier

Le répertoire dans lequel Nginx va, par défaut, chercher les pages html est `/var/www/html`

Créons cet index.html dans notre dossier courant :

```html
<html>
<h1> Particule, l’expertise cloud </h1>
</html>
$ curl http://localhost:8001/www/html/index.html mynginx
```

Vérifions que notre page est bien accessible :

```html
$ curl http://localhost:8001
<html>
  <h1> Particule, l’expertise cloud native</h1>
</html>
```

Le test peut aussi être effectué sur votre navigateur. Les balises HTML sont correctement interprétées.

### Monter un volume

Créons notre volume au préalable :

```bash
$ docker volume create myvolume
myvolume
```

Par défaut, les volumes sont stockés dans `/var/lib/docker/volumes/`

Il est nécessaire d’être root pour accéder à la sous-arborescence
`/var/lib/docker`

```bash
# ls /var/lib/docker/volumes
myvolume metadata.db
# cd /var/lib/docker/volumes/myvolume/_data
# echo "<html> Hello Particule </html>" > index.html
```

Montons ce volume dans un conteneur :

```html
$ docker run -d -p 8001:80 -v myvolume:/var/www/html mynginx
$ curl http://localhost:8001
<html> Hello Particule </html>
```

Notre volume est correctement monté !


## Lancer l'appplication Demo-Todo


```
$ git clone https://github.com/particuleio/demo-todo-app
Cloning into 'demo-todo-app'...
remote: Enumerating objects: 21, done.
remote: Counting objects: 100% (21/21), done.
remote: Compressing objects: 100% (18/18), done.
remote: Total 21 (delta 1), reused 21 (delta 1), pack-reused 0
Receiving objects: 100% (21/21), 11.03 KiB | 2.76 MiB/s, done.
Resolving deltas: 100% (1/1), done.
$ cd demo-todo-app
$ export SERVER_ADDR=http://<VM_PUBLIC_IP>:1323
$ bash script.sh
...
```


