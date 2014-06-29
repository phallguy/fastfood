module Fastfood
  module Services
    class LinuxFile < Fastfood::Services::LinuxFileSystem

      private
        def create_destination( data )
          on_host do
            sudo_upload! prepare_contents( data ), data[:destination]
          end
        end

        def generate_template( data )
          path = Fastfood.find_file( data[:template] ) \
                      || Fastfood.find_file( File.join( "config/fastfood/templates", data[:template] ) )
          StringIO.new( ERB.new( File.read( path ) ).result(binding) )
        end

        def prepare_contents( data )
          return generate_template( data ) if data[:template]

          data.fetch(:contents)
        end

    end
  end
end