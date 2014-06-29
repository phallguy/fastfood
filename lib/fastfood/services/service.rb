module Fastfood
  module Services
    # Services do the actual work on the server running tasks, installing software
    # adding users, etc.
    class Service

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

        # Determines if the service should run with the given options.
        # @option options [Array<Symbol,String>] roles we're limited to.
        def should_run?( options )
          if roles = options[:roles]
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
            with( { term: "xterm", debian_frontend: "noninteractive" }.merge( with_env ) ) do
              Trampoline.new( service, self ).bounce &block
            end
          end
        end

        # Provisions and runs a named service on the host.
        def run_service( subject, data = {} )
          franchise.service( subject, host ).run data
        end

        # Supports blending class methods and host dsl methods. When `on host`
        # is invoked, the block is executed with the host as self making it
        # impossible to invoke other methods on the service object without keeping
        # a reference to 'self' and making the methods public. This helper class
        # offers a blended binding that will invoke methods on the service object
        # first, then on the host binding.
        class Trampoline
          def initialize( service, host )
            @service = service;
            @host    = host;
          end

          def bounce(&block)
            instance_eval(&block)
          end

          def method_missing( name, *args )
            if @service.respond_to?( name, true )
              return @service.send( name, *args )
            elsif @host.respond_to?( name, true )
              return @host.send( name, *args )
            end

            super
          end

          def respond_to?( *args )
            @service.respond_to?( *args ) || @host.respond_to?( *args )
          end
        end
    end
  end
end