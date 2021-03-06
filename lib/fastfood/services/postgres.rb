module Fastfood
  module Services
    class Postgres < Fastfood::Services::User

      private

        def run_with_data( data )
          config( data )
          create_user( data )
          create_db( data )
          run_sql( data )
          download_db( data )
        end

        # Blatantly ripped from https://github.com/bruno-/capistrano-postgresql/blob/master/lib/capistrano/postgresql/psql_helpers.rb
        def psql( data, *args)
          result = nil
          on_host do
            result = test :sudo, "-u #{data[:user]} psql", *args
          end
          result
        end

        def db_user_exists?( data, name )
          psql data, '-tAc', %Q{"SELECT 1 FROM pg_roles WHERE rolname='#{name}';" | grep -q 1}
        end

        def db_exists?( data, db_name )
          psql data, '-tAc', %Q{"SELECT 1 FROM pg_database WHERE datname='#{db_name}';" | grep -q 1}
        end

        def create_user( data )
          return unless create = data[:create_user]
          cmd = db_user_exists?( data, create[:username] ) ? "ALTER" : "CREATE"
          on_host do
            unless psql data, "-c", %Q{ "#{ cmd } user #{create[:username]} WITH password '#{create[:password]}'" }
              error "PG #{create[:username]} could not be created."
              exit 1
            end
          end
        end

        def create_db( data )
          return unless create = data[:create_db]

          on_host do
            unless db_exists?( data, data[:database] )
              unless psql data, "-c", %Q{ "CREATE database #{data[:database]} owner #{data[:owner]}" }
                error "PG database #{data[:database]} could not be created."
                exit 1
              end
            end

            Array(create[:extensions]).each do |extension|
              psql data, "-d", data[:database], "-c", %Q{"CREATE EXTENSION IF NOT EXISTS #{extension} "}
            end
          end
        end

        def config( data )
          return unless config = data[:config]

          entries     = permitted_host_entries( config, data )
          config_file = File.join( config[:config_dir], "pg_hba.conf" )

          run_service \
            :config_change,
            file: config_file,
            changes: { entry: entries, id: "app-permissions" }

          on_host do
            sudo :chown, "#{data[:user]}:#{data[:user]}", config_file
          end
        end

        def permitted_host_entries( config, data )
          servers = config[:servers] || roles( :app ).map(&:internal_hostname)
          entry = servers.map do |server|
            Fastfood.ip_addresses( server ).map do |addr|
              [
                "host #{data[:database]} #{data[:owner]} #{addr}/32 md5",
                "hostssl #{data[:database]} #{data[:owner]} #{addr}/32 md5",
                "host #{data[:database]} #{data[:user]} #{addr}/32 md5",
                "hostssl #{data[:database]} #{data[:user]} #{addr}/32 md5"
              ]
            end
          end.flatten.compact.join( $/ )
        end

        def run_sql( data )
          return unless command = data[:command]

          psql data, "-c", %Q{"#{command}"}
        end

        def download_db( data )
          return unless download = data[:download]

          result = nil

          server = roles( :db ).first.internal_hostname


          on_host do
            with_verbosity Logger::ERROR do
              # TODO Find a way to stream to the output file
              result = capture :sudo, "-u #{data[:user]} PGPASSWORD=#{ data[:password] } pg_dump -h #{ server } -U #{data[:owner]} --no-privileges --no-owner  -Fc -w #{ data[:database]}"
            end
          end

          File.open( "#{ download }.sqlc", 'wb' ) do |f|
            f.write result

            # BUG in SSHKit does not capture tailing 0 in output so pad out an
            # extra 16 null bytes
            f.write ?\0 * 5

          end

        rescue StandardError => e
          binding.pry
          raise
        end
    end
  end
end