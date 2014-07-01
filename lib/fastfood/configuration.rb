module Fastfood
  # Provides a DSL for setting up fastfood configuration without polluting the
  # global namespace.
  module Configuration
    module_function

    # Declare a required system package.
    # @param [Array<String>,String] package_names to install on the target host.
    # @option options [Array<Symbol>,Symbol] :roles to install the packages on.
    def package( package_names, options = {} )
      packages = fetch( :system_packages, {} )
      package_names = Array( package_names ).map &:to_s
      Array( options.fetch( :roles, :all ) ).each do |role|
        packages[role.to_sym] = packages.fetch( role.to_sym, Set.new ) + package_names
      end

      set :system_packages, packages
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

  end
end