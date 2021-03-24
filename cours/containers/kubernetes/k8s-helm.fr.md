# Kubernetes : Helm

## Qu'est-ce que Helm ?

- Outil de packaging d'application Kubernetes
- Developpé en Go
- Actuellement en v3
- Projet *graduated* de la CNCF

<https://github.com/helm/helm>

## Pourquoi Helm ?

  - Applique le principe DRY (Don't Repeat Yourself)
    - Mécanisme de templating (Go templating)
    - Variabilisation des ressources générées
  - Facilité de versionnement et de partage (repository Helm)
  - Helm permet d'administrer les Releases
    - Rollbacks / upgrades d'applications

## Concepts

Concept | Description
--------|------------------------------------------------------------------------
Chart   | Ensemble de ressources permettant de definir une application Kubernetes
Config  | Valeurs permettant de configurer un Chart (`values.yaml`)
Release | Chart deployé avec une Config

## Comparaison avec des manifests YAML

  - Permet de mettre en place le DRY (Don't Repeat Yourself)
    - customisation via fichier de configuration YAML
  - Définition d'une seule source de vérité
    - Les ressources sont packagées
  - Packages déployés via des Releases


## Structure d'un Chart

- Chart.yaml pour définir le chart ainsi que ses metadatas
- values.yaml sert à definir les valeurs de configuration du Chart par défaut
- `crds/`: Dossier qui recense les CRDs
- `templates/`: les templates de manifeste Kubernetes en YAML

### Chart.yaml

Le fichier de configuration du Chart dans lequel sont définies
ses metadatas.

```yaml
---
apiVersion: v2
description: Hello World Chart.
name: hello-world-example
sources:
  - https://github.com/prometheus-community/helm-charts
version: 1.3.2
appVersion: 0.50.3
dependencies: []
```

### Structure du values.yaml

- Chaque attribut est ensuite disponible au niveau des templates

```yaml
---
## Provide a name in place of kube-prometheus-stack for `app:` labels
##
applicationName: ""

## Override the deployment namespace
##
namespaceOverride: ""


## Apply labels to the resources
##
commonLabels: {}
```

### Surcharge du values.yaml

```yaml
---
# values-production.yaml
commonLabels:
  env: prod
```

```console
tree
.
├── Chart.yaml
├── templates
│   ├── application.yaml
│   ├── configuration.yaml
│   └── secrets.yaml
├── values-production.yaml
├── values-staging.yaml
└── values.yaml
```

### Templates

Helm permet de variabiliser les manifestes Kubernetes,
permettant de créer et configurer des ressources dynamiquement,
en se basant sur la configuration.

```yaml
apiVersion: apps/v1
kind: Pod
metadata:
  name: {{ .Chart.Name }}
  labels:
    app.kubernetes.io/managed-by: "Helm"
    chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
    release: {{ .Release.Name | quote }}
    version: 1.0.0
spec:
  containers:
  - image: "{{ .Values.helloworld.image.name }}:{{ .Values.helloworld.image.tag }}"
    name: helloworld
```

## Gestion des repositories

  - Un Repository Helm permet de distribuer et versionner des Charts
  - Contient un `index.yaml` listant les Charts packagés disponibles par version
  - Deux méthodes de déploiement possibles
    - Via HTTP en tant que fichiers statiques
    - Via OCI en utilisant une Registry (depuis Helm v3)

## Commandes communes

```console
$ helm repo add stable https://charts.helm.sh/stable
"stable" has been added to your repositories
$ helm repo update
$ helm install stable/airflow --generate-name
helm install stable/airflow --generate-name
NAME: airflow-1616524477
NAMESPACE: defaul
...
$ helm upgrade airflow-1616524477 stable/airflow
helm upgrade airflow-1616524477 stable/airflow
Release "airflow-1616524477" has been upgraded. Happy Helming!
$ helm rollback airflow-1616524477
Rollback was a success! Happy Helming!
$ helm uninstall airflow-1616524477
release "airflow-1616524477" uninstalled
```

