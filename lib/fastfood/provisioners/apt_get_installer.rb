require 'fastfood/provisioners/provisioner'

module Fastfood
  module Provisioners
    class AptGetInstaller < Fastfood::Provisioners::Provisioner

      private
        def run_with_data( data )
          packages = Array( data[:packages] )
          on_host do
            sudo :'apt-get', "update" if data.fetch( :update, true )
            sudo :'apt-get', "-y install #{packages.join(" ")}"
          end
        end

    end
  end
end