#!/usr/bin/env rspec

require 'spec_helper'

describe Puppet::Type.type(:rpmkey).provider(:rpm) do
  before :each do
    allow(Puppet::Type.type(:rpmkey)).to receive(:defaultprovider).and_return(described_class)
  end

  describe 'instances' do
    it 'has an instances method' do
      expect(described_class).to respond_to :instances
    end
  end

  describe 'prefetch' do
    it 'has a prefetch method' do
      expect(described_class).to respond_to :prefetch
    end
  end

  context 'self.instances multiple keys' do
    before :each do
      allow(described_class).to receive(:rpm).with('-q', 'gpg-pubkey').and_return(File.read(my_fixture('rpm_q')))
    end

    it 'returns all keys' do
      expect(described_class.instances.map(&:name)).to eq(['DB42A60E', '4F2A6FD2', '23A254D4'])
    end
  end

  context 'self.instances no key installed' do
    before :each do
      allow(described_class).to receive(:rpm).with('-q', 'gpg-pubkey').and_raise Puppet::ExecutionFailure, 'package gpg-pubkey is not installed'
    end

    it 'returns and empty list' do
      expect(described_class.instances).to be_empty
    end
  end

  context 'self.instances returns unexpected lines' do
    before :each do
      allow(described_class).to receive(:rpm).with('-q', 'gpg-pubkey').and_return(File.read(my_fixture('rpm_q_unexpected')))
    end

    it 'warns and ignore unexpected output' do
      expect(described_class).to receive(:warning).with('Unexpected rpm output "gpg-pubkey-4f2a6fd3". Ignoring this line.')
      expect(described_class.instances.map(&:name)).to eq(['DB42A60E', '4F2A6FD2', '23A254D4'])
    end
  end

  describe '#exists?' do
    it 'returns true if the resource is present' do
      provider = described_class.new(name: 'DB42A60E', ensure: :present)
      expect(provider).to be_exists
    end

    it 'returns false if the resource is absent' do
      provider = described_class.new(name: 'DB42A60E', ensure: :absent)
      expect(provider).not_to be_exists
    end
  end

  describe '#create' do
    it 'imports the key' do
      provider = described_class.new(Puppet::Type.type(:rpmkey).new(
        name: 'DB42A60E',
        source: 'http://example.com/foo',
        ensure: :present,
      ))
      expect(provider).to receive(:rpm).with('--import', 'http://example.com/foo')
      provider.create
    end

    it 'raises an error if no source is specified' do
      provider = described_class.new(Puppet::Type.type(:rpmkey).new(
        name: 'DB42A60E',
        ensure: :present,
      ))
      expect { provider.create }.to raise_error(Puppet::Error, %r{Cannot add key without a source})
    end
  end

  describe '#destroy' do
    it 'removes the key' do
      provider = described_class.new(Puppet::Type.type(:rpmkey).new(
        name: 'DB42A60E',
        source: 'http://example.com/foo',
        ensure: :absent,
      ))
      expect(provider).to receive(:rpm).with('-e', '--allmatches', 'gpg-pubkey-db42a60e')
      provider.destroy
    end

    it 'does not complain about a missing source' do
      provider = described_class.new(Puppet::Type.type(:rpmkey).new(
        name: 'DB42A60E',
        ensure: :absent,
      ))
      expect(provider).to receive(:rpm).with('-e', '--allmatches', 'gpg-pubkey-db42a60e')
      expect { provider.destroy }.not_to raise_error
    end
  end
end
