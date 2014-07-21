module Fastfood
  module Services
    # Manages an IPTABLES firewal via UFW.
    class UfwFirewall < Fastfood::Services::Service

      private

        def run_with_data( data )
          if rules = data[:rules]
            apply_rules rules
          end

          ufw :disable  if data[:disable]
          ufw :enable   if data[:enable]
          ufw :status   if data[:status]
        end

        def apply_rules( rules )
          reset_rules
          rules.each do |rule|
            next unless should_run?( rule )
            apply_rule rule
          end
          clean_backups
        end

        def apply_rule( rule )
          if command = rule[:command]
            case command
            when :allow, :deny then
              apply_port_rule rule
            when :default
              apply_default_rule rule
            else
              fail "Don't know how to apply '#{command}' rules, try using #custom 'ufw commands'"
            end
          else
            ufw rule[:args]
          end
        end

        def apply_default_rule( rule )
          ufw :default, *rule[:args]
        end

        def apply_port_rule( rule )
          args = [rule[:command]]

          Array( rule[:protocol] || [:all] ).each do |protocol|

            protocol_args = args.dup
            protocol_args << "proto #{protocol}" unless protocol == :all
            protocol_args << "to any port #{rule[:port]}" if rule[:port]

            expand_hosts( rule[:from] || :any ).each do |from_host|
              host_args = protocol_args.dup

              host_args << "from #{from_host}" unless from_host == :any


              ufw *host_args
            end
          end
        end

        def expand_hosts( from )
          @resolve ||= Resolv.new

          Array( from ).map do |h|
            case h
            when :any
              h
            when Symbol
              expand_hosts( roles( h ) )
            when SSHKit::Host
              h.internal_ip_addresses
            else
              Fastfood.ip_addresses( h )
            end
          end.flatten.compact.uniq
        end

        def reset_rules
          on_host do
            ufw :reset
            # Always allow SSH connections cause it's too easy to break. Must
            # add a deny rule to disable ssh.
            sudo :ufw, "allow 22"
          end
        end

        def clean_backups
          on_host do
            execute :sudo, :rm, "-f /etc/ufw/*.rules.*"
          end
        end

        def ufw( *args )
          on_host do
            execute :echo, "'y' |", :sudo, :ufw, *args
          end
        end

    end
  end
end

