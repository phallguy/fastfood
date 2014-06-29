module Fastfood
  module Services
    class SourceInstaller < Fastfood::Services::Service

      private
        def run_with_data( data )
          tmp_path = "~/sources/#{SecureRandom.uuid}"

          download_source  tmp_path , data
          verify_signature tmp_path , data
          make             tmp_path , data

        ensure
          cleanup          tmp_path , data
        end

        def download_source( tmp_path, data )
          on_host do
            execute "rm -rf #{tmp_path} && mkdir -p #{tmp_path}"
            within tmp_path do
              execute :wget, "--quiet --output-document=source.tgz  #{ data[:source] }"
            end
          end
        end

        def verify_signature( tmp_path, data )
          return unless data[:sha]

          on_host do
            within tmp_path do
              upload! StringIO.new( "#{data[:sha]} source.tgz" ), "/tmp/sha1"
              execute :mv, "/tmp/sha1 ."
              execute :sha1sum, "-c sha1"
            end
          end
        end

        def make( tmp_path, data )
          on_host do
            within tmp_path do
              execute :tar, "--strip-components 1 -xzvf source.tgz"
              within data[:make] do
                execute :make
                sudo :make, "install"
              end
            end
          end
        end

        def cleanup( tmp_path, data )
          on_host do
            execute "rm -rf #{tmp_path}" unless data[:keep]
          end
        end
    end
  end
end