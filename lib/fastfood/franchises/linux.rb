require 'fastfood/provisioners/linux_user'
require 'fastfood/provisioners/apt_get_installer'

module Fastfood
  module Franchises
    class Linux < Fastfood::Franchises::Franchise

      def initialize
        super

        register_provisioner :user, Fastfood::Provisioners::LinuxUser
        register_provisioner :install, Fastfood::Provisioners::AptGetInstaller
      end
    end
  end
end
