module Fastfood
  module Services
    class LinuxFileSystem < Fastfood::Services::Service

      private
          def run_with_data( data )
          create_destination data
          set_mode( data[:destination], data[:mode] ) if data[:mode]
          set_owner( data[:destination], data[:owner], data[:group] ) if data[:owner] || data[:group]
        end

        def set_owner( path, owner, group = owner )
          chown = ""
          chown = "#{owner}"     if owner
          chown += ":#{group}"   if group

          on_host do
            if test( "[ -f '#{path}' ]")
              sudo :chown, chown, path unless chown.empty?
            end
          end
        end

        def set_mode( path, mode )
          return unless mode

          on_host do
            if test( "[ -f '#{path}' ]")
              sudo :chmod, mode, path
            end
          end
        end

        def create_destination( data )
          fail "#{self.class.name} does not implement #create_destination"
        end


    end
  end
end