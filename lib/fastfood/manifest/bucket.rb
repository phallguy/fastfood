require 'hashie'

module Fastfood
  class Manifest
    # Key/value store for instance data.
    class Bucket < Hashie::Mash

      def initialize( *args )
        super
        @_dirty = false
      end

      # Determines if the given version is newer than the manifest version.
      def older?( version )
        unless manifest_version = self[:version]
          return version
        end

        version && Gem::Version.new( manifest_version ) < Gem::Version.new( version )
      end

      # Indicates if the hash has changed since it was loaded.
      def dirty?
        @_dirty
      end

      # Marks the hash as clean for dirty tracking.
      def clean!
        @_dirty = false
        self
      end

      # Marks the bucket as dirty.
      def dirty!
        @_dirty = true
        self
      end

      %w{ []= store update replace delete }.each do |method|
        class_eval %{
          def #{method}( *args )
            dirty!
            super
          end
        }
      end

    end
  end
end