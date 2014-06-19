
namespace :fastfood do
  namespace :bootstrap do
    set(:root_user, "root" )
    set(:pub_keys, "~/.ssh/id_rsa.pub" )
    set(:swapfile_size, 4096)

    task default: [
      "bootstrap:create_provision_user",
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

    # task :create_remote_user do
    #   roles(:all).each do |host|
    #     ssh_path = "/home/#{host.username}/.ssh"
    #     key_file = "#{ssh_path}/authorized_keys"
    #     `ssh #{fetch(:root_user)}@#{host.hostname} 'useradd --create-home --shell /bin/bash #{host.username} || true; mkdir -p "#{ssh_path}"'`
    #     `cat #{fetch(:pub_keys)} | ssh #{fetch(:root_user)}@#{host.hostname} 'cat - > /tmp/authorized_keys; mv -f /tmp/authorized_keys #{key_file}; chown #{host.username}:#{host.username} #{key_file}; chmod 0600 #{key_file}; sh -c "echo 127.0.0.1 #{host.hostname} >> /etc/hosts"'`
    #     `ssh #{fetch(:root_user)}@#{host.hostname} 'echo "#{host.username}   ALL = NOPASSWD: ALL" > /etc/sudoers.d/#{host.username}; chmod 0440 /etc/sudoers.d/#{host.username}'`
    #   end
    # end

    # task :clone_local_user do
    #   roles(:all).each do |host|
    #     ssh_path = "/home/#{local_user}/.ssh"
    #     key_file = "#{ssh_path}/authorized_keys"
    #     `ssh #{fetch(:root_user)}@#{host.hostname} 'useradd --create-home --shell /bin/bash #{local_user} || true; mkdir -p "#{ssh_path}"'`
    #     `cat #{fetch(:pub_keys)} | ssh #{fetch(:root_user)}@#{host.hostname} 'cat - > /tmp/authorized_keys; mv -f /tmp/authorized_keys #{key_file}; chown #{local_user}:#{local_user} #{key_file}; chmod 0600 #{key_file}; sh -c "echo 127.0.0.1 #{host.hostname} >> /etc/hosts"'`
    #     `ssh #{fetch(:root_user)}@#{host.hostname} 'echo "#{local_user}   ALL = NOPASSWD: ALL" > /etc/sudoers.d/#{local_user}; chmod 0440 /etc/sudoers.d/#{local_user}'`

    #   end
    # end

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
