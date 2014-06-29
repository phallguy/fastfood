require 'fastfood/services/user'

module Fastfood
  module Services
    class LinuxTemplate < Fastfood::Services::User

      private
        def run_with_data( data )
          upload_template( data )
          establish_permissions( data )
        end

        def upload_template( data )
          on_host do
            output = generate_template( data )

            if data[:sudo]
              sudo_upload! output, data[:destination]
            else
              upload! output, data[:destination]
            end
          end
        end

        def establish_permissions( data )
          on_host do
            sudo :chmod, data[:chmod], data[:destination] if data[:chmod]
            sudo :chown, data[:chown], data[:destination] if data[:chown]
          end
        end

        def generate_template( data )
          path = Fastfood.find_file( data[:template] ) \
                      || Fastfood.find_file( File.join( "config/fastfood/templates", data[:template] ) )
          StringIO.new( ERB.new( File.read( path ) ).result(binding) )
        end

    end
  end
end