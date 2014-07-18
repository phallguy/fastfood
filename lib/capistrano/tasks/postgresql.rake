namespace :postgresql do

  def pg_config( options = {} )
    {
      user: fetch(:pg_system_user),
      owner: fetch(:pg_user),
      database: fetch(:pg_database)
    }.merge( options )
  end

  desc "Installs PostgreSQL on the DB server"
  task :install => ["fastfood:system:install_packages"]

  desc "Install and configure postgresql"
  task :setup => [:install,:config,:create_db]

  task :create_db => ["postgresql:set_password"] do
    on provisioned_hosts(:db) do
      provision :sql, host,
        pg_config(
          create_user: { username: fetch(:pg_user), password: fetch(:pg_password) },
          create_db:   { extensions: [:hstore] }
          )
    end
  end

  task :config do
    on provisioned_hosts(:db) do
      provision :sql, host,
        pg_config(
          config: { version: fetch( :pg_version ), config_dir: fetch( :pg_config_dir ) }
          )
    end
  end

  task :generate_database_yml => ["fastfood:folders", "postgresql:set_password"] do
    release_roles(:app).each do |host|
      server_file host, File.join( shared_path, "config/database.yml" ) do
        template "pg_database.yml.erb"
        owner host.username
        group host.username
        mode "0400"
      end
    end
  end
  after "fastfood:config:generate", "postgresql:generate_database_yml"

  task :link_database_yml do
    on release_roles(:all) do
      execute :ln, "-nfs", shared_path.join( "config/database.yml" ), release_path.join( "config/database.yml" )
    end
  end
  after "fastfood:config:link", "postgresql:link_database_yml"

  task :set_password do
    db_yml  = shared_path.join( "config/database.yml" )
    found   = false
    on provisioned_hosts( release_roles(:app) ).each do
      if test("[ -f #{db_yml} ]")
        found = true
        config = YAML.load sudo_download!( db_yml )
        if stage = config[fetch(:stage).to_s]
          set :pg_password, stage["password"]
        end
      end
    end

    invoke "postgresql:generate_database_yml" unless found
  end

  %i{ start stop restart }.each do |command|
    task command do
      on provisioned_hosts( :db ) do
        sudo "/etc/init.d/postgresql #{command}"
      end
    end
  end

end

task settingup: "postgresql:setup"

namespace :load do
  task :defaults do
    set :pg_version,      "9.3"
    set :pg_database,     -> { "#{ fetch(:safe_application) }_#{fetch(:stage)}" }
    set :pg_user,         -> { fetch(:pg_database) }
    set :pg_host,         -> { db = roles(:db).first.internal_hostname }
    set :pg_password,     -> { ask "a new PG password: ", SecureRandom.hex }
    set :pg_system_user,  "postgres"
    set :pg_config_dir,   -> { "/etc/postgresql/#{fetch(:pg_version)}/main" }

    fetch(:fastfood_franchise).register_service :sql, Fastfood::Services::Postgres

    fastfood do
      package "postgresql-client", roles: :all
      %i{ postgresql postgresql-contrib libpq-dev }.each do |package|
        package( { package => { version: fetch( :pg_version ) } }, roles: :db )
      end

      firewall do
        well_known :sql, 5432
        allow      :sql, on: :db
      end
    end
  end
end