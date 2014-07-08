namespace :fastfood do

  desc "Setup deployment folders"
  task :folders do
    release_roles( :all ).each do |host|
      server_folder host, fetch(:deploy_to) do
        owner host.user
        group host.user
      end
    end
  end
  after "deploy:check", "fastfood:folders"
end