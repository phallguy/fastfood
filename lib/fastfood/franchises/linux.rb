require 'fastfood/provisioners/linux_user'

module Fastfood
  module Franchises
    class Linux < Fastfood::Franchises::Franchise

      def initialize
        super

        register_provisioner :user, Fastfood::Provisioners::LinuxUser
      end
    end
  end
end
