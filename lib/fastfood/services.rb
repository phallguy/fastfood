module Fastfood
  module Services
    autoload :AptGetInstaller , 'fastfood/services/apt_get_installer'
    autoload :LinuxUser       , 'fastfood/services/linux_user'
    autoload :Service         , 'fastfood/services/service'
    autoload :User            , 'fastfood/services/user'
  end
end