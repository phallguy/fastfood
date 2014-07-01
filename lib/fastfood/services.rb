module Fastfood
  module Services
    autoload :AptGetInstaller   , 'fastfood/services/apt_get_installer'
    autoload :ConfigChange      , 'fastfood/services/config_change'
    autoload :LinuxUser         , 'fastfood/services/linux_user'
    autoload :LinuxSwapfile     , 'fastfood/services/linux_swapfile'
    autoload :LinuxFile         , 'fastfood/services/linux_file'
    autoload :LinuxFileSystem   , 'fastfood/services/linux_file_system'
    autoload :LinuxFolder       , 'fastfood/services/linux_folder'
    autoload :LinuxFolderBundle , 'fastfood/services/linux_folder_bundle'
    autoload :Service           , 'fastfood/services/service'
    autoload :SourceInstaller   , 'fastfood/services/source_installer'
    autoload :User              , 'fastfood/services/user'
  end
end