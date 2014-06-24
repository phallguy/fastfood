require 'fastfood/services/service'

module Fastfood
  module Services
    class AptGetInstaller < Fastfood::Services::Service

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