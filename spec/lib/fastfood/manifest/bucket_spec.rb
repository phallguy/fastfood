require 'spec_helper'

describe Fastfood::Manifest::Bucket do

  describe "#older?" do
    let(:bucket){ Fastfood::Manifest::Bucket.new( { version: "0.1.1" } ) }

    it "detects newer version" do
      expect( bucket.older?( "0.2.2" ) ).to be_truthy
    end

    it "detects older version" do
      expect( bucket.older?( "0.1.0" ) ).to be_falsey
    end

    it "treats pre as older" do
      expect( bucket.older?( "0.1.1pre" ) ).to be_falsey
    end
  end

  it "is indifferent access" do
    bucket = Fastfood::Manifest::Bucket.new( type: "indifferent", "access" => true )

    expect( bucket["type"] ).to eq "indifferent"
    expect( bucket[:access] ).to be true
  end

  describe "dirty tracking" do
    let(:bucket){ Fastfood::Manifest::Bucket.new( name: "Prince" ) }

    it "shouldn't be dirty when created" do
      expect( bucket ).not_to be_dirty
    end

    it "should be dirty when modified" do
      bucket[:name] = "The Artist Formely Known As"
      expect( bucket ).to be_dirty
    end

    it "isn't dirty after cleaning" do
      bucket[:name] = "Some crazy symbol"
      bucket.clean!

      expect( bucket ).not_to be_dirty
    end
  end

end
