namespace :firewall do

  desc "Installs Firewall system components on the server"
  task install: ["fastfood:system:install_packages"]

  desc "Install and configure the firewall"
  task setup: [:install,:configure,:enable]

  task :configure do
    rules = fetch( :firewall_config ).fetch( :rules )
    roles(:all).each do |host|
      provision :firewall, host, rules: rules
    end
  end

  desc "Enables the firewall and all configured rules"
  task :enable do
    roles(:all).each do |host|
      provision :firewall, host, enable: true, status: true
    end
  end

  desc "Disables the firewall"
  task :disable do
    provision :firewall, host, disable: true, status: true
  end

end

task settingup: "firewall:setup"

namespace :load do
  task :defaults do
    fastfood do
      # Make sure the Universal Fire Wall utility is installed.
      package "ufw", roles: :all

      firewall do
        # Default rule is to not allow any connections (Except SSH of course)
        # which is always enabled by the firewall provisioner.
        default :deny
      end
    end
  end
end