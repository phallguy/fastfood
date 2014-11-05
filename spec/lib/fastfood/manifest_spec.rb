require 'spec_helper'

class TestManifest < Fastfood::Manifest
  public :path_for_bucket, :find_bucket, :save_bucket
end

describe Fastfood::Manifest do
  let(:bucket_path ){ "/opt/fastfood/manifest" }
  let(:host){ Capistrano::Configuration::Server.new( "deploy@example.com" ) }
  let(:manifest){ TestManifest.new( host, bucket_path ) }

  describe "#path_for_bucket" do
    {
      "users" => "users.json",
      "packages/git" => "packages/git.json",
      :bundle => "bundle.json"
    }.each do |name,expected|

      it "returns #{expected} for #{name}" do
        expect( manifest.path_for_bucket( name ) ).to eq File.join( bucket_path, expected )
      end
    end
  end

  describe "#find_bucket" do
    before(:each) do
      allow_any_instance_of(Fastfood::Trampoline::Spring).to \
        receive( :download! )
          .with("/opt/fastfood/manifest/users.json")
          .and_return("{}")
      allow_any_instance_of(Fastfood::Trampoline::Spring).to \
        receive( :test )
          .and_return(false)
    end

    it "gets a hash" do
      expect( manifest.find_bucket( :users ) ).to be_a Fastfood::Manifest::Bucket
    end
  end

  describe "#save_bucket" do
    before(:each) do
      allow_any_instance_of(Fastfood::Trampoline::Spring).to \
        receive( :sudo_upload! )
          .with( kind_of(StringIO), "/opt/fastfood/manifest/users.json" )
      allow_any_instance_of(Fastfood::Trampoline::Spring).to \
        receive( :sudo )
    end

    it "Uploads a json version of the bucket" do
      manifest.save_bucket( :users, {} )
    end
  end

  describe "#select" do
    before(:each) do
      expect(manifest).to receive(:find_bucket).and_return(Fastfood::Manifest::Bucket.new.dirty!)
      expect(manifest).to receive(:save_bucket)
    end

    it "yields" do
      expect{ |b| manifest.select( :users, &b ) }.to yield_with_args( kind_of Hash )
    end

  end

end
