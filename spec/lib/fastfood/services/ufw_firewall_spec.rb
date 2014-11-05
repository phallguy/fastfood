require 'spec_helper'

describe Fastfood::Services::UfwFirewall do

  let(:host){ Capistrano::Configuration::Server.new( "deploy@localhost" ) }
  let(:firewall){ Fastfood::Services::UfwFirewall.new( host, nil ) }

  describe "rules" do


    before(:each) do
      allow( firewall ).to receive( :reset_rules )
      allow( firewall ).to receive( :clean_backups )
      allow( firewall ).to receive( :should_run? ).and_return( true )
      allow( firewall ).to receive( :ufw )

      expect( firewall ).not_to receive( :on_host )
    end

    it "handles :any host" do
      expect( firewall ).to receive( :ufw )
        .with( :allow, "to any port 80" )

      firewall.run rules: [{ command: :allow, port: 80, on: :all }]
    end

    it "handles specific roles" do
      expect( firewall ).to receive( :ufw )
        .with( :allow, "to any port 80", "from 127.0.0.1" )

      expect( firewall ).to receive( :roles )
        .and_return([host])

      firewall.run rules: [{ command: :allow, port: 80, on: :all, from: :app }]
    end

    it "handles specific ip addresses" do
      expect( firewall ).to receive( :ufw )
        .with( :allow, "to any port 80", "from 8.8.8.8" )

      firewall.run rules: [{ command: :allow, port: 80, on: :all, from: "8.8.8.8" }]
    end

    it "handles domain names" do
      expect( firewall ).to receive( :ufw )
        .with( :allow, "to any port 80", "from 107.170.170.4" )

      firewall.run rules: [{ command: :allow, port: 80, on: :all, from: "beakered.com" }]
    end

  end

end
