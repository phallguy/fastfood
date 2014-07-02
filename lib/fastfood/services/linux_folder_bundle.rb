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
          ensure_folder destination, data

          Dir[File.join(source,"*")].each do |file|
            if File.directory?( file )
              bundle_folder file, make_destination_path( source, destination, file ), data
            else
              bundle_file file, source, destination, data
            end
          end
        end

        def bundle_file( file, source, destination, data )
          on_host do
            File.open file do |f|
              dest = make_destination_path( source, destination, file )
              sudo_upload! f, dest
              set_owner dest, data[:owner], data[:group]
              set_mode dest, ( File.stat( file ).mode & 07777 ).to_s( 8 )
            end
          end
        end

        def make_destination_path( source, destination, file )
          File.join( destination, file[source.length..-1] )
        end

        def ensure_folder( folder, data )
          on_host do
            sudo :mkdir, "-p #{folder}"
            set_owner folder , data[:owner] , data[:group]
            set_mode  folder , data[:mode]
          end
        end

    end
  end
end