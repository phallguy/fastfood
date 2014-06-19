
namespace :fastfood do
  namespace :bootstrap do
    set(:root_user, "root" )
    set(:pub_keys, "~/.ssh/id_rsa.pub" )
    set(:swapfile_size, 4096)

    task default: [
      "fastfood:bootstrap:create_provision_user",
      "fastfood:provision:users",
      "git:install"
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

    # # enable swap file
    # # https://www.digitalocean.com/community/articles/how-to-add-swap-on-ubuntu-12-04

    # task :swapfile do
    #   swapfile_size = fetch(:swapfile_size,0).to_i
    #   roles(:all).each do |host|
    #     if swapfile_size > 0
    #       `ssh #{fetch(:root_user)}@#{host.hostname} 'dd if=/dev/zero of=/swapfile bs=1024 count=#{swapfile_size}k && mkswap /swapfile && swapon /swapfile && echo /swapfile none swap sw 0 0 >> /etc/fstab'`
    #       `ssh #{fetch(:root_user)}@#{host.hostname} 'echo 10 | tee /proc/sys/vm/swappiness && echo vm.swappiness = 10 | tee -a /etc/sysctl.conf'`
    #       `ssh #{fetch(:root_user)}@#{host.hostname} 'chown root:root /swapfile && chmod 0600 /swapfile'`
    #     end
    #   end
    # end

    # task :unattended_upgrades do
    #   on roles(:all) do |host|
    #     template host, "60unattended-upgrades-security.erb", "/tmp/60unattended-upgrades-security"
    #     sudo :mv, "/tmp/60unattended-upgrades-security", "/etc/apt/apt.conf.d/60unattended-upgrades-security"
    #   end
    # end
  end

  desc "Prepare a server for running capistrano tasks"
  task bootstrap: "fastfood:bootstrap:default"
end
