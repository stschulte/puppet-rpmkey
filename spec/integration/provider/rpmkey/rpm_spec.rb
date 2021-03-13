#!/usr/bin/env ruby

require 'spec_helper'

describe Puppet::Type.type(:rpmkey).provider(:rpm) do
  let(:catalog) { Puppet::Resource::Catalog.new }
  let :rpm_q_output do
    <<EOS
gpg-pubkey-db42a60e-37ea5438
gpg-pubkey-4f2a6fd2-3f9d9d3b
gpg-pubkey-23a254d4-41ddbc46
EOS
  end
  let :resource_absent do
    Puppet::Type.type(:rpmkey).new(
      name: '352C64E5',
      ensure: :absent,
    )
  end
  let :resource_present do
    Puppet::Type.type(:rpmkey).new(
      name: '4F2A6FD2',
      ensure: :present,
      source: '/tmp/4F2A6FD2',
    )
  end
  let :resource_create do
    Puppet::Type.type(:rpmkey).new(
      name: '2D762E88',
      ensure: :present,
      source: '/tmp/2D762E88',
    )
  end
  let :resource_delete do
    Puppet::Type.type(:rpmkey).new(
      name: '23A254D4',
      ensure: :absent,
    )
  end

  before :each do
    allow(described_class).to receive(:suitable?).and_return true
  end

  def run_in_catalog(*resources)
    catalog.host_config = false
    resources.each do |resource|
      expect(resource).to receive(:err).never
      catalog.add_resource(resource)
    end
    expect(described_class).to receive(:rpm).with('-q', 'gpg-pubkey').and_return rpm_q_output
    catalog.apply
  end

  describe 'when managing one resource' do
    describe 'with ensure set to absent' do
      it 'does nothing if key is already absent' do
        run_in_catalog(resource_absent)
      end

      it 'erases corresponsing package if key currently present' do
        expect(described_class).to receive(:rpm).with('-e', '--allmatches', 'gpg-pubkey-23a254d4')
        run_in_catalog(resource_delete)
      end
    end

    describe 'with ensure set to present' do
      it 'does nothing if already present and in sync' do
        run_in_catalog(resource_present)
      end

      it 'imports the key if corresponding package is currently absent' do
        expect(described_class).to receive(:rpm).with('--import', '/tmp/2D762E88')
        run_in_catalog(resource_create)
      end
    end
  end
end
