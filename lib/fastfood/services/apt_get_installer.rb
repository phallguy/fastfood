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

          add_repos( packages )
          on_host do
            # Ignore dpkg-preconfigure: unable to re-open stdin: No such file or directory
            sudo :'apt-get', "-y install #{ packages_to_command( packages ) } 2> /dev/null"
          end
        end

        def packages_for_host( packages )
          blended = packages.fetch( :all, {} ).dup
          host.roles.each do |role|
            blended.merge! packages.fetch( role, {} )
          end

          blended
        end

        def packages_to_command( packages )
          packages.each_with_object([]) do |(key,value),commands|
            next if value == false

            commands << package_to_command( key, value )
          end.join(" ")
        end

        def package_to_command( key, value )
          command = [key]

          if value.is_a? Hash
            if version = value[:version]
              command << "="
              command << value[:version]
              command << "*"
            end
          end

          command.join('')
        end

        def add_repos( packages )
          needs_update = false
          manifest.select :apt_get_repositories do |bucket|
            packages.each do |key,value|
              next unless value.is_a? Hash
              next unless repo = value[:repo]
              next if bucket[repo]

              bucket[repo] = true
              needs_update = true
              on_host do
                sudo :'add-apt-repository', repo
              end
            end
          end

          update_system if needs_update
        end

    end
  end
end