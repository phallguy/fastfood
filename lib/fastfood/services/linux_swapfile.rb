require 'fastfood/services/user'

module Fastfood
  module Services
    class LinuxSwapfile < Fastfood::Services::Service

      private
        def run_with_data( data )
          location  = data.fetch( :location, "/swapfile" )
          size      = data.fetch( :size, 4096 )

          remove_swapfile( location )
          create_swapfile( location, size )
          configure_swappiness
          protect_swapfile( location )
        end

        def create_swapfile( location, size )
          on_host do
            sudo :dd     , "if=/dev/zero of=#{location} bs=1024 count=#{size}k"
            sudo :mkswap , location
            sudo :swapon , location
          end

          run_service \
            :config_change,
            file: "/etc/fstab",
            changes: { entry: "#{location} none swap sw 0 0", id: "swap" }

        end

        def configure_swappiness
          on_host do
            execute "echo 10 | #{SSHKit.config.command_map[:sudo]} tee /proc/sys/vm/swappiness"
          end

          run_service \
            :config_change,
            file: "/etc/sysctl.conf",
            changes: { key: "vm.swappiness", value: "10" }
        end

        def protect_swapfile( location )
          on_host do
            sudo :chown, "root:root #{location}"
            sudo :chmod, "0600 #{location}"
          end
        end

        def remove_swapfile( location )
          on_host do
            if test( "[ -f #{location} ]" )
              sudo :swapoff, location
              sudo :rm, location
            end
          end
        end

    end
  end
end