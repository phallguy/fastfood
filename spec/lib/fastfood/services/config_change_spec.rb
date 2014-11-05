require 'spec_helper'

describe Fastfood::Services::ConfigChange do
  let(:fstab){ fixture_file( "fstab" ).read }
  let(:sysctl){ fixture_file( "sysctl.conf" ).read }
  let(:host){ Capistrano::Configuration::Server.new( "deploy@example.com" ) }
  let(:config_change){ Fastfood::Services::ConfigChange.new( host, nil ) }

  context "virgin config" do

    describe "change entry" do
      before(:each) do
        @modified = nil
        expect(config_change).to receive(:read_config_file).and_return( fstab )
        expect(config_change).to receive(:write_config_file){ |modified,_| @modified = modified }

        config_change.run \
          file: "/pretend/fstab",
          changes: { id: "swap", entry: "happy happy joy joy" }
      end

      it "should modifiy the config" do
        expect( @modified ).to include "happy happy joy joy"
      end

      it "should tag changes" do
        expect( @modified ).to match /^# BEGIN FASTFOOD \[swap\]/
        expect( @modified ).to match /^# END FASTFOOD \[swap\]/
      end
    end

    describe "change key value" do
      before(:each) do
        @modified = nil
        expect(config_change).to receive(:read_config_file).and_return( sysctl )
        expect(config_change).to receive(:write_config_file){ |modified,_| @modified = modified }

        config_change.run \
          file: "/pretend/sysctl.conf",
          changes: [
            { key: "vm.swappiness", value: 10 },
            { key: "net.core.wmem_max", value: 5000 }
          ]
      end

      it "should add to the config" do
        expect( @modified ).to include "vm.swappiness=10"
      end

      it "should tag changes" do
        expect( @modified ).to match /^# BEGIN FASTFOOD \[vm\.swappiness\]/m
        expect( @modified ).to match /^# END FASTFOOD \[vm\.swappiness\]/
      end

      it "changes existing values" do
        expect( @modified ).to include "net.core.wmem_max=5000"
        expect( @modified ).not_to include "net.core.wmem_max=12582912"
      end

      it "tags changes to existing values" do
        expect( @modified ).to match /^# BEGIN FASTFOOD \[net\.core\.wmem_max\]/m
        expect( @modified ).to match /^# END FASTFOOD \[net\.core\.wmem_max\]/
      end

    end
  end

  context "config with existing changes" do
    describe "change entry" do
      before(:each) do
        @modified = nil
        expect(config_change).to receive(:read_config_file).and_return( fstab )
        expect(config_change).to receive(:write_config_file){ |modified,_| @modified = modified }.twice

        config_change.run \
          file: "/pretend/fstab",
          changes: { id: "swap", entry: "happy happy joy joy" }

        expect(config_change).to receive(:read_config_file).and_return( @modified )
        config_change.run \
          file: "/pretend/fstab",
          changes: { id: "swap", entry: "beans and franks" }
      end

      it "should modifiy the config" do
        expect( @modified ).to include "beans and franks"
      end

      it "should remove the old config" do
        expect( @modified ).not_to include "happy happy joy joy"
      end

      it "should tag changes" do
        expect( @modified ).to match /^# BEGIN FASTFOOD \[\w+\]/
        expect( @modified ).to match /^# END FASTFOOD \[\w+\]/
      end
    end

    describe "change key value" do
      before(:each) do
        @modified = nil
        expect(config_change).to receive(:read_config_file).and_return( sysctl )
        expect(config_change).to receive(:write_config_file){ |modified,_| @modified = modified }.twice

        config_change.run \
          file: "/pretend/sysctl.conf",
          changes: { key: "vm.swappiness", value: 10 }

        expect(config_change).to receive(:read_config_file).and_return( @modified )
        config_change.run \
          file: "/pretend/sysctl.confi",
          changes: { key: "vm.swappiness", value: 15 }

      end

      it "should modify the config" do
        expect( @modified ).to include "vm.swappiness=15"
      end

      it "should remove the old config" do
        expect( @modified ).not_to include "vm.swappiness=10"
      end

    end
  end

end
