set :provision_user, ENV["USER"]
set :bootstrap_user, 'root'
set :bootstrap_keys, ENV["BOOTSTRAP_KEYS"] || "~/.ssh/id_rsa"
set :provision_keys, ENV["PROVISION_KEYS"] || "~/.ssh/id_rsa"
