require 'puppet/provider/package'

##
# Package provider for Yaourt. Yaourt is a package manager for Arch Linux that
# makes it easy to install packages from the AUR. The usage of Yaourt is almost
# identical to Pacman so most of the code in this provider was copied from
# lib/puppet/provider/package/pacman.rb.
#
# @since 03-12-2011
#
Puppet::Type.type(:package).provide(
  :yaourt,
  :parent => Puppet::Provider::Package
) do
  desc 'Package provider for Yaourt, used on Arch Linux.'

  commands    :yaourt => '/usr/bin/yaourt'
  confine     :operatingsystem => :archlinux
  has_feature :upgradeable

  class << self
    ##
    # Returns an array containing the command and parameters to use in order to
    # list all installed packages.
    #
    # @since  03-12-2011
    # @return [Array]
    #
    def listcmd
      [command(:yaourt), ' -Q']
    end

    ##
    # Retrieves a list of all the currently installed packages.
    #
    # @since  03-12-2011
    # @return [Array]
    #
    def instances
      packages = []

      begin
        execpipe(listcmd) do |process|
          fields = [:name, :ensure]

          # yaourt -Q returns a list of packages in the format of
          # repo/package version (group)
          regex = /^\w+\/(\S+)\s+(\S+)/

          process.each_line do |line|
            hash = {}

            if match = line.match(regex)
              fields.zip(match.captures) do |field, value|
                hash[field] = value
              end

              hash[:provider] = self.name
              packages        << new(hash)
            else
              warning('Failed to match line %s' % line)
            end
          end
        end
      rescue Puppet::ExecutionFailure
        return nil
      end

      return packages
    end
  end

  ##
  # Installs a new package or updates an existing one. Yaourt does not have the
  # option --noprogressbar.
  #
  # @since 03-12-2011
  #
  def install
    yaourt('--noconfirm', '-Sy', @resource[:name])
  end

  ##
  # Updates an existing package.
  #
  # @since 03-12-2011
  #
  def update
    install
  end

  ##
  # Retrieves the latest version of a package.
  #
  # @since  03-12-2011
  # @return [String]
  #
  def latest
    yaourt('-Sy')

    return yaourt('-Sp', '--print-format %v', @resource[:name]).chomp
  end

  ##
  # Queries Yaourt for information about a package.
  #
  # @since 03-12-2011
  #
  def query
    begin
      output = yaourt('-Qi', @resource[:name])

      if output =~ /Version.*:\s(.+)/
        return { :ensure => $1 }
      end
    rescue Puppet::ExecutionFailure
      return {
        :ensure => :purged,
        :status => 'missing',
        :name   => @resource[:name],
        :error  => 'ok',
      }
    end

    return nil
  end

  ##
  # Removes a package from the system.
  #
  # @since 03-12-2011
  #
  def uninstall
    yaourt('--noconfirm', '-R', @resource[:name])
  end
end
