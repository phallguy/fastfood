namespace :fastfood do
  namespace :config do

    desc "Links configuration files from the shared folder to the application config folder"
    task :link do
    end
    after "deploy:updating", "fastfood:config:link"

    desc "Generates application config files in the shared/config folder"
    task :generate do
    end
    after "settingup", "fastfood:config:generate"

  end

  desc "Set up configuration files used by the application such as the secrets.yml and database.yml files"
  task :config => ["config:generate"]

end