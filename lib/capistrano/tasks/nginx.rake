namespace :nginx do

  desc "Installs nginx on servers with the :web role"
  task install: ["fastfood:system:install_packages"] do

  end

  task :config do
    roles(:web).each do |host|

      puts fetch(:domain_name)

      server_file host, "/etc/nginx/nginx.conf" do
        template "nginx/root.conf.erb"
        user :root
        owner :root

        workers fetch(:nginx_worker_processes)
      end

      app_config = "#{fetch(:safe_application)}.conf"
      server_file host, "/etc/nginx/sites-available/#{app_config}" do
        template "nginx/app.conf.erb"
        user :root
        owner :root

        ssl           fetch(:ssl)
        application   fetch(:safe_application)
        domain_name   fetch(:domain_name)
        static_paths  Array( fetch(:static_paths) )
        bind          fetch(:app_bind)
      end

      on provisioned_host host do
        sudo :ln, "-nfs", "/etc/nginx/sites-available/#{app_config}", "/etc/nginx/sites-enabled/#{app_config}"
        sudo :rm, "-f", "/etc/nginx/sites-enabled/default"
      end

    end
  end

  desc "Install and configure nginx"
  task setup: [:install,:config]

  %i{ start stop restart }.each do |command|
    task command do
      on provisioned_hosts( :web ) do
        sudo "/etc/init.d/nginx #{command}"
      end
    end
  end
  after "deploy:publishing", "nginx:restart"

end

task settingup: "nginx:setup"

namespace :load do
  task :defaults do
    set :nginx_worker_processes, 2
    set :ssl, false
    set :static_paths, fetch(:assets_prefix)
    set :domain_name, ->{ primary( :web ).hostname.split(".")[1..-1].join('.') }

    fastfood do
      package nginx: { repo: "ppa:nginx/stable" }

      firewall do
        allow :http,   on: :web
        allow :https,  on: :web
      end
    end
  end
end