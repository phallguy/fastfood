namespace :fastfood do

  desc "Setup deployment folders"
  task :folders do
    release_roles( :all ).each do |host|

      Array( [fetch(:deploy_to), shared_path, releases_path, shared_path.join("config") ] ).flatten.each do |folder|
        server_folder host, folder.to_s do
          owner host.user
          group host.user
        end
      end

    end
  end
end