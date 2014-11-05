namespace :fastfood do
  namespace :secrets do

    task :generate do
      puts "Generating secrets.yml file"

      on release_roles(:app) do |host|
        server_file host, shared_path.join( "config/secrets.yml" ) do
          owner host.username
          group host.username

          template "secrets.yml.erb"
        end
      end
    end
    after "settingup", "fastfood:secrets:generate"

    task :link do
      on release_roles(:all) do
        execute :ln, "-nfs", shared_path.join( "config/secrets.yml" ), release_path.join( "config/secrets.yml" )
      end
    end
    after "deploy:updating", "fastfood:secrets:link"

  end

  task :secrets => ["secrets:generate","secrets:link"]
end