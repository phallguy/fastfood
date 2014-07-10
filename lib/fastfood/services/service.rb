module Fastfood
  module Services
    # Services do the actual work on the server running tasks, installing software
    # adding users, etc.
    class Service

      include Fastfood::Trampoline

      # @return [Capistrano::Configuration::Server] the host that the service
      #   will perform it's actions on.
      attr_reader :host

      # @return [Fastfood::Franchises:Franchise] used to coordinate other services
      #   require to complete this service's tasks.
      attr_reader :franchise

      # @param [Capistrano::Configuration::Server] host to run on.
      def initialize( host, franchise )
        host = Array( host )
        fail "Expecting exactly 1 host" if host.length != 1
        @host = host.first
        @franchise = franchise
      end

      # Perform the provisioning task using the provided data.
      # @pram [Hash] data required to do the work.
      def run( data = {} )
        run_with_data( collect_data( data ) )
      end

      protected

        def manifest
          @manifest ||= Fastfood::Manifest.new( host, File.join( fetch(:fastfood_folder), "manifest" ) )
        end

        # Determines if the service should run with the given options.
        # @option options [Array<Symbol,String>] roles we're limited to.
        def should_run?( options )
          if roles = Array( options[:roles] )
            return false unless roles.any?{ |r| host.has_role? r }
          end

          true
        end

        # Allow the service to collect data from the server and merge it with
        # the provided data before running.
        # @param [Hash] current data.
        # @return [Hash] the combined data.
        def collect_data( data )
          data
        end

        # OVERRIDE THIS when implementing a service to do the actual work.
        # @param [Hash] data to use when working.
        def run_with_data( data )
          fail "Implement #run_with_data in #{self.class.name}."
        end

        # Perform an action with the configured host on the server. Allows base
        # classes to perform some sort of setup.
        # @param [Hash] with_env additional environment variables to set.
        def on_host( with_env = {}, &block )
          service = self
          on host do
            with( { debian_frontend: "noninteractive" }.merge( with_env ) ) do
              Fastfood::Trampoline::Spring.new(  service, self ).bounce &block
            end
          end
        end

        # Provisions and runs a named service on the host.
        def run_service( subject, data = {} )
          franchise.service( subject, host ).run data
        end


    end
  end
end