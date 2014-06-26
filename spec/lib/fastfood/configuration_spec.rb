require 'spec_helper'
require 'fastfood'
require 'fastfood/configuration'

describe Fastfood::Configuration do

  describe "#package" do

    it "adds to the required_pacakges setting" do
      Fastfood.configure do
        package "git"
      end

      expect( Capistrano::Configuration.env.fetch(:system_packages)[:all] ).to include "git"
    end

  end
end