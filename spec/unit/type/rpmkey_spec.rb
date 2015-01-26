#!/usr/bin/env rspec

require 'spec_helper'

describe Puppet::Type.type(:rpmkey) do

  it "should have :name as its keyattribute" do
    expect(described_class.key_attributes).to eq([:name])
  end

  describe "when validating attributes" do
    [:name, :source, :provider].each do |param|
      it "should have a #{param} parameter" do
        expect(described_class.attrtype(param)).to eq(:param)
      end
    end

    [:ensure].each do |property|
      it "should have a #{property} property" do
        expect(described_class.attrtype(property)).to eq(:property)
      end
    end
  end

  describe "when validating value" do
    describe "for ensure" do
      it "should support present" do
        expect { described_class.new(:name => 'DB42A60E', :ensure => :present) }.to_not raise_error
      end

      it "should support absent" do
        expect { described_class.new(:name => 'DB42A60E', :ensure => :absent) }.to_not raise_error
      end

      it "should not support other values" do
        expect { described_class.new(:name => 'DB42A60E', :ensure => :foo) }.to raise_error(Puppet::Error, /Invalid value/)
      end
    end

    describe "for name" do
      it "should support a valid name" do
        expect { described_class.new(:name => '01230123', :ensure => :present) }.to_not raise_error
        expect { described_class.new(:name => 'DB42A60E', :ensure => :present) }.to_not raise_error
        expect { described_class.new(:name => 'ABCDEFAB', :ensure => :present) }.to_not raise_error
      end

      it "should not support an empty name" do
        expect { described_class.new(:name => '', :ensure => :present) }.to raise_error(Puppet::Error, /Name.*empty/)
      end

      it "should not support invalid names" do
        expect { described_class.new(:name => 'DB42A60G', :ensure => :present) }.to raise_error(Puppet:: Error, /Invalid key/)
        expect { described_class.new(:name => 'GB42A60E', :ensure => :present) }.to raise_error(Puppet:: Error, /Invalid key/)
        expect { described_class.new(:name => 'DB42A60E-DB42A60E', :ensure => :present) }.to raise_error(Puppet:: Error, /Invalid key/)
        expect { described_class.new(:name => ' DB42A60E', :ensure => :present) }.to raise_error(Puppet:: Error, /Invalid key/)
        expect { described_class.new(:name => 'DB42A60E ', :ensure => :present) }.to raise_error(Puppet:: Error, /Invalid key/)
        expect { described_class.new(:name => 'DB42 A60E', :ensure => :present) }.to raise_error(Puppet:: Error, /Invalid key/)
        expect { described_class.new(:name => 'DB42a60E', :ensure => :present) }.to raise_error(Puppet:: Error, /Invalid key/)
        expect { described_class.new(:name => 'dB42A60E', :ensure => :present) }.to raise_error(Puppet:: Error, /Invalid key/)
        expect { described_class.new(:name => 'DB42A60e', :ensure => :present) }.to raise_error(Puppet:: Error, /Invalid key/)
      end

    end

    describe "for source" do
      it "should support a local filename" do
        expect { described_class.new(:name => 'DB42A60E', :source => '/tmp/foo', :ensure => :present) }.to_not raise_error
      end
      it "should support a http link" do
        expect { described_class.new(:name => 'DB42A60E', :source => 'http://example.com/foo', :ensure => :present) }.to_not raise_error
      end
    end

    describe "autorequire" do
      let(:catalog){
        catalog = Puppet::Resource::Catalog.new
      }
      it "should autorequire a local file" do
        file = Puppet::Type.type(:file).new(:name => '/tmp/foo', :content => 'bar' )
        catalog.add_resource file
        key = described_class.new(:name => 'DB42A60E', :source => '/tmp/foo', :ensure => :present)
        catalog.add_resource key
        expect(key.autorequire.size).to eq(1)
      end
      it "should not fail on an absent source" do
         key = described_class.new(:name => 'DB42A60E', :ensure => :absent)
         expect { catalog.add_resource key }.to_not raise_error
         expect(key.autorequire.size).to eq(0)
      end
    end

  end
end
