require 'spec_helper'
require 'fastfood'
require 'fastfood/dsl'

describe Fastfood::DSL do

  describe "#repo" do
    before(:each) do
      Fastfood.file_paths.clear
      Fastfood.file_paths << fixture_file_path( "data/inherited" )
      Fastfood.file_paths << fixture_file_path( "data/app" )
    end

    subject{ repo "users.json", merge: true }

    it{ should have_key :deploy }
    it{ should have_key :root }

    it "overrides inherited" do
      expect( subject[:johnq][:name] ).to eq "Publique"
    end

    it "retains inherited merged properties" do
      expect( subject[:johnq][:email] ).to eq "johnq@public.com"
    end
  end
end