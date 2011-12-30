##
# Resource: runit::service
#
# runit::service is a Puppet type that can be used to create Runit services with
# custom commands and custom log commands.
#
# == Parameters
#
# [*ensure*] the state of the service. Setting to "present" will create the
#   service but not activate it (by coping it to the active services directory).
#   In order to do so you should set the parameter to "active".
#
# [*command*]
#   The command to run for the service. Commands should not include a call to
#   "exec" as this is added automatically. The output of STDERR and STDOUT is
#   redirected to the same output for all commands.
#
# [*log_command*]
#   When specified this command is used to log the output of Runit.
#
# [*name*]
#   The name of the service, specified as the resource name.
#
# == Example
#
#   runit::service { 'memcached':
#     ensure  => active,
#     command => 'memcached -u memcached'
#   }
#
define runit::service(
  $command,
  $ensure      = present,
  $log_command = undef
) {
  include runit

  $available = "${::runit::available_services}/$name"
  $active    = "${::runit::active_services}/$name"
  $log       = "$available/log"

  # Create the service files but don't activate them yet.
  if $ensure == active or $ensure == present {
    # Create the service directory.
    file { $available:
      ensure  => directory,
      owner   => $::runit::user,
      group   => $::runit::group,
      mode    => 0770,
      recurse => true,
      require => File[$::runit::available_services],
    }

    # Create the run file.
    file { "$available/run":
      ensure  => present,
      owner   => $::runit::user,
      group   => $::runit::group,
      mode    => 0770,
      require => File[$available],
      content => template('runit/run.erb'),
    }
  }
  # Remove the service files.
  else {
    exec { 'shutdown-service':
      command => "/sbin/sv d $active",
      require => File[$active],
      onlyif  => '/usr/bin/test -e /sbin/sv'
    }

    file { $available:
      ensure => absent,
      force  => true,
    }

    file { $active:
      ensure => absent,
      force  => true,
    }
  }

  # Symlink the service?
  if $ensure == active {
    file { $active:
      ensure  => link,
      target  => $available,
      owner   => $::runit::user,
      group   => $::runit::group,
      mode    => 0770,
      recurse => true,
      require => File[$available],
    }
  }
  # Nuke the active symlink.
  elsif $ensure == present {
    file { $active:
      ensure => absent,
    }
  }

  # Create the log run file.
  if $log_command != undef and $ensure in [present, active] {
    file { $log:
      ensure  => directory,
      owner   => $::runit::user,
      group   => $::runit::group,
      mode    => 0770,
      recurse => true,
      require => File[$available],
    }

    file { "$log/run":
      ensure  => present,
      owner   => $::runit::user,
      group   => $::runit::group,
      mode    => 0770,
      require => File[$log],
      content => template('runit/log/run.erb'),
    }
  }
}
