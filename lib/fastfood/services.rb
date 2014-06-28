module Fastfood
  module Services
    autoload :AptGetInstaller , 'fastfood/services/apt_get_installer'
    autoload :ConfigChange    , 'fastfood/services/config_change'
    autoload :LinuxUser       , 'fastfood/services/linux_user'
    autoload :LinuxSwapfile   , 'fastfood/services/linux_swapfile'
    autoload :Service         , 'fastfood/services/service'
    autoload :User            , 'fastfood/services/user'
  end
end