module Fastfood
  # Provide a trampoline for some of SSHKit's dsl methods to allow blocks to
  # access methods of the binding they were invoked from.
  module Trampoline

    # Invokes SSHKit's `on` method with a trampoline for self.
    def on_trampoline( *args, &block )
      bind = self
      on *args do
        Spring.new( bind, self ).bounce &block
      end
    end

    # Supports blending class methods and backend dsl methods. When `on backend`
    # is invoked, the block is executed with the backend as self making it
    # impossible to invoke other methods on the binding object without keeping
    # a reference to 'self' and making the methods public. This helper class
    # offers a blended binding that will invoke methods on the binding object
    # first, then on the backend binding.
    class Spring < BasicObject
      def initialize( binding, backend )
        @binding = binding;
        @backend = backend;
      end

      def bounce(&block)
        instance_eval(&block)
      end

      def method_missing( name, *args, &block )
        if @backend.respond_to?( name, true )
          return @backend.send( name, *args, &block )
        elsif @binding.respond_to?( name, true )
          return @binding.send( name, *args, &block )
        end

        super
      rescue ::StandardError => e
        ::Kernel.binding.pry
        ::Kernel.fail
      end

      def respond_to?( *args )
        @binding.respond_to?( *args ) || @backend.respond_to?( *args )
      end
    end
  end
end