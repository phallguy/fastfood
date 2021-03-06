require 'fastfood/version'
require 'fastfood/core'
require 'pry'

module Fastfood

  autoload :Configuration         , 'fastfood/configuration'
  autoload :FirewallConfiguration , 'fastfood/firewall_configuration'
  autoload :DSL                   , 'fastfood/dsl'
  autoload :Manifest              , 'fastfood/manifest'
  autoload :Trampoline            , 'fastfood/trampoline'

  module Franchises
    autoload :Franchise , 'fastfood/Franchises/franchise'
    autoload :Linux     , 'fastfood/Franchises/linux'
  end

  module Services
    autoload :AptGetInstaller   , 'fastfood/services/apt_get_installer'
    autoload :ConfigChange      , 'fastfood/services/config_change'
    autoload :LinuxFile         , 'fastfood/services/linux_file'
    autoload :LinuxFileSystem   , 'fastfood/services/linux_file_system'
    autoload :LinuxFolder       , 'fastfood/services/linux_folder'
    autoload :LinuxFolderBundle , 'fastfood/services/linux_folder_bundle'
    autoload :LinuxSwapfile     , 'fastfood/services/linux_swapfile'
    autoload :LinuxUser         , 'fastfood/services/linux_user'
    autoload :Postgres          , 'fastfood/services/postgres'
    autoload :Service           , 'fastfood/services/service'
    autoload :SourceInstaller   , 'fastfood/services/source_installer'
    autoload :UfwFirewall       , 'fastfood/services/ufw_firewall'
    autoload :User              , 'fastfood/services/user'
  end

end

require 'fastfood/extensions/extensions'