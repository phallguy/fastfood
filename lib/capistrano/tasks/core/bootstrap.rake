namespace :fastfood do
  namespace :bootstrap do

    task default: [
      "fastfood:bootstrap:create_provision_user",
      "fastfood:bootstrap:swapfile",
      "fastfood:provision:users",
      "fastfood:bootstrap:setup_folders",
      "fastfood:system:install",
      "fastfood:bootstrap:install_ruby",
      "fastfood:bootstrap:install_client"
      ] do
    end

    task :create_provision_user do
      puts "Ensuring provisioning user exists"
      roles(:all).each do |host|
        bootstrap :user,
                  host,
                  fetch( :users ).slice( fetch(:provision_user).to_sym )
      end
    end

    task :setup_folders do
      release_roles( :all ).each do |host|
        server_folder host, fetch(:deploy_to) do
          owner host.user
          group host.user
        end
      end
    end

    task :swapfile do
      swapfile_size = fetch(:swapfile_size,0).to_i
      roles(:all).each do |host|
        provision :swapfile, host, size: swapfile_size
      end
    end

    task :unattended_upgrades do
      next unless fetch(:unattended_upgrades)

      release_roles(:all).each do |host|
        server_file host, '/etc/apt/apt.conf.d/50unattended-upgrades' do
          template "50unattended-upgrades.erb"
          owner "root"
          group "root"
          mode "0644"
        end
      end
    end

    task :install_ruby do
      # Each VM hooks onto this to make sure it's installed with the server
    end

    task :install_client do
      on provisioned_hosts(:all) do |host|
        provision :folder_bundle, host,
          source: File.expand_path( "../../../../fastfood/client", __FILE__ ),
          destination: fetch(:fastfood_folder),
          owner: "root",
          group: "root",
          mode: "0600"
      end
    end

  end

  desc "Prepare a server for running capistrano tasks"
  task bootstrap: "fastfood:bootstrap:default"
end


namespace :load do
  namespace :defaults do
    set(:swapfile_size, 1024)
    set(:unattended_upgrades, true)
    set(:fastfood_folder, "/opt/fastfood")
  end
end