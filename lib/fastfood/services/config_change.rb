module Fastfood
  module Services
    # Makes repeatable changes to configuration files to avoid countless
    # 'echo >> file' entries and sudoing and copying.
    class ConfigChange < Fastfood::Services::Service

      private

        def run_with_data( data )
          write_config_file( Change.new( read_config_file( data ), data ).make_changes, data )
        end

        def read_config_file( data )
          download! data.fetch(:file)
        end

        def write_config_file( modified, data )
          sudo_upload! StringIO.new( modified ), data.fetch(:file)
        end

        # Acutal change handler.
        class Change
          attr_accessor :contents, :data, :changes

          def initialize( contents, data )
            @contents = contents
            @data     = data
            @changes  = data.fetch(:changes)
            @changes  = [@changes] if @changes.is_a? Hash
            @changes  = Array(@changes)
          end

          def make_changes
            changes.each do |change|
              case
              when change[:entry] then change_entry( change )
              when change[:key]   then change_key( change )
              else fail "Don't know how to change #{change}"
              end
            end

            contents
          end

          private

            def line
              @line ||= data.fetch( :line_ending, $INPUT_RECORD_SEPARATOR )
            end

            def comment
              @comment ||= data.fetch( :line_comment, '#' )
            end

            def change_entry( change )
              range = find_fastfood_block( change.fetch(:id), ) || -1

              @contents[*Array(range)] = format_block( change.fetch(:id), change.fetch(:entry) )
            end

            def change_key( change, file_contents, data )

            end

            def format_block( id, block_contents )
              "#{line}#{comment} BEGIN FASTFOOD [#{id}] #{Time.now}#{line}"\
              "#{comment} Do not modify these lines. They will be overwritten on next fastfood run.#{line}"\
              "#{block_contents}#{line}"\
              "#{comment} END FASTFOOD [#{id}]#{line}"
            end

            def find_fastfood_block( id )
              # http://refiddle.com/15lj
              pattern = /(#{line}?#{comment}\s+BEGIN FASTFOOD.*(\[#{ Regexp.escape( id ) }\]).*#{comment}\s+END FASTFOOD \2\s+#{line}?)/m
              match   = pattern.match( contents ) || return

              match.offset(1)
            end
        end
    end
  end
end