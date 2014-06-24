require 'fastfood/services/linux_user'
require 'fastfood/services/apt_get_installer'

module Fastfood
  module Franchises
    class Linux < Fastfood::Franchises::Franchise

      def initialize
        super

        register_service :user, Fastfood::Services::LinuxUser
        register_service :install, Fastfood::Services::AptGetInstaller
      end
    end
  end
end
