module Fastfood
  module Franchises
    class Franchise
      def initialize
        @services = {}
      end

      def service( subject, host )
        if service = services[subject]
          service.respond_to?(:call) ? service.call( host, self ) : service.new( host, self )
        else
          fail "#{self.class.name} doesn't know how to provision #{subject}"
        end
      end

      private

        attr_reader :services

        def register_service( subject, service )
          services[subject] = service
        end
    end
  end
end