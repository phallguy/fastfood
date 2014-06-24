require 'spec_helper'
require 'fastfood'

describe Fastfood do

  describe "#find_files" do
    before(:each) do
      Fastfood.file_paths.clear
      Fastfood.file_paths << fixture_file_path( "data/inherited" )
      Fastfood.file_paths << fixture_file_path( "data/app" )
    end

    it "finds them all" do
      expect( Fastfood.find_files("users.json").size ).to eq 2
    end

    it "fins the app version first" do
      expect( Fastfood.find_files("users.json").first ).to match /app/
    end

  end

end
