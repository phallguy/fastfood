module Fastfood
  module Services
    class LinuxFile < Fastfood::Services::LinuxFileSystem
      private

        def create_destination( data )
          return unless data[:contents] || data[:template]
          on_host do
            sudo :mkdir, "-p #{File.dirname(data[:destination])}"
            sudo_upload! prepare_contents( data ), data[:destination]
          end
        end

        def generate_template( data )
          Template.new( data, manifest ).generate
        end

        def prepare_contents( data )
          return generate_template( data ) if data[:template]

          data.fetch(:contents)
        end

      class Template

        attr_reader :data, :manifest

        def initialize( data, manifest )
          @data     = data
          @manifest = manifest
        end

        def generate
          StringIO.new( ERB.new( File.read( path ) ).result(binding) ).tap do
            manifest.save destination, @bucket if @bucket
          end
        end

        def path
          Fastfood.find_file( data[:template] ) \
            || Fastfood.find_file( File.join( "config/fastfood/templates", data[:template] ) )
        end

        def bucket
          @bucket ||= manifest.select destination
        end

        def destination
          data[:destination]
        end

        def config_value( key, prompt, options = {} )
          value = _config_value( bucket, key.to_s.split('/') )
          if value
            return value unless options[ :prompt ]
          else
            value = yield if block_given?
          end

          ask( prompt, value ).call.tap do |val|
            _set_config_value bucket, key.to_s.split("/"), val
          end
        end

        def _config_value( hash, parts )
          val = hash[parts.shift]
          if parts.any?
            _config_value( val, parts )
          else
            val
          end
        end

        def _set_config_value( hash, parts, value )
          key = parts.shift
          val = hash[key]
          if parts.any?
            val ||= {}
            hash[key] = val
            _set_config_value( val, parts )
          else
            hash[key] = value
          end
        end

      end

    end
  end
end