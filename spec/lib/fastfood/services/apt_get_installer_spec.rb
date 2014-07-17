require 'spec_helper'

describe Fastfood::Services::AptGetInstaller do
  let(:host){ Capistrano::Configuration::Server.new( "deploy@example.com" ) }
  let(:installer){ Fastfood::Services::AptGetInstaller.new( host, nil ) }

  before(:each) do
    allow( installer ).to receive(:on_host)
  end

  it "tries to install packages" do
    expect(installer).to receive :install_packages
    installer.run packages: { all: {} }
  end

  it "uses packages only for the target host" do
    expect(installer).to receive( :packages_for_host ).and_return([])
    installer.run packages: { all: {} }
  end

  describe "#packages_for_host" do
    let(:packages) do
      {
        all: { git: true },
        web: { nginx: true },
        app: { rails: true }
      }
    end

    it "gets only all when no roles" do
      blended = installer.send :packages_for_host, packages
      expect(blended).to      have_key :git
      expect(blended).not_to  have_key :nginx
      expect(blended).not_to  have_key :rails
    end

    it "gets all and web for web roles" do
      host.add_role :web
      blended = installer.send :packages_for_host, packages
      expect(blended).to     have_key :git
      expect(blended).to     have_key :nginx
      expect(blended).not_to have_key :rails
    end
  end

  describe "#packages_to_command" do
    let(:packages) do
      {
        git: true,
        nginx: { version: "1.3" }
      }
    end

    it "works" do
      commands = installer.send :packages_to_command, packages
      expect( commands ).to eq "git nginx=1.3"
    end
  end
end