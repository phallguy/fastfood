module Helpers
  module FixtureHelpers

    def fixture_file( *args, &block)
      path = fixture_file_path( args.first )
      args[0] = path
      File.open *args, &block
    end

    def fixture_file_path( path )
      File.join( fixture_path, path )
    end

    def fixture_path=( value )
      @fixture_path = value
    end

    def fixture_path
      @fixture_path ||= File.expand_path "../../../fixtures", __FILE__
    end

  end
end