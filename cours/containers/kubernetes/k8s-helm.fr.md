# Kubernetes : Helm

## Helm : Qu'est-ce que Helm ? (what)

- Outil de packaging d'application Kubernetes
- Developpe en Go
- Actuellement en v3
- Incubated project CNCF

github.com/helm/helm

## Helm : Pourquoi Helm ? (why)

  - Applique le principe D.R.Y (Don't Repeat Yourself)
    - Mechanisme de templating
    - Variabilisation des ressources generees
  - Single point of authority
  - Easy to host, version, share (public & private repositories)
  - Helm permet d'administrer les Releases
    - Rollbacks / upgrades d'applications

## Helm : Compare a des manifestes YAML

  - Permet de mettre en place le DRY (Dont Repeat Yourself)
    - customisation via fichier de configuration YAML
  - Definition d'une seule source de verite
    - Les ressources sont packagees
    - On ne deploie plus de manifeste manuellement
  - Packages deployees via des Releases

## Helm : Concepts

Concept | Description
--------|------------------------------------------------------------------------
Chart   | Ensemble de ressources permettant de definir une application Kubernetes
Config  | Valeurs permettant de configurer un Chart (`values.yaml`)
Release | Chart deploye avec une Config


## Helm : Structure d'un Chart

- Chart.yaml pour definir le chart ainsi que ses metadatas
- values.yaml sert a definir les valeurs de configuration du Chart par defaut
- `crds/`: Dossier qui recense les CRDs
- `templates/`: les templates de manifeste Kubernetes en YAML

### Helm : Chart.yaml

Le fichier de configuration du Chart dans lequel sont definies
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

### Helm : Structure du values.yaml

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

### Helm : Surcharge du values.yaml

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
├── values-dev.yaml
├── values-production.yaml
├── values-staging.yaml
└── values.yaml
```

### Helm : Templates

Helm permet de variabiliser les manifestes Kubernetes,
permettant de creer et configurer des ressources dynamiquement,
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

## Helm : Gestion des repositories

- What is helm repository
- How to create helm repository (private?)
- How to publish to helm repository

## Helm : Commandes communes

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
helm upgrade  airflow-1616524477 stable/airflow
Release "airflow-1616524477" has been upgraded. Happy Helming!
$ helm rollback airflow-1616524477
Rollback was a success! Happy Helming!
$ helm uninstall airflow-1616524477
release "airflow-1616524477" uninstalled
```

## Conclusion

