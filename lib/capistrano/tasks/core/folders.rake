namespace :fastfood do

  desc "Setup deployment folders"
  task :folders do
    release_roles( :all ).each do |host|
      user = host.user

      Array( [fetch(:deploy_to), shared_path, releases_path, shared_path.join("config") ] ).flatten.each do |folder|
        server_folder host, folder.to_s do
          owner user
          group user
        end
      end

    end
  end
end

namespace :load do
  task :defaults do
    set :linked_dirs, fetch(:linked_dirs,[]) + %w{ tmp/pids tmp/sockets log }
  end
end