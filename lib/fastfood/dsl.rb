require 'json'

module Fastfood
  module DSL

    # Run a task on a server using the provisioning credentials.
    # @param [Symbol] subject used to look up the service from the fastfood_franchise.
    # @param [Host] host to perform the service on.
    # @param [Array] *args to pass to the service runner.
    def provision( subject, host, *args )
      franchise = fetch(:fastfood_franchise)
      provisioned_hosts( host ).each do |provisioned|
        franchise.service( subject, provisioned ).run( *args )
      end
    end

    # Run a task on a server using the bootstrap credentials.
    # @param [Symbol] subject used to look up the service from the fastfood_franchise.
    # @param [Host] host to perform the service on.
    # @param [Array] *args to pass to the service runner.
    def bootstrap( subject, host, *args )
      franchise = fetch(:fastfood_franchise)
      bootstrapped_hosts( host ).each do |bootstrapped|
        franchise.service( subject, bootstrapped ).run( *args )
      end
    end

    # Execute the given command as sudo
    def sudo( *args )
      execute :sudo, *args
    end

    # Upload a file using a temp folder then sudo mv to the destination.
    def sudo_upload!( io, destination )
      tmp = "/tmp/#{SecureRandom.uuid}"
      upload! io, tmp
      yield tmp if block_given?
      sudo :mv, tmp, destination
    ensure
      sudo :rm, "-f", tmp
    end

    # Maps the given hosts to a new array using provisioner credentials.
    def provisioned_hosts( hosts )
      remap_hosts hosts, user: fetch(:provision_user), keys: fetch(:provision_keys)
    end
    alias_method :provisioned_host, :provisioned_hosts

    # Maps the given hosts to a new array using bootstrap credentials.
    def bootstrapped_hosts( hosts )
      remap_hosts hosts, user: fetch(:bootstrap_user), keys: fetch(:bootstrap_keys)
    end
    alias_method :bootstrapped_host, :bootstrapped_hosts

    # Loads a set of data from local data files in the application configuration
    # @param [String] path to the repo file (ex config/fastfood/data/users.json)
    # @optionoptions [Boolean] :merge inherited data. Default true.
    def repo( path, options = {} )
      files = Fastfood.find_files( path )
      warn_repo_missing path if files.empty? && options.fectch(:warn,true)
      files.each_with_object({}) do |file, data|
        File.open( file ) do |f|
          json = JSON.parse( f.read, symbolize_names: true )
          deep_reverse_merge! data, json
        end
        break data unless options[:merge]
      end
    end

    # Upload an ERB template file to a host.
    def upload_template( host, from, to )
      path = Fastfood.find_file from
      erb = File.read( path )
      on host do |host|
        upload! ERB.new(erb).result(binding), to
      end
    end

    private

      def deep_reverse_merge!( original, additional )
        original.merge! additional do |k,o,a|
          deep_reverse_merge! o, a if Hash === o
          o
        end
      end

      def remap_hosts( hosts, new_properties = {} )
        Array( hosts ).map do |host|
          host.dup.with new_properties
        end
      end

      def warn_repo_missing( path )
        paths = Fastfood.file_paths.map{|p| File.join( p, path ) }
        puts "WARNING: No repo for #{path} found in #{paths}".yellow
      end


  end
end

include Fastfood::DSL