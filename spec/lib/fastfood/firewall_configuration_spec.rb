require 'spec_helper'

describe Fastfood::FirewallConfiguration do

  let(:firewall_config){ Fastfood::FirewallConfiguration.new }
  let(:rules){ config[:rules] }
  let(:rule){ rules.first }

  describe "#port" do
    it "converts named port to number" do
      expect( firewall_config.send :_port, :http ).to eq 80
    end

    it "returns integers" do
      expect( firewall_config.send :_port, 99 ).to eq 99
    end
  end

  describe "#well_known" do
    it "adds a new port" do
      config = firewall_config.build do
        well_known :apples, 1234
      end

      expect( config[:well_known][:apples] ).to eq 1234
    end
  end

  describe "#allow" do
    let(:config) do
      firewall_config.build do
        allow :http, :https, roles: :web, from: :app, protocol: :tcp
      end
    end

    it "creates an allow rule" do
      expect( rule[:command] ).to eq :allow
    end

    it "supports any port from a specific address" do
      config = firewall_config.build do
        allow from: :app
      end

      expect( config[:rules].first ).not_to have_key :port
    end

    it "supports 'to' as an alias for 'roles'" do
      config = firewall_config.build do
        allow :http, to: :alias
      end

      expect( config[:rules].first[:roles] ).to eq [:alias]
    end

    it "supports 'on' as an alias for 'roles'" do
      config = firewall_config.build do
        allow :http, on: :db
      end

      expect( config[:rules].first[:roles] ).to eq [:db]
    end

    it "sets the destinations" do
      expect( rule[:roles] ).to eq [:web]
    end

    it "sets the port" do
      expect( rule[:port] ).to eq 80
    end

    it "adds rules for each port" do
      expect( rules.length ).to eq 2
    end

    it "sets the protocol" do
      expect( rule[:protocol] ).to eq [:tcp]
    end

    it "sets the ip address for all from addresses" do
      expect( rule[:from] ).to eq [:app]
    end
  end

  describe "#deny" do
    let(:config) do
      firewall_config.build do
        deny :http, :https, on: :web, from: :app
      end
    end

    it "creates a deny rule" do
      expect( rule[:command] ).to eq :deny
    end
  end

  describe "#custom" do
    let(:config) do
      firewall_config.build do
        custom "reload"
      end
    end

    it "sets the args" do
      expect( rule[:args] ).to eq "reload"
    end

    it "doesn't set a command" do
      expect( rule ).not_to have_key :command
    end
  end

end
