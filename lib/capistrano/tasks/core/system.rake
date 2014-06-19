namespace :system do

  set :required_packages, %w{ git git-core htop unattended-upgrades tcl imagemagick s3cmd htop python-software-properties }
  set :additional_packages, []

  task :update do
    on roles(:all) do
      sudo "apt-get", "update"
    end
  end

  task :upgrade do
    on roles(:all) do
      sudo "apt-get", "-y upgrade"
    end
  end

  task :install_packages do
    on roles(:all) do
      packages = fetch(:required_packages) + fetch(:additional_packages)
      sudo "apt-get", "-y install #{packages.join(' ')}"
    end
  end
end