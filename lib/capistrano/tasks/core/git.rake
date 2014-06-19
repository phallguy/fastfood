namespace :git do
  task :install do
    roles(:all).each do |host|
      provision :install, host, packages: :git
    end
  end
end