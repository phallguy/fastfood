namespace :fastfood do
  namespace :provision do

    set :users, repo( "config/fastfood/data/users.json", merge: true )

    task :users do
      manager = fetch(:fastfood_manager)

      puts "Provisioning system users"
      roles(:all).each do |host|
        provision :user, host, fetch(:users)
      end
    end

  end
end