module Fastfood
  # Simple key/value structure for data kept on each client to keep track of
  # installed resources, versions, and history.
  class Manifest

    include Fastfood::Trampoline

    # @!attribute
    # @return [Host] host the manifest represents.
    attr_accessor :host

    # @param [Host] host to track data on.
    # @param [String] bucket_path on the host to store manifest buckets in.
    def initialize( host, bucket_path )
      @host = host
      @bucket_path = bucket_path
    end

    # Selects a bucket to store name/values pairs to.
    # @param [String,Symbol] bucket name.
    # @yieldparam [Hash] bucket to store name/value pairs in.
    #
    # After yielding do the block, select will persist any changes to the bucket
    # to the host before returning.
    def select( bucket_name )
      bucket = find_bucket( bucket_name )
      if block_given?
        yield bucket
        save_bucket bucket_name, bucket if bucket.dirty?
      else
        bucket
      end
    end

    # Saves the given hash back to the server.
    def save( bucket_name, bucket )
      save_bucket bucket_name, bucket
    end

    private

      def buckets
        @buckets ||= {}
      end

      def find_bucket( bucket_name )
        bucket_name = bucket_name.to_sym
        path        = path_for_bucket( bucket_name )

        unless bucket = buckets[bucket_name]
          on_trampoline host do
            bucket = if test( :sudo, "[ -f #{path} ]" )
              buckets[bucket_name] = Bucket.new( JSON.parse( sudo_download! path ) )
            else
              Bucket.new
            end
          end
        end

        bucket
      end

      def save_bucket( bucket_name, bucket )
        path = path_for_bucket( bucket_name )
        bucket_path = @bucket_path
        on_trampoline host do
          sudo :mkdir, "-p #{File.dirname( path )}"
          sudo_upload! StringIO.new( JSON.pretty_generate( bucket ) ), path
        end
      end

      def path_for_bucket( bucket_name )
        parts = bucket_name.to_s.split(/\//).map{|c| safe_file_component_name c}
        File.join( @bucket_path, *parts[0..-2], "#{parts[-1]}.json" )
      end

      def safe_file_component_name( name )
        name.gsub( /[^a-z0-9\.\-]+/i, '_' ).gsub(/_$/,'')
      end

  end
end

require 'fastfood/manifest/bucket'