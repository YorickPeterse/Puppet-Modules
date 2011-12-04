##
# Class: memcached
#
# Installs Memcached and sets up a specific user for the Memcached server.
#
# == Parameters
#
# [*user*]
#   The user to create for the memcached server.
#
# == Example
#
#   class { 'memcached':
#     user => 'memcached',
#   }
#
class memcached($user = 'memcached') {
  package { 'memcached':
    ensure => present
  }

  user { $user:
    ensure  => present,
    shell   => '/bin/false',
    require => Package['memcached']
  }
}
