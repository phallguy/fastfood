require 'fastfood/services/linux_user'
require 'fastfood/services/apt_get_installer'

module Fastfood
  module Franchises
    class Linux < Fastfood::Franchises::Franchise

      def initialize
        super

        register_service :user             , Fastfood::Services::LinuxUser
        register_service :install          , Fastfood::Services::AptGetInstaller
        register_service :source_installer , Fastfood::Services::SourceInstaller
        register_service :swapfile         , Fastfood::Services::LinuxSwapfile
        register_service :config_change    , Fastfood::Services::ConfigChange
        register_service :file             , Fastfood::Services::LinuxFile
      end
    end
  end
end
