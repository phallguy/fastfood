module Fastfood
  module Provisioners
    # Provisioners do the actual work on the server running tasks, installing software
    # adding users, etc.
    class Provisioner

      # @return [Capistrano::Configuration::Server] the host that the provisioner
      #   will perform it's actions on.
      attr_reader :host

      # @param [Capistrano::Configuration::Server] host to run on.
      def initialize( host )
        @host = host
      end

      # Perform the provisioning task using the provided data.
      # @pram [Hash] data required to do the work.
      def run( data = {} )
        run_with_data( collect_data( data ) )
      end

      private

        # Allow the provisioner to collect data from the server and merge it with
        # the provided data before running.
        # @param [Hash] current data.
        # @return [Hash] the combined data.
        def collect_data( data )
          data
        end

        # OVERRIDE THIS when implementing a provisioner to do the actual work.
        # @param [Hash] data to use when working.
        def run_with_data( data )
          fail "Implement #run_with_data in #{self.class.name}."
        end
    end
  end
end