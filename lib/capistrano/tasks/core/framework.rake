namespace :load do
  task :defaults do
    set :provision_user, ENV["USER"]
    set :bootstrap_user, 'root'
    set :bootstrap_keys, ENV["BOOTSTRAP_KEYS"] || "~/.ssh/id_rsa"
    set :provision_keys, ENV["PROVISION_KEYS"] || "~/.ssh/id_rsa"

    set :safe_application, ->{ fetch(:application).to_s.gsub( /[^a-z0-9_]+/i, '_') }
  end
end

desc "Setup a new server"
task :setup