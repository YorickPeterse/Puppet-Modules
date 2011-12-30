##
# Class: runit
#
# This module uses Yaourt and the runit-dietlibc package. The latter is a more
# lightweight version of Runit.
#
# == Parameters
#
# [*ensure*]
#   The state of the Runit package (present, absent, etc). Set to present by
#   default.
#
# [*available_services*]
#   The directory to use for storing all the available services, set to /etc/sv
#   by default.
#
# [*active_services*]
#   The directory containing all active services, set to /service by default.
#
# [*user*]
#   The user to use for the ownership of all files and directories. Set to root
#   by default. If you're using a different user it will be created
#   automatically.
#
# [*group*]
#   The group to use for all files and folders. Set to runit by default, created
#   automatically.
#
# == Example
#
#   class { 'runit':
#     ensure => present,
#   }
#
class runit(
  $ensure             = present,
  $available_services = '/etc/sv',
  $active_services    = '/service',
  $user               = 'root',
  $group              = 'runit'
) {
  package { 'runit-dietlibc':
    ensure   => $ensure,
    provider => 'yaourt'
  }

  if $user != 'root' {
    user { $user:
      ensure => present
    }
  }

  group { $group:
    ensure  => present,
    require => Package['runit-dietlibc']
  }

  # Directory with all the available services.
  file { $available_services:
    ensure  => directory,
    mode    => 0770,
    recurse => true,
    owner   => $user,
    group   => $group,
    require => Group[$group]
  }

  # Directory containing all active services.
  file { $active_services:
    ensure  => directory,
    mode    => 0770,
    recurse => true,
    owner   => $user,
    group   => $group,
  }

  file { '/sbin/runsvdir-start':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => 0770,
    content => template('runit/runsvdir-start.erb'),
    require => File[$active_services]
  }

  if $ensure == present {
    # Adds Runit to the inittab and reloads the configuration.
    exec { 'add-inittab':
      command => '/bin/echo -e "\nSV:123456:respawn:/sbin/runsvdir-start" \
        >> /etc/inittab; /sbin/init q',
      onlyif  => '/usr/bin/test -z `/bin/grep "SV:123456" /etc/inittab`',
      require => File['/sbin/runsvdir-start']
    }
  }
  else {
    # Removes the Runit line from /etc/inittab and ensures that there's only 1
    # empty line at the end of the file.
    exec { 'delete-inittab':
      command => '/bin/sed -i "s/SV:123456:respawn:\/sbin\/runsvdir-start//g" \
        /etc/inittab; /bin/sed -i "/^$/N;/\n$/D" /etc/inittab; /sbin/init q'
    }
  }
}
