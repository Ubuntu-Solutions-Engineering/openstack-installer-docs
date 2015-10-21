# Multi Installer Guide

## Pre-requisites

> An existing MAAS server is required for the Multi install option. If you do
> not have a MAAS please visit
> [MAAS Getting Started guide](http://maas.ubuntu.com/docs1.8/install.html)
> for more details.

Multi-Installer has been tested on Ubuntu Server, which is the recommended OS for the cloud installer.

Add the OpenStack installer ppa to your system.

```
$ sudo apt-add-repository ppa:cloud-installer/stable
$ sudo apt-get update
```

### Networking

> For a proper installation the system must have an available network interface that can be managed by MAAS and respond to DNS/DHCP requests. The private network can then be configured to forward traffic out via public network interface.

An example of a system with 2 network interfaces **eth0 (public)** and **eth1 (private, bridged)**

```
# The loopback network interface
auto lo
iface lo inet loopback
  dns-nameservers 127.0.0.1
  pre-up iptables-restore < /etc/network/iptables.rules

auto eth0
iface eth0 inet dhcp

auto eth1
iface eth1 inet manual

auto br0
iface br0 inet static
  address 172.16.0.1
  netmask 255.255.255.0
  bridge_ports eth1
  ```

Below sets up the NAT for those interfaces, save to **/etc/network/iptables.rules**:

```
*nat
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
-A POSTROUTING -s 172.16.0.1/24 ! -d 172.16.0.1/24 -j MASQUERADE
COMMIT
```

Finally, enable IP Forwarding:

```
$ echo "1" | sudo tee /proc/sys/net/ipv4/ip_forward
```

## Installation

Install OpenStack installer via apt-get

```
$ sudo apt-get install openstack
```

## Start the installation

To start the installation run the following command

```
$ sudo openstack-install --edit-placement
```

An initial dialog box will appear asking you to select which type of install, choose **Multi-system**.

Fill in the subsequent dialogs for setting your password, entering the MAAS IP and API Key.

Once juju is bootstrapped the installer will present a placement screen which
allows the user to place services on specific machines. The placement screen
does a few checks so that services will not be placed in a container that will
only work in a KVM.

There is a minimal requirement for **Neutron** that requires **2 NICs** and that
machine should be selected during placement.

## Setting a password

When asked to set the openstack password it should be noted **that this password
is used throughout all openstack related services (ie Horizon login password)**.

## Next Steps

The installer will run through a series of steps starting with making sure the
necessary bits are available for a multi system installation and ending with a
juju bootstrapped system.

## Accessing the OpenStack environment

[See Using Juju in OpenStack Guide](https://wiki.ubuntu.com/OpenStack/Installer/using-juju)

## Tips

### Specifying a bootstrap node

Juju will arbitrarily pick a machine to install its state server to, however, if
a machine exists that is better suited you can tell the OpenStack installer to
use that machine instead:

```
$ JUJU_BOOTSTRAP_TO=openstack-vm-bootstrap.maas sudo -E openstack-install
```

### Custom Placement for Multi-Install Deployments

By default, the openstack installer will deploy services to available machines in your MAAS cluster based on the [Canonical Reference Architecture for OpenStack](https://jujucharms.com/openstack).

If you want to change that layout to choose specific systems for a set of services, or install some of the services that are not deployed by default, you can use the Custom Placement UI by adding the ''--edit-placement'' flag to your openstack-install command line:

```
% sudo openstack-install --edit-placement
```

This will show a text-mode UI for choosing where to place services. See [[https://wiki.ubuntu.com/OpenStack/Installer/service-placement|Placement UI Guide]] for details.


## Troubleshooting

Please see our [Multi Install Debugging](https://wiki.ubuntu.com/OpenStack/Installer/debugging/multi-install)

The installer keeps its own logs in **$HOME/.cloud-install/commands.log**.

## Uninstalling

To uninstall and cleanup your system run the following

```
$ sudo openstack-install -u
```

> If it errors out during uninstall see [manually uninstalling](https://wiki.ubuntu.com/OpenStack/Installer/debugging)
