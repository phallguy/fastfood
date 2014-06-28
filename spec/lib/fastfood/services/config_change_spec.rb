require 'spec_helper'

describe Fastfood::Services::ConfigChange do
  let(:fstab){ fixture_file( "fstab" ).read }
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
        expect( @modified ).to match /^# BEGIN FASTFOOD \[\w+\]/
        expect( @modified ).to match /^# END FASTFOOD \[\w+\]/
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
    end

  end

end