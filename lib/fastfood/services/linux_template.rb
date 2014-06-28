require 'fastfood/services/user'

module Fastfood
  module Services
    class LinuxTemplate < Fastfood::Services::User

      private
        def run_with_data( data )
          on_host do
            path    = Fastfood.find_file( data[:template] ) \
                      || Fastfood.find_file( File.join( "config/fastfood/templates", data[:template] ) )
            output  = StringIO.new( ERB.new( File.read( path ) ).result(binding) )

            if data[:sudo]
              sudo_upload! output, data[:destination]
            else
              upload! output, data[:destination]
            end

            sudo :chmod, data[:chmod], data[:destination] if data[:chmod]
            sudo :chown, data[:chown], data[:destination] if data[:chown]
          end
        end

    end
  end
end