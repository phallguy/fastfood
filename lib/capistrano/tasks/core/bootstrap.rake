namespace :fastfood do
  namespace :bootstrap do
    set(:swapfile_size, 1024)
    set(:unattended_upgrades, true)

    task default: [
      "fastfood:bootstrap:create_provision_user",
      "fastfood:bootstrap:swapfile",
      "fastfood:provision:users",
      "fastfood:bootstrap:setup_folders",
      "fastfood:system:install"
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
        on provisioned_host host do
          sudo :mkdir, "-p #{fetch(:deploy_to)}"
          sudo :chown, "-R #{host.user}:#{host.user} #{fetch(:deploy_to)}"
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
        provision :template, host,
          template: "50unattended-upgrades.erb",
          destination: "/etc/apt/apt.conf.d/50unattended-upgrades",
          chown: "root:root",
          chmod: "0644",
          sudo: true
      end
    end
  end

  desc "Prepare a server for running capistrano tasks"
  task bootstrap: "fastfood:bootstrap:default"
end
