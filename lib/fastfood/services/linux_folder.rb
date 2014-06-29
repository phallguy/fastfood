module Fastfood
  module Services
    class LinuxFolder < Fastfood::Services::LinuxFileSystem

      private
        def create_destination( data )
          on_host do
            sudo :mkdir, "-p #{data[:destination]}"
          end
        end

    end
  end
end