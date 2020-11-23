# Deploy OpenStack

### What we are going to see

- Install OpenStack manually
  <https://docs.openstack.org/install-guide/>
- Understand its internals
- Go through each component in more details
- Overview of deployment solutions

### Detailed architecture

![Vue détaillée des services](images/architecture.jpg)

### Services architecture

![Machines "physiques" et services](images/archi-service.png)

### A few global configuration items

- All the components must be configured to talk with Keystone
- Most must be configured to talk with MySQL/MariaDB and RabbitMQ
- Components split in multiple services sometimes have one configuration file per service
- The `policy.json` configuraton file specify the required permissions for each API call

### Operating system

- Linux OS with Python
- Ubuntu
- Red Hat
- SUSE
- Debian, Fedora, CentOS, etc.

### Python

![Python logo](images/python-powered.png){ width=100 height=50 }

- OpenStack is Python 2.7 compatible
- Python 3 comptability almost complete
- So as not to reinvent the wheel, a lot of dependencies are necessary

### MySQL/MariaDB database

- Stores most of the data managed by OpenStack
- Each component has it own database
- OpenStack uses the SQLAlchemy Python ORM
- Theoretical support of what SQLAlchemy supports (and migrations support)
- MySQL/MariaDB is the most tested and used implementation
- SQLite is mainly used for tests and demos
- Some deployments work with PostgreSQL

![SQLAlchemy logo](images/sqlalchemy-logo.png){height=40px}
![MySQL logo](images/mysql-logo.png){height=40px}

### Message bus

- AMQP: Advanced Message Queuing Protocol
- Messages, queues, routing
- OpenStack processes interact through AMQP
- Multiple possible implementations: Qpid, 0MQ, etc.
- RabbitMQ by default

### RabbitMQ

![RabbitMQ logo](images/rabbitmq-logo.png){height=40px}

- RabbitMQ is written in Erlang
- An Erlang virtual machine is therefore required

### “Hello world” RabbitMQ

![Simple example of RabbitMQ operation](images/rabbitmq-schema.png)

### Memcached cache

- Multiple services make use of a caching mechanism
- Memcached is the default implementation

## Keystone: Authentication, authorization and service catalog

### Install and configuration

- APT package: keystone
- WSGI web server integration (Apache by default)
- Configuration file: `/etc/keystone/keystone.conf`
- Users/groups backends: SQL, LDAP (or Active Directory)
- Projects/roles/services/endpoints backends: SQL
- Tokens backends: SQL, Memcache, none (depending on the token type)

### Tokens drivers

- Uuid
- PKI
- Fernet

### Bootstrap

- Services and endpoints creation (starting with Keystone)
- Users, groups and domains creation
- Bootstrap feature

## Nova: Compute

### Nova api

- Two jobs
- API to manage instances for the utilisateur
- API for the instances: metadata API
- The metadata API must be available at `http://169.254.169.254/`
- The metadata API provides personalized configuration informations to each instance

### Nova compute

- Manages instances (virtual or bare metal machines)
- Takes advantage of libvirt or other APIs such as XenAPI
- Drivers: libvirt (KVM, LXC, etc.), XenAPI, VMWare vSphere, Ironic
- Ability to retrieve console logs and VNC console

### Nova scheduler

- Service in charge of scheduling instance requests to compute nodes
- Filter, Chance, Multi Scheduler
- Filters, by default: AvailabilityZoneFilter,RamFilter,ComputeFilter
- Sort by weigh, by default: RamWeigher

### Nova scheduler in action

![nova-scheduler operation](images/scheduling-schema.png)

### Nova conductor

- Optional service which improves security
- Act as a proxy between compute nodes and DB
- Compute nodes, at risk, therefore don't have DB access anymore

## Glance: Image registry

### Backends

- Swift or S3
- Ceph
- HTTP
- Local directory

### Install

- APT package: glance-api

## Neutron: Network as a service

### Principles

- *Software Defined Networking* (SDN)
- Was Quantum and nova-network
- neutron-server: provides the API
- DHCP agent: provides DHCP service to instances
- L3 agent: manages network layer 3, routing
- Plugin: LinuxBridge by default, other open source / proprietary, software/hardware implementations exist

### Additional features

Beyonce basic layer 2 and 3 networking features, Neutron can provide other services:

- Load Balancing (HAProxy, ...)
- Firewall (vArmour, ...): different from security groups
- VPN (Openswan, ...): to reach a private network without floating IPs

These features are also based on plugins

### Plugins ML2

- **Modular Layer 2**
- LinuxBridge
- OpenVSwitch
- OpenDaylight
- Contrail, OpenContrail
- Nuage Networks
- VMWare NSX
- cf. OpenFlow

### Implementation

- Each network is a *bridge*
- Bridges are expanded across hosts using tunnels (VXLAN type) if necessary
- Neutron takes advantage of Linux kernel network namespaces to allow IP overlapping
- Metadata proxy is a component that allows instances isolated in their network to reach the metadata API provided by Nova

### Diagram

![User view of the network](images/neutron-schema.png)

### Diagram

![Infra view of the network](images/neutron-schema2.png)

## Cinder: Block storage

### Principles

- Was nova-volume
- Provides volumes
- Volume attachement through iSCSI by default

### Install

- Package cinder-api: provides the API
- Package cinder-volume: creation and management of volumes
- Package cinder-scheduler: scheduling of volume creation requests
- Package cinder-backup (optional): backup to an object store

### Backends

- Use of multiple backends in parallel possible
- LVM (by default)
- GlusterFS
- Ceph
- Proprietary storage systems such as NetApp
- DRBD

## Horizon: Web dashboard

### Principles

- Horizon is a Django module
- OpenStack Dashboard is the official implementation of this module

![Python Django web framework logo](images/django-logo.png){ width=100 height=50 }

### Configuration

- `local_settings.py`
- Services appear in Horizon if they exist in Keystone service catalog

## Swift: Object storage

### Principles

- SDS: *Software Defined Storage*
- Use of commodity hardware
- CAP  theorem: choosing two
- Completly decentralized architecture
- No central database

### Implementation

- Proxy: API server for all the requests
- Object server: storage server
- Container server: maintains list of objects in containers
- Account server: maintains list of containers in accounts
- Each object is replicated n times (3 by default)

### The ring

- Problem: how to decide which data is going onto which object server
- The ring is split in partitions
- Each data is located in the ring to find out the partition
- A partition is associated to multiple servers

### Diagram

![Swift architecture](images/swift-schema.png){ width=200 height=300 }

## Ceilometer: Metrics collection

### Monitor usage of infrastructure with Ceilometer

- Stores different metrics regarding usage of cloud services
- Provides APIs to retrieve these data
- Base to build billing tools (example: CloudKitty)

### Ceilometer

- Retrieves data and stores them
- Used to be stored in MongoDB
- Now stored in Gnocchi

### Gnocchi: time-series database

- Why Gnocchi? To solve Ceilometer + MongoDB scaling issues
- Initiated by Ceilometer developers and integrated in the Ceilometer project team
- Provides an API to read and write data
- Uses a relational DB and an object storage system

## Heat: Resources orchestration

### Architecture

- heat-api
- heat-engine

