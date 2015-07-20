#!/usr/bin/env rspec

require 'spec_helper'

describe Puppet::Type.type(:rpmkey).provider(:rpm) do

  before :each do
    Puppet::Type.type(:rpmkey).stubs(:defaultprovider).returns described_class
  end

  describe ".instances" do
    it "should have an instances method" do
      expect(described_class).to respond_to(:instances)
    end

    it "should get installed rpm keys by running rpm -q" do
      described_class.expects(:rpm).with('-q', 'gpg-pubkey', '--xml').returns File.read(my_fixture('rpm_q_xml'))
      expect(described_class.instances.map(&:name)).to eq([
        '246110C1',
        '95A43F54',
        '8E1431D5'
      ])
    end

    it "should return an empty list if no key is installed" do
      described_class.expects(:rpm).with('-q', 'gpg-pubkey', '--xml').raises Puppet::ExecutionFailure, 'package gpg-pubkey is not installed'
      expect(described_class.instances).to be_empty
    end

    it "should warn and ignore unexpected output" do
      described_class.expects(:rpm).with('-q', 'gpg-pubkey', '--xml').returns File.read(my_fixture('rpm_q_xml_unexpected'))
      described_class.expects(:warning).with('Unexpected rpm output: Release property is undefined.')
      expect(described_class.instances.map(&:name)).to eq([
        '246110C1',
        '95A43F54',
        '8E1431D5'
      ])
    end
  end

  describe "#exists?" do
    it "should return true if the resource is present" do
      provider = described_class.new(:name => 'DB42A60E', :ensure => :present)
      expect(provider).to be_exists
    end

    it "should return false if the resource is absent" do
      provider = described_class.new(:name => 'DB42A60E', :ensure => :absent)
      expect(provider).not_to be_exists
    end
  end

  describe "#create" do
    it "should import the key" do
      provider = described_class.new(Puppet::Type.type(:rpmkey).new(
        :name   => 'DB42A60E',
        :source => 'http://example.com/foo',
        :ensure => :present
      ))
      provider.expects(:rpm).with('--import', 'http://example.com/foo')
      provider.create
    end

    it "should raise an error if no source is specified" do
      provider = described_class.new(Puppet::Type.type(:rpmkey).new(
        :name   => 'DB42A60E',
        :ensure => :present
      ))
      expect { provider.create }.to raise_error(Puppet::Error, /Cannot add key without a source/)
    end
  end

  describe "#destroy" do
    it "should remove the key" do
      provider = described_class.new(Puppet::Type.type(:rpmkey).new(
        :name   => 'DB42A60E',
        :source => 'http://example.com/foo',
        :ensure => :present
      ))
      # #package is "read-only"
      phash = provider.instance_variable_get(:@property_hash)
      phash[:package] = 'gpg-pubkey-db42a60e-12345678'
      provider.instance_variable_set(:@property_hash, phash)
      provider.expects(:rpm).with('-e', '--allmatches', 'gpg-pubkey-db42a60e-12345678')
      provider.destroy
    end

    it "should not complain about a missing source" do
      provider = described_class.new(Puppet::Type.type(:rpmkey).new(
        :name   => 'DB42A60E',
        :ensure => :absent
      ))
      # #package is "read-only"
      phash = provider.instance_variable_get(:@property_hash)
      phash[:package] = 'gpg-pubkey-db42a60e-12345678'
      provider.instance_variable_set(:@property_hash, phash)
      provider.expects(:rpm).with('-e', '--allmatches', 'gpg-pubkey-db42a60e-12345678')
      expect { provider.destroy }.to_not raise_error
    end
  end

  [
    :install_date,
    :build_date,
    :packager,
    :package,
  ].each do |property|
    describe "\##{property}" do
      it "should be read only" do
        provider = described_class.new(Puppet::Type.type(:rpmkey).new(
          :name   => 'DB42A60E',
          :ensure => :present
        ))
        # ruby 1.8.7 does not support #public_send
        expect { provider.send(property) }.to_not raise_error
        expect { provider.send("#{property}=".to_sym, 1) }.
          to raise_error(Puppet::Error, /#{property} is read-only/)
      end
    end
  end
end
