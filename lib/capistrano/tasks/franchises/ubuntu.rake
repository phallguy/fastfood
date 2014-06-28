require 'fastfood/franchises/linux'

set(:root_user, "root" )

set :fastfood_franchise, Fastfood::Franchises::Linux.new