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
      Array( options.fetch( :roles, :all ) ).each do |role|
        packages[role.to_sym] = packages.fetch( role.to_sym, [] ) + Array( package_names )
      end

      set :system_packages, packages
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