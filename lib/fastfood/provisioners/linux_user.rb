require 'fastfood/provisioners/user'

module Fastfood
  module Provisioners
    class LinuxUser < Fastfood::Provisioners::User

      private
        def run_with_data( data )
          on host do
            data.each do |username,attributes|

              unless test("id -u #{username}")
                execute :useradd, "--create-home --shell #{attributes.fetch(:shell,"/bin/bash")} #{username}"
              end

              home_dir        = capture( "eval echo ~#{username}" )
              ssh_dir         = File.join home_dir, ".ssh"
              authorized_keys = File.join( ssh_dir, "authorized_keys")

              execute :mkdir, "-p #{ssh_dir}"
              binding.pry
              upload! StringIO.new( attributes[:ssh_key] ), authorized_keys
              execute :chown, " #{username}:#{username} #{authorized_keys}"
              execute :chmod, " a+r #{authorized_keys}"
            end
          end
        end

    end
  end
end