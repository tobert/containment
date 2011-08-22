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

## Examples

From the root of this project:

    sudo ruby -I./lib examples/nsfork_only.rb

## Usage

    require 'containment'

    # plain nsfork - the child process is in its own namespace
    pid = Containment::NS::nsfork()

    # still working out how I want this to look ... but something like this
    # get an object for the root cgroup
    root_cg = Containment::Cgroup.new("/")
    my_cg = root_cg.new_child("mine")
    my_cg.cpuset.cpus([0,1,2,3])
    my_cg.cpuset.mems([0])

    # all together now!
    # demo -- I haven't written all this yet ;)
    container = Containment::Container.new("/bin/true")
    container.cgroup.cpuset.cpus([1]) # lock to processor 1
    container.cgroup.cpuset.mems([0]) # lock memory node 0 (NUMA)
    container.ns.launch("ps -ef") # launch a process in the namespace

# AUTHOR

Al Tobey <tobert@gmail.com>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Al Tobey.

This is free software; you can redistribute it and/or modify it under the
terms of the Artistic License 2.0.  See the file LICENSE for details.

