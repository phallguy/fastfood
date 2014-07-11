namespace :redis do

  desc "Installs redis on servers with the :redis role"
  task install: ["fastfood:system:install_packages"] do
    roles(:redis).each do |host|
      provision :source_installer, host,
        source: "http://download.redis.io/releases/redis-2.8.12.tar.gz",
        sha: "56c86a4f9eccaf29f934433c7c67a175e404b2f6",
        version: "2.8.12"
    end
  end

  task :config do
    roles(:redis).each do |host|
      server_file host, "/etc/redis/#{fetch(:redis_port)}.conf" do
        template "redis/redis.conf.erb"
        owner :root
        group :root
        port fetch(:redis_port)
      end

      server_folder host, "/var/log/redis" do
      end

      server_file host, "/etc/init.d/redis_#{fetch(:redis_port)}" do
        mode "755"
        template "redis/init_script.erb"
        port fetch(:redis_port)
      end

      on provisioned_host(host) do
        execute :'update-rc.d', "redis_#{fetch(:redis_port)} defaults"
      end
    end
  end

  desc "Install and configure redis"
  task setup: [:install,:config]

end

task settingup: "redis:setup"

namespace :load do
  task :defaults do

    set :redis_port, 6379

    fastfood do
      package "tcl8.5", roles: :redis

      firewall do
        well_known :redis, fetch( :redis_port )
        allow      :redis, on: :redis, from: [ :app, :db ]
      end
    end
  end
end