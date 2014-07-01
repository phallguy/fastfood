module Fastfood
  module Services
    # Makes repeatable changes to configuration files to avoid countless
    # 'echo >> file' entries and sudoing and copying.
    class ConfigChange < Fastfood::Services::Service

      DEFAULT_LINE_COMMENT    = '#'
      DEFAULT_VALUE_SEPARATOR = '='

      private

        def run_with_data( data )
          write_config_file( Change.new( read_config_file( data ), data ).change, data )
        end

        def read_config_file( data )
          contents = ""
          file     = data.fetch(:file)

          on_host do
            if test( "[ -f #{file} ]" )
              contents = download! file
            end
          end

          contents
        end

        def write_config_file( modified, data )
          on_host do
            sudo_upload! StringIO.new( modified ), data.fetch(:file)
          end
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

          def change
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
              @line ||= data.fetch( :line_ending, $/ )
            end

            def comment
              @comment ||= data.fetch( :line_comment, DEFAULT_LINE_COMMENT )
            end

            def change_entry( change )
              range = find_fastfood_block( change.fetch(:id) ) || [-1]

              block = format_block( change.fetch(:id), change.fetch(:entry) )
              if @contents.length > 0
                @contents[*range] = block
              else
                @contents = block
              end
            end

            def change_key( change )
              key   = change.fetch( :key )
              entry = "#{key}#{change.fetch(:separator,DEFAULT_VALUE_SEPARATOR)}#{change.fetch(:value)}"
              id    = change.fetch( :id, key )

              range = find_fastfood_block( id ) || find_key_entry( change ) || [-1]
              @contents[*range] = format_block( id, entry )
            end

            def format_block( id, block_contents )
              "#{line}#{comment} BEGIN FASTFOOD [#{id}] v#{Fastfood::VERSION} #{Time.now}#{line}"\
              "#{comment} Do not modify these lines. They will be overwritten on next fastfood run.#{line}"\
              "#{block_contents}#{line}"\
              "#{comment} END FASTFOOD [#{id}]#{line}"
            end

            def find_fastfood_block( id )
              # http://refiddle.com/15lj
              ln      = Regexp.escape( line )
              pattern = /(#{ln}?#{comment}\s+BEGIN FASTFOOD.*(\[#{ Regexp.escape( id ) }\]).*#{comment}\s+END FASTFOOD \2\s+#{ln}?)/m
              match   = pattern.match( contents ) || return

              range = match.offset(1)
              [range[0],range[1]-range[0]]
            end

            def find_key_entry( change )
              # http://refiddle.com/15m1
              key       = Regexp.escape( change.fetch(:key)  )
              separator = Regexp.escape( change.fetch(:separator, DEFAULT_VALUE_SEPARATOR) )

              pattern   = /(^\s*#{ key }\s*#{ separator }\s*.*$)/
              match     = pattern.match( contents ) || return

              range = match.offset( 0 )
              [range[0],range[1]-range[0]]
            end
        end
    end
  end
end