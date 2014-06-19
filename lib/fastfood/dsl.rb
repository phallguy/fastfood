require 'json'

module Fastfood
  module DSL

    def provision( context, host, *args )
      manager = fetch(:fastfood_manager)
      provisioned_hosts( host ).each do |provisioned|
        manager.provisioner( context, provisioned ).run( *args )
      end
    end

    def bootstrap( context, host, *args )
      manager = fetch(:fastfood_manager)
      bootstrapped_hosts( host ).each do |bootstrapped|
        manager.provisioner( context, bootstrapped ).run( *args )
      end
    end

    def sudo( *args )
      execute :sudo, *args
    end

    def sudo_upload!( io, destination )
      tmp = "/tmp/#{SecureRandom.uuid}"
      upload! io, tmp
      yield tmp if block_given?
      sudo :mv, tmp, destination
    ensure
      sudo :rm, "-f", tmp
    end

    def provisioned_hosts( hosts )
      remap_hosts hosts, user: fetch(:provision_user), keys: fetch(:provision_keys)
    end
    alias_method :provisioned_host, :provisioned_hosts

    def bootstrapped_hosts( hosts )
      remap_hosts hosts, user: fetch(:bootstrap_user), keys: fetch(:bootstrap_keys)
    end
    alias_method :bootstrapped_host, :bootstrapped_hosts

    def remap_hosts( hosts, new_properties = {} )
      Array( hosts ).map do |host|
        host.dup.with new_properties
      end
    end

    # Loads a set of data from local data files in the application configuration
    def repo( path, options = {} )
      files = Fastfood.find_files( path )
      warn_repo_missing path if files.empty? && options.fectch(:warn,true)
      files.each_with_object({}) do |file, data|
        File.open( file ) do |f|
          json = JSON.parse( f.read, symbolize_names: true )
          data.merge! json
        end
        break data unless options[:merge]
      end
    end

    def upload_template( host, from, to )
      path = Fastfood.find_file from
      erb = File.read( path )
      on host do |host|
        upload! ERB.new(erb).result(binding), to
      end
    end

    def warn_repo_missing( path )
      paths = Fastfood.file_paths.map{|p| File.join( p, path ) }
      puts "WARNING: No repo for #{path} found in #{paths}".yellow
    end

  end
end

include Fastfood::DSL