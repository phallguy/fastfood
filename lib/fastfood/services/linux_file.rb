require 'fastfood/services/user'

module Fastfood
  module Services
    class LinuxFile < Fastfood::Services::User

      private
        def run_with_data( data )
          upload_contents( data )
          set_mode( data )
          set_owner( data )
        end

        def upload_contents( data )
          on_host do
            output = prepare_contents( data )

            sudo_upload! output, data[:destination]
          end
        end

        def set_owner( data )
          chown = ""
          chown = "#{data[:owner]}"     if data[:owner]
          chown += ":#{data[:group]}"   if data[:group]

          on_host do
            sudo :chown, chown, data[:destination] unless chown.empty?
          end
        end

        def set_mode( data )
          on_host do
            sudo :chmod, data[:mode], data[:destination] if data[:mode]
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