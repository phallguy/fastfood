namespace :postgresql do

  desc "Installs PostgreSQL on the DB server"
  task :install => ["fastfood:system:install_packages"]

  desc "Install and configure postgresql"
  task :setup => [:install,:create_db]

  task :create_db => ["postgresql:set_password"] do
    on provisioned_hosts(:db) do
      provision :sql, host,
        user: fetch(:pg_system_user),
        create_user: { username: fetch(:pg_user), password: fetch(:pg_password) },
        create_db:   { name: fetch(:pg_database), owner: fetch(:pg_user), extensions: [:hstore] }
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

  task :set_password do
    db_yml  = File.join( shared_path, "config/database.yml" )
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

end


namespace :load do
  task :defaults do
    fastfood do
      package "postgresql-client", roles: :all
      package "postgresql", "postgresql-contrib", roles: :db

      firewall do
        well_known :sql, 5432
        allow      :sql, on: :db, from: :app
      end
    end

    set :pg_database,     -> { "#{ fetch(:safe_application) }_#{fetch(:stage)}" }
    set :pg_user,         -> { fetch(:pg_database) }
    set :pg_host,         -> { db = roles(:db).first; db.fetch(:internal_hostname) || db.hostname }
    set :pg_password,     -> { ask "a new PG password: ", SecureRandom.hex }
    set :pg_system_user,  "postgres"

    fetch(:fastfood_franchise).register_service :sql, Fastfood::Services::Postgres
  end
end