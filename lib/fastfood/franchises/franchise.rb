module Fastfood
  module Franchises
    class Franchise
      def initialize
        @provisioners = {}
      end

      def provisioner( subject, host )
        if provisioner = provisioners[subject]
          provisioner.respond_to?(:call) ? provisioner.call( host ) : provisioner.new( host )
        else
          fail "#{self.class.name} doesn't know how to provision #{subject}"
        end
      end

      private

        attr_reader :provisioners

        def register_provisioner( subject, provisioner )
          provisioners[subject] = provisioner
        end
    end
  end
end