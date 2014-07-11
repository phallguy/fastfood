require 'fastfood/franchises/linux'

namespace :load do
  task :defaults do
    set(:root_user, "root" )
    set :fastfood_franchise, Fastfood::Franchises::Linux.new
  end
end