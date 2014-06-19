require 'fastfood/provisioners/user'

module Fastfood
  module Provisioners
    class LinuxUser < Fastfood::Provisioners::User

      private
        def run_with_data( data )
          data.each do |username,attributes|
            next unless should_run?( attributes )
            create_user    username, attributes
            authorize_keys username, attributes[:ssh_keys]
            assign_groups  username, attributes[:groups]
            make_sudoer    username                       if attributes[:sudo]
          end
        end

        def create_user( username, attributes )
          on_host do
            unless test("id -u #{username}")
              sudo :useradd, "--create-home --shell #{attributes.fetch(:shell,"/bin/bash")} #{username}"
            end
          end
        end

        def authorize_keys( username, keys )
          on_host do
            home_dir        = capture( "eval echo ~#{username}" )
            ssh_dir         = File.join home_dir, ".ssh"
            authorized_keys = File.join( ssh_dir, "authorized_keys")

            sudo :mkdir, "-p #{ssh_dir}"
            sudo :chown, "-R #{username}:#{username} #{ssh_dir}"

            sudo_upload! StringIO.new( Array( keys ).join("\n") ), authorized_keys
            sudo :chown, " #{username}:#{username} #{authorized_keys}"
            sudo :chmod, " a+r #{authorized_keys}"
            # Require keys
            sudo :passwd, " -l #{username}"
          end
        end

        def assign_groups( username, groups )
          groups = Array( groups )
          return if groups.empty?

          on_host do
            groups.each do |group|
              sudo :groupadd, " --force #{group}"
            end
            sudo :usermod, " --groups #{groups.join ' '} #{username}"
          end
        end

        def make_sudoer( username )
          on_host do
            sudoer = File.join( "/etc/sudoers.d", username.to_s )
            sudo_upload! StringIO.new( "#{username} ALL=(ALL) NOPASSWD: ALL" ), sudoer do |sudoer|
              sudo :chown, "root:root", sudoer
            end
          end
        end

    end
  end
end