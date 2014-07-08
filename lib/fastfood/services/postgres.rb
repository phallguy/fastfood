module Fastfood
  module Services
    class Postgres < Fastfood::Services::User

      private

        def run_with_data( data )
          create_user( data )
          create_db( data )
          run_sql( data )
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
            unless db_exists?( data, create[:name] )
              unless psql data, "-c", %Q{ "CREATE database #{create[:name]} owner #{create[:owner]}" }
                error "PG database #{create[:name]} could not be created."
                exit 1
              end
            end

            Array(create[:extensions]).each do |extension|
              psql data, "-c", %Q{"CREATE EXTENSION IF NOT EXISTS #{extension} "}
            end
          end
        end

        def run_sql( data )
          return unless command = data[:command]

          psql data, "-c", %Q{"#{command}"}
        end
    end
  end
end