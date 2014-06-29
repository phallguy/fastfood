require 'fastfood/services/service'

module Fastfood
  module Services
    class AptGetInstaller < Fastfood::Services::Service

      private
        def run_with_data( data )
          update_system   if data[:update]
          upgrade_system  if data[:upgrade]

          install_packages( data[:packages] )
        end

        def update_system
          on_host do
            sudo :'apt-get', "update"
          end
        end

        def upgrade_system
          on_host do
            sudo :'apt-get', "upgrade"
          end
        end

        def install_packages( packages )
          packages = packages_for_host( packages )
          on_host do
            # Ignore dpkg-preconfigure: unable to re-open stdin: No such file or directory
            sudo :'apt-get', "-y install #{packages.join(" ")} 2> /dev/null"
          end
        end

        def packages_for_host( packages )
          blended = packages.fetch( :all, [] )
          host.roles.each do |role|
            blended += packages.fetch( role, [] )
          end

          blended.to_a
        end

    end
  end
end