require 'ipaddr'

module Fastfood
  # Provides a DSL for setting up firewall rules.
  class FirewallConfiguration

    attr_reader :config

    WELL_KNOWN = {
      http:  80,
      https: 443,
      ftp:   21,
      ssh:   22,
      scp:   22,

      pop3:  110,
      smtp:  25,

      dns:   53
    }

    # @option options [Hash] :well_known hash of named ports to their actual values.
    def initialize( config = {} )
      @config = {
        rules: config[:rules] || [],
        well_known: WELL_KNOWN.merge( config[:well_known] || {} )
      }
    end

    # Builds the actual firewall rules given a block that defines them using
    # the firewall dsl.
    def build( &block )
      instance_eval( &block )
      config
    end

    private

      def allow( *args )
        _command :allow, *args
      end

      def deny( *args )
        _command :deny, *args
      end

      def default( allow_or_deny, options = {} )
        _rules << _command_options( options ).merge!(  command: :default, args: allow_or_deny )
      end

      def custom( args )
        _rules << { args: args }
      end

      def clear
        _rules = []
      end

      def well_known( name, port )
        config[:well_known][name.to_sym] = port
      end

      def _port( port_or_well_known )
        return unless port_or_well_known
        return port_or_well_known if port_or_well_known.is_a? Integer

        config[:well_known][port_or_well_known] || fail( "'#{port_or_well_known}' is not a well known port" )
      end

      def _command( name, *args )
        options = args.pop if args.last.is_a? Hash
        options ||= {}

        if args.any?
          args.each do |port|
            _port_command name, port, options
          end
        else
          _port_command name, nil, options
        end
      end

      def _port_command( name, port, options )
        cmd = _command_options( options ).merge! \
          command: name,
          protocol: options[:protocol] ? Array( options[:protocol] ) : nil,
          from: Array(options[:from] || :any)

        cmd[:port] = _port( port ) if port

        _rules << cmd
      end

      def _command_options( options )
        cmd = {
          roles: Array(  options[:on] ) + Array( options[:to] ) + Array( options[:roles] ),
        }

        cmd[:roles]   = [:all] unless cmd[:roles].any?
        cmd
      end

      def _rules
        config[:rules]
      end

  end
end
