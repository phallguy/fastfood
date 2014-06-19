namespace :fastfood do
  namespace :provision do

    set :users, repo( "config/fastfood/data/users.json", merge: true )

    task users: ["fastfood:provision:provision_user", "fastfood:provision:deploy_user", "fastfood:provision:system_users"]


    task :deploy_user do

    end

    task :system_users do
      manager = fetch(:fastfood_manager)

      puts "Provisioning system users"
      roles(:all).each do |host|
        provision :user, host, fetch(:users)
      end
    end

    task :provision_user do
      puts "Ensuring provisioning user exists"
      roles(:all).each do |host|
        bootstrap :user,
                  host,
                  fetch( :users ).slice( fetch(:provision_user).to_sym )
      end
    end
  end
end