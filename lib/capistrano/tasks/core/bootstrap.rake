namespace :load do
  namespace :defaults do
    set(:swapfile_size, 1024)
    set(:unattended_upgrades, true)
    set(:fastfood_folder, "/opt/fastfood")

    # Make sure sudo knows it's non-interactive and won't prompt for password
    # if its required. Just fail.
    SSHKit.config.command_map[:sudo] = "#{SSHKit.config.command_map[:sudo]} -n"
  end
end

namespace :fastfood do
  namespace :bootstrap do

    task default: [
      "fastfood:bootstrap:create_provision_user",
      "fastfood:bootstrap:swapfile",
      "fastfood:provision:users",
      "fastfood:system:install",
      "fastfood:bootstrap:install_ruby",
      "fastfood:bootstrap:install_client"
      ] do
    end

    # Makes sure that the user to be used for provisioning exists on the server.
    # Must have access to the bootstrap keys for root login.
    task :create_provision_user do
      roles(:all).each do |host|
        bootstrap :user,
                  host,
                  fetch( :users ).slice( fetch(:provision_user).to_sym )
      end
    end

    # Setup a swap file
    task :swapfile do
      swapfile_size = fetch( :swapfile_size, 0 ).to_i
      next if swapfile_size == 0

      roles(:all).each do |host|
        provision :swapfile, host, size: swapfile_size
      end
    end

    # Make sure the system stays up-to-date for security patches.
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

    # Install the fastfood client on the server.
    # TODO: make it useful.
    task :install_client do
      on provisioned_hosts(:all) do |host|
        provision :folder_bundle, host,
          id: "fastfood_client",
          source: File.expand_path( "../../../../fastfood/client", __FILE__ ),
          destination: fetch(:fastfood_folder),
          owner: "root",
          group: "root",
          mode: "0611",
          force: true,
          version: Fastfood::VERSION
      end
    end

  end

  desc "Prepare a server for running capistrano tasks"
  task bootstrap: "fastfood:bootstrap:default"
end

task :settingup => "fastfood:bootstrap"
