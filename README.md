# Puppet Modules

This repository contains a collection of Puppet modules that are meant to be
used on Arch Linux (though they shouldn't be too hard to port).

Currently this repo contains the following modules:

* Memcached
* Nginx
* Runit

## Requirements

* Arch Linux
* Yaourt

Yaourt can be installed as following:

    $ echo -e "\n[archlinuxfr]\nServer = http://repo.archlinux.fr/\$arch" \
      >> /etc/pacman.d/mirrorlist
    $ pacman -Syu
    $ pacman -S yaourt

Besides Yaourt and Arch Linux you'll also need to install the following packages
to get Puppet to work:

* base-devel
* openssh
* openssl
* ruby
* git
* sudo (not required when puppet runs as root)
* inetutils
* net-tools (provides ifconfig, etc)

Once installed you'll have to create a user and group for Puppet:

    $ groupadd puppet
    $ useradd puppet -g puppet

Once all this has been done you should be good to go.

## Installation

    $ git clone git://github.com/YorickPeterse/Puppet-Modules.git puppet_modules
    $ cp -r puppet_modules /etc/puppet/modules

## License

The code in this repository is licensed under the MIT license. A copy of this
license can be found in the file "LICENSE".
