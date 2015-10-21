
# Single Installer Guide

## Pre-requisites

Add the OpenStack installer ppa to your system.

```
$ sudo apt-add-repository ppa:cloud-installer/stable
$ sudo apt-get update
```

> The host system must be capable of supporting KVM and nested KVM.

## Hardware

The installer would work best with at least:

 * 12G RAM (Hard requirement, see note below.)
 * 100G HDD (SSD for optimal performance)
 * 8 CPUS

> If running on a system with less than 12G of RAM expect to run into deployment issues early. Currently, 12G is the absolute lowest one can go to ensure a deployment will succeed.

## Installation

Install the OpenStack installer via apt-get

```
$ sudo apt-get install openstack
```

## Start the installation

To start the installation run the following command

```
$ sudo openstack-install
```

An initial dialog box will appear asking you to select which type of install,
choose **Single system**.

> Setting a password
>
> When asked to set the OpenStack password it should be noted that this password
> is used throughout all OpenStack related services (ie Horizon login password).

## Installing of Services

The installer will run through a series of steps starting with making sure the
necessary bits are available for a single system installation and ending with a
juju bootstrapped system.

When the bootstrapping has finished it will immediately load the status screen.
From there you can see the nodes listed along with the deployed charms necessary
to start your private OpenStack cloud.

Adding additional compute nodes, block storage, object storage, and controllers
can be done by pressing A and making the selection on the dialog box.

Finally, once those nodes are displayed and the charms deployed the horizon
dashboard will be available to you for managing your OpenStack cloud.

## Logging into Horizon (Openstack Dashboard)

The IP address of Horizon is located at the bottom of the status screen along
with your login and password credentials. For example, the login credentials for
the dashboard are:

*username: **ubuntu**
*password: **"password that was set during installation"**

## Accessing the OpenStack environment

[See Using Juju in OpenStack Guide](https://wiki.ubuntu.com/OpenStack/Installer/using-juju)

## Troubleshooting

See [Debugging a Single install](https://wiki.ubuntu.com/OpenStack/Installer/debugging/single-install)

## Uninstalling

To uninstall and cleanup your system run the following

```
$ sudo openstack-install -u
```

> If it errors out during uninstall check out [Manually uninstalling Single Install](https://wiki.ubuntu.com/OpenStack/Installer/debugging)

## Advanced Usage

It is possible to stop and start the container housing OpenStack. To do so run
the following from the container host:

```
$ sudo lxc-stop -n openstack-single-$USER
$ sudo lxc-start -n openstack-single-$USER -d
$ sudo lxc-attach -n openstack-single-$USER
# now, inside the container:
% su ubuntu
% JUJU_HOME=~/.cloud-install/juju juju status
```

From this point on it is a matter of waiting for all services to be restarted
and shown as **agent-state: started** within the juju status output.

Once the services are started again, running the following from the host system
will bring up the status screen again:

```
$ openstack-status
```

## Additional Tips

### Use pre-existing Ubuntu LXC cloud images

Subsequent runs of the single installer can make use of existing LXC cloud images. To do so run with the following:

```
$ USE_LXC_IMAGE_CACHE=1 sudo -E openstack-install
```

### Use an APT proxy

Speed up package installation by using an apt-proxy, both **squid-deb-proxy** and **apt-cacher-ng** are good choices.

For example,

```
$ sudo apt-get install apt-cacher-ng
$ sudo openstack-install --apt-proxy http://10.0.3.1:3142 --apt-https-proxy http://10.0.3.1:3142
```

### Persist static route through reboots

Because the single installer is a POC we try not to alter the host system, however, in this particular case to make accessing
the openstack services easier from the host a static route is added. This is not persisted through reboots so it requires you to make note of this and perform additional steps to keep the static ip available in the route table.

For example,

```
stokachu@cabeiri:~$ sudo lxc-ls -f
NAME                       STATE    IPV4                                 IPV6  GROUPS  AUTOSTART  
------------------------------------------------------------------------------------------------
openstack-single-stokachu  RUNNING  10.0.10.1, 10.0.3.11, 192.168.122.1  -     -       YES        
```

I can see that the ip assigned to the host is ''10.0.3.11'' and that the services used by juju are utilizing the '10.0.10.x' network. In order to manually add a static route for this run the following:

```
$ sudo ip route add 10.0.10.0/24 via 10.0.3.11 dev lxcbr0
```

Verify the ip route is added

```
$ ip route
10.0.10.0/24 via 10.0.3.11 dev lxcbr0
```
Feel free to add this line in however you manage your routing table, for example, in your ''/etc/rc.local'' file.

### Query your OpenStack Cloud

From the system hosting your container install some of the OpenStack cli tools and query various components:

```
$ sudo apt-get install python-novaclient
$ source ~/.cloud-install/openstack-ubuntu-rc
$ nova image-list
+--------------------------------------+---------------------------------------------------------------+--------+--------+
| ID                                   | Name                                                          | Status | Server |
+--------------------------------------+---------------------------------------------------------------+--------+--------+
| 2139dfdb-f4fb-418c-be5e-c5cb469eb05d | auto-sync/ubuntu-trusty-14.04-amd64-server-20150908-disk1.img | ACTIVE |        |
| 79698f1e-ceaa-4146-be3f-f01b02bf3b02 | auto-sync/ubuntu-trusty-14.04-amd64-server-20150908-disk1.img | ACTIVE |        |
+--------------------------------------+---------------------------------------------------------------+--------+--------+
```

You can find more information on what client tools are available on [The OpenStack Wiki](http://docs.openstack.org/user-guide/common/cli_install_openstack_command_line_clients.html)
