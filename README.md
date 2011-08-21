# Containment

Containment is a library for working with Linux kernel cgroups and namespaces.

## Requirements

- Linux!

This module is not portable to other OS's at all. It also does not try to
support any funky mounting schemes for cgroups, so you must have the full
cgroup fs mounted as described below. Running on the same system as LXC
may or may not work; I don't care (yet). This should and is intended
to work fine inside other kinds of virtualization like Xen (including EC2),
KVM, and VMware.

### Cgroups

 - Linux 2.6.24 or higher with CONFIG\_NAMESPACES=y
 - cgroups mounted with all facilities in /cgroup, e.g.

    echo "cgroup /cgroup cgroup defaults 2 0" >> /etc/fstab
    mount /cgroup

### Namespaces

 - Linux 2.6.24 or higher with CONFIG\_NAMESPACES=y
 - Root or CAP\_SYS\_ADMIN privileges

## Installation

None at the moment. Once I'm happy with it, I'll publish a gem and update this.

## Usage

    require 'containment'

    # ... working on it ...

