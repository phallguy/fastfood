require 'hashie'

module Fastfood
  class Manifest
    # Key/value store for instance data.
    class Bucket < Hashie::Mash

      include Fastfood::Extensions::DirtyTrackingHash

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

    end
  end
end