require 'fastfood/franchises/linux'

set(:root_user, "root" )
set(:pub_keys, "~/.ssh/id_rsa.pub" )
set(:swapfile_size, 4096)


set :fastfood_manager, Fastfood::Franchises::Linux.new