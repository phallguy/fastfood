require 'spec_helper'

describe Fastfood::Services::AptGetInstaller do
  let(:host){ Capistrano::Configuration::Server.new( "deploy@example.com" ) }
  let(:installer){ Fastfood::Services::AptGetInstaller.new( host ) }

  before(:each) do
    installer.stub(:on_host)
  end

  it "tries to install packages" do
    expect(installer).to receive :install_packages
    installer.run packages: { all: [] }
  end

  it "uses packages only for the target host" do
    expect(installer).to receive :packages_for_host
    installer.run packages: { all: [] }
  end

  describe "#packages_for_host" do
    let(:packages) do
      {
        all: [:git],
        web: [:nginx],
        app: [:rails]
      }
    end

    it "gets only all when no roles" do
      blended = installer.send :packages_for_host, packages
      expect(blended).to include :git
      expect(blended).not_to include :nginx
      expect(blended).not_to include :rails
    end

    it "gets all and web for web roles" do
      host.add_role :web
      blended = installer.send :packages_for_host, packages
      expect(blended).to include :git
      expect(blended).to include :nginx
      expect(blended).not_to include :rails
    end
  end
end