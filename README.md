# Chef playground

This demo features a Chef server with three readily bootstrapped nodes all
running on Vagrant VMs.

Virtualization: libvirt / KVM

Tested on
- Fedora 26
- libvirt 3.2.1
- Vagrant 1.9.1
- Chef Development Kit 2.0.28

# Prerequisites

- [ChefDK](https://downloads.chef.io/chefdk)
- [libvirt](https://libvirt.org/)
- [libvirt-nss](https://wiki.libvirt.org/page/NSS_module) name resolution enabled
- [Vagrant](https://www.vagrantup.com/)
- Vagrant plugin [`vagrant-libvirt`](https://github.com/vagrant-libvirt/vagrant-libvirt)
- (optional) Vagrant plugin [`vagrant-cachier`](https://github.com/fgrehm/vagrant-cachier)

# Usage

1. Run the boostrap script, get some coffee &mdash; it takes a while.

    ```bash
    $ ./bootstrap.sh
    ```

2. Use the `knife` tool to manipulate your virtual infrastructure or `chef
   generate cookbook` to start a new cookbook.
