module Fastfood
  # Provides a DSL for setting up fastfood configuration without polluting the
  # global namespace.
  module Configuration
    module_function

    # @param [Array<String>,String,Hash] new_packages to install on the target host.
    # @option options [Array<Symbol>,Symbol] :roles to install the packages on.
    #
    # Declare a required system package.
    #
    # When **new_packages** is a string, or array of strings, fastfood will simply
    # install the package with the given name using the default options.
    #
    # When **new_package** is a hash, the key is the name of the package and the
    # keys are additional values understood by the package installer such as
    # version, or repoisitory address.
    def package( *new_packages )
      packages = fetch( :system_packages, all: {} )
      options  = new_packages.pop if new_packages.length > 1 && new_packages.last.is_a?( Hash )
      options  ||= {}

      new_packages = _map_packages( new_packages )
      Array( options.fetch( :roles, :all ) ).each do |role|
        packages[role.to_sym] = packages.fetch( role.to_sym, {} ).merge new_packages
      end

      set :system_packages, packages
    end

    # Declare firewall rules.
    # @see Fastfood::FirewallConfiguration
    #
    # @example
    #     fastfood do
    #       firewall do
    #         allow :http, on: :web
    #       end
    #     end
    def firewall( &block )
      firewall_config = FirewallConfiguration.new fetch( :firewall_config, {} )
      set :firewall_config, firewall_config.build( &block )
    end

    # Set the fastfood franchise to use.
    def franchise( name )
      require "capistrano/fastfood/franchises/#{name}"
    end

    # Use defaults for a given cloud platform.
    def cloud( name )
      require "capistrano/fastfood/clouds/#{name}"
    end

    # Include the named fastfood services.
    def services( *names )
      names.flatten.compact.each do |name|
        require File.join( "capistrano/fastfood", name )
      end
    end

    def fetch( *args )
      env.fetch( *args )
    end

    def set( *args )
      env.set( *args )
    end

    def env
      Capistrano::Configuration.env
    end

    def _map_packages( packages )
      packages.each_with_object( {} ) do |package, mapped|
        case package
        when Hash then mapped.merge! package
        when String,Symbol  then mapped[package.to_sym] = true
        when Array then mapped.merge!( _map_packages( package ) )
        else fail "Not sure what to do with #{package}."
        end
      end
    end

  end
end