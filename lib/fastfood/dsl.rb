require 'json'

module Fastfood
  module DSL

    # Sets up a fastfood configuration context.
    def fastfood(&block)
      Fastfood.configure(&block)
    end

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

    # # Execute the given command as sudo
    # def sudo( *args )
    #   if args.first.is_a? Symbol
    #     args = args.dup
    #     args[0] = SSHKit.config.command_map[args[0]]
    #   end
    #   execute :sudo, *args
    # end

    # Upload a file using a temp folder then sudo mv to the destination.
    def sudo_upload!( io, destination )
      tmp = "/tmp/#{SecureRandom.uuid}"
      upload! io, tmp
      yield tmp if block_given?
      sudo :mv, "-f", tmp, destination
    ensure
      sudo :rm, "-f", tmp
    end

    # Download a file using a temp folder then sudo mv to the destination.
    def sudo_download!( destination )
      mode = capture( :sudo, :stat, "-c '%a'", destination, '2> /dev/null' ).strip

      sudo :chmod, "a+r", destination
      download! destination
    ensure
      sudo :chmod, mode, destination if mode
    end

    # Maps the given hosts to a new array using provisioner credentials.
    def provisioned_hosts( hosts )
      _remap_hosts hosts, user: fetch(:provision_user), keys: fetch(:provision_keys)
    end
    alias_method :provisioned_host, :provisioned_hosts

    # Maps the given hosts to a new array using bootstrap credentials.
    def bootstrapped_hosts( hosts )
      _remap_hosts hosts, user: fetch(:bootstrap_user), keys: fetch(:bootstrap_keys)
    end
    alias_method :bootstrapped_host, :bootstrapped_hosts

    # Loads a set of data from local data files in the application configuration
    # @param [String] path to the repo file (ex config/fastfood/data/users.json)
    # @option options [Boolean] :merge inherited data. Default true.
    def repo( path, options = {} )
      files = Fastfood.find_files( path )
      _warn_repo_missing path if files.empty? && options.fectch(:warn,true)
      files.each_with_object({}) do |file, data|
        File.open( file ) do |f|
          json = JSON.parse( f.read, symbolize_names: true )
          _deep_reverse_merge! data, json
        end
        break data unless options[:merge]
      end
    end

    # Adds a file to the remote server.
    # @param [Host] host to put the file on.
    # @param [String,Hash] options_or_destination either the destination path, or an options hash for the File service.
    def server_file( host, options_or_destination = nil, &block )
      _file_system_dsl host, :file, options_or_destination, &block
    end

    # Creates a folder on the remote server.
    # @param [Host] host to put the folder on.
    # @param [String,Hash] options_or_destination either the destination path, or an options hash for the Folder service.
    def server_folder( host, options_or_destination = nil, &block )
      _file_system_dsl host, :folder, options_or_destination, &block
    end

    # Makes a change in a config file.
    # @param [Host] host to put the folder on.
    # @param [String,Hash] options_or_config_file either the config file path, or an options hash for the ConfigChange service.
    def config_change( host, options_or_config_file = nil, &block )
      _dsl_method host, :config_change, { file: options_or_config_file }, &block
    end

    # Gets a manifest manager for the given host.
    def host_manifest( host )
      Fastfood::Manifest.new( host, File.join( fetch(:fastfood_folder), "manifest" ) )
    end

    # Execute the block with the given verbosity.
    def with_verbosity( verbosity, &block )
      original = SSHKit.config.output_verbosity
      SSHKit.config.output_verbosity = verbosity
      yield
    ensure
      SSHKit.config.output_verbosity = original
    end

    private

      def _file_system_dsl( host, subject, options_or_destination = nil, &block )
        options_or_destination = options_or_destination.to_path if options_or_destination.respond_to? :to_path
        options_or_destination = { destination: options_or_destination } if options_or_destination.is_a? String
        _dsl_method host, subject, options_or_destination , &block
      end

      def _dsl_method( host, subject, options, &block )
        options ||= {}
        provision subject, host, options.merge( DslBuilder.new.build( &block ).to_hash )
      end

      def _deep_reverse_merge!( original, additional )
        original.merge! additional do |k,o,a|
          _deep_reverse_merge! o, a if Hash === o
          o
        end
      end

      def _remap_hosts( hosts, new_properties = {} )
        hosts = Array( hosts )
        if hosts.first.is_a? Symbol
          hosts = hosts.map{|h| roles(h)}.flatten
        end

        hosts.map do |host|
          if host.properties.all?{|k,v| new_properties[k] == v }
            return host
          else
            host.dup.with new_properties
          end
        end
      end

      def _warn_repo_missing( path )
        paths = Fastfood.file_paths.map{|p| File.join( p, path ) }
        puts "WARNING: No repo for #{path} found in #{paths}".yellow
      end

      class DslBuilder

        def initialize
          @hash = {}
        end

        def build( &block )
          instance_eval( &block )
          self
        end

        def to_hash
          @hash
        end

        def method_missing( name, *args )
          @hash[name] = args.first
        end
      end
  end
end
