namespace :fastfood do
  namespace :system do

    fastfood do
      package %w{ git git-core htop }, roles: :all
      package %w{ unattended-upgrades }, roles: :all if fetch(:unattended_upgrades)
    end

    task :update do
      roles(:all).each do |host|
        provision :install, host, update: true
      end
    end

    task :upgrade do
      roles(:all).each do |host|
        provision :install, host, upgrade: true
      end
    end

    task :install_packages do
      roles(:all).each do |host|
        provision :install, host, packages: fetch(:system_packages,{})
      end
    end

    desc "Installs system packages"
    task install: [:update,:install_packages]

  end
end