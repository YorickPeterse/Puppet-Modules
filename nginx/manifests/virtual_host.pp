##
# Type: nginx::virtual_host
#
# Type for creating Nginx virtual hosts. When adding a virtual host it is
# stored in the directory set in $hosts.
#
# == Parameters
#
# [*ensure*]
#   Can be set to either present or absent. When set to absent the specified
#   virtual host will be deleted.
#
# [*content*]
#   The content of the virtual host configuration file.
#
# == Example
#
#   nginx::virtual_host { 'default':
#     ensure  => present,
#     content => '...',
#   }
#
define nginx::virtual_host(
  $content
  $ensure = present,
) {
  include nginx

  # Install the virtual host
  if $ensure == present {
    file { "${::nginx::hosts}/$name":
      ensure  => present,
      mode    => 0644,
      owner   => $user,
      group   => $group,
      content => $content,
      require => File[$::nginx::hosts],
      notify  => Exec['reload-nginx'],
    }
  }
  # Remove the virtual host
  else {
    exec { "rm -f ${::nginx::hosts}/$name":
      notify  => Exec['nginx-reload'],
      require => File["${::nginx::hosts}/$name"]
    }
  }
}
