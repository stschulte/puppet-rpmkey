#!/usr/bin/env ruby

require 'spec_helper'

describe Puppet::Type.type(:rpmkey).provider(:rpm), '(integration)' do

  before :each do
    described_class.stubs(:suitable?).returns true
#    Puppet::Type.type(:rpmkey).stubs(:defaultprovider).returns described_class
  end

  # this resource is already absent
  let :resource_absent do
    Puppet::Type.type(:rpmkey).new(
      :name   => '352C64E5',
      :ensure => :absent
    )
  end

  # this resource is already present
  let :resource_present do
    Puppet::Type.type(:rpmkey).new(
      :name   => '8E1431D5',
      :ensure => :present,
      :source => '/tmp/8E1431D5'
    )
  end

  # this resource is not yet present
  let :resource_create do
    Puppet::Type.type(:rpmkey).new(
      :name        => '2D762E88',
      :ensure      => :present,
      :source      => '/tmp/2D762E88'
    )
  end

  # this resource is not yet absent
  let :resource_delete do
    Puppet::Type.type(:rpmkey).new(
      :name   => '8E1431D5',
      :ensure => :absent
    )
  end

  def run_in_catalog(*resources)
    catalog = Puppet::Resource::Catalog.new
    catalog.host_config = false
    resources.each do |resource|
      resource.expects(:err).never
      catalog.add_resource(resource)
    end
    described_class.expects(:rpm).with('-q', 'gpg-pubkey', '--xml').
      returns File.read(fixtures('unit/provider/rpmkey/rpm/rpm_q_xml'))
    catalog.apply
  end

  describe "when managing one resource" do
    describe "with ensure set to absent" do
      it "should do nothing if key is already absent" do
        described_class.any_instance.expects(:rpm).never
        run_in_catalog(resource_absent)
      end

      it "should erase corresponsing package if key currently present" do
        described_class.any_instance.expects(:rpm).with('-e', '--allmatches', 'gpg-pubkey-8e1431d5-53bcbac7')
        run_in_catalog(resource_delete)
      end
    end

    describe "with ensure set to present" do
      it "should do nothing if already present and in sync" do
        described_class.any_instance.expects(:rpm).never
        run_in_catalog(resource_present)
      end

      it "should import the key if corresponding package is currently absent" do
        described_class.any_instance.expects(:rpm).with('--import', '/tmp/2D762E88')
        run_in_catalog(resource_create)
      end
    end
  end
end
