require 'spec_helper'
require 'fastfood'
require 'fastfood/configuration'

describe Fastfood::Configuration do

  describe "#package" do

    it "adds to the system_packages setting" do
      Fastfood.configure do
        package "git"
      end

      expect( Capistrano::Configuration.env.fetch(:system_packages)[:all] ).to have_key :git
    end

    it "adds each of a variable array to the system_packages setting" do
      Fastfood.configure do
        package "git", "git-core"
      end

      expect( Capistrano::Configuration.env.fetch(:system_packages)[:all] ).to have_key :git
      expect( Capistrano::Configuration.env.fetch(:system_packages)[:all] ).to have_key :'git-core'
    end

    it "adds each of a fixed array to the system_packages setting" do
      Fastfood.configure do
        package %w{ git git-core }
      end

      expect( Capistrano::Configuration.env.fetch(:system_packages)[:all] ).to have_key :git
      expect( Capistrano::Configuration.env.fetch(:system_packages)[:all] ).to have_key :'git-core'
    end

    it "adds complete package details from hash" do
      Fastfood.configure do
        package git: { version: "2.1" }
      end

      expect( Capistrano::Configuration.env.fetch(:system_packages)[:all] ).to have_key :git
    end

    it "only adds to given roles" do
      Fastfood.configure do
        package "newrelic", roles: :web
      end

      expect( Capistrano::Configuration.env.fetch(:system_packages)[:web] ).to     have_key :newrelic
      expect( Capistrano::Configuration.env.fetch(:system_packages)[:all] ).not_to have_key :newrelic
    end



  end
end
