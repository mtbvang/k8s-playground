# Kubernetes Development VMs

This project contains a `Vagrantfile` for a 3 nodes Kubernetes cluster using `VirtualBox` and `Ubuntu
16.04`.

### Prerequisites

- Virtualbox 5.2+
- Vagrant 2.0.1+
- Internet access, this playground pulls Vagrant boxes from the Internet as well
as installs Ubuntu application packages from the Internet.

### Bringing Up The cluster
To bring up the cluster, clone this repository to a working directory.

```
git clone https://github.com/mtbvang/vagrant-ubuntu-k8s
```

Change into the working directory and `vagrant up`

```
cd vagrant-ubuntu-k8s
vagrant up
vagrant hostmanager --provider virtualbox
```

Vagrant will start three machines. Each machine will have a NAT-ed network
interface, through which it can access the Internet, and a `private-network`
interface in the subnet 172.42.42.0/24. The private network is used for
intra-cluster communication.

The machines created are:

| NAME | IP ADDRESS | ROLE |
| --- | --- | --- |
| k8s1 | 172.42.42.11 | Cluster Master |
| k8s2 | 172.42.42.12 | Cluster Worker |
| k8s3 | 172.42.42.13 | Cluster Worker |


