module Fastfood
  module Services
    class LinuxFolderBundle < Fastfood::Services::LinuxFileSystem

      private
        def create_destination( data )
          on_host do
            manifest.select data.fetch(:id) do |manifest|
              next unless manifest.older?( data.fetch(:version) ) || data[:force]

              bundle_folder( data[:source], data[:destination], data )
              manifest[:version] = data[:version]
            end
          end
        end

        def bundle_folder( source, destination, data )
          on_host do
            sudo :mkdir, "-p #{destination}"
            set_owner destination, data[:owner], data[:group]
            set_mode destination, data[:mode]

            Dir[File.join(source,"*")].each do |file|
              if File.directory?( file )
                bundle_folder file, make_destination_path( source, destination, file ), data
              else
                File.open file do |f|
                  dest = make_destination_path( source, destination, file )
                  sudo_upload! f, dest
                  set_owner dest, data[:owner], data[:group]
                  set_mode dest, ( File.stat( file ).mode & 07777 ).to_s( 8 )
                end
              end
            end
          end
        end

        def make_destination_path( source, destination, file )
          File.join( destination, file[source.length..-1] )
        end

    end
  end
end