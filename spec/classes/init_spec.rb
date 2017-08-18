require 'spec_helper'

describe 'rpmkey', :type => :class do
  context 'with defaults for all parameters' do
    it { should contain_class('rpmkey') }
  end
  context 'with key specified in hiera and hiera_merge disabled' do
    let(:facts) do
      {
        :osfamily => 'RedHat',
        :fqdn => 'hieranomerge.example.com',
        :lsbmajdistversion => '6',
      }
    end
    it { should contain_class('rpmkey') }
    it { should contain_rpmkey('0608B895').with({
      'ensure' => 'present',
      'source' => 'https://fedoraproject.org/static/0608B895.txt',
    })
    }
  end
  context 'with multiple key specified in hiera with hiera_merge disabled' do
    let(:facts) do
      {
        :osfamily => 'RedHat',
        :fqdn => 'hieranomerge.example.com',
        :lsbmajdistversion => '6',
        :specific => 'redhatkeys',
      }
    end
    it { should contain_class('rpmkey') }
    it { should contain_rpmkey('0608B895').with({
      'ensure' => 'present',
      'source' => 'https://fedoraproject.org/static/0608B895.txt',
    })
    }
    it { should_not contain_rpmkey('12345678').with({
      'ensure' => 'absent',
      'source' => 'https://link-to-key.tld/static/12345678.txt',
    })
    }
  end
  context 'with multiple key specified in hiera with hiera_merge enabled' do
    let(:facts) do
      {
        :osfamily => 'RedHat',
        :fqdn => 'hieramerge.example.com',
        :lsbmajdistversion => '6',
        :specific => 'redhatkeys',
      }
    end
    it { should contain_class('rpmkey') }
    it { should contain_rpmkey('0608B895').with({
      'ensure' => 'present',
      'source' => 'https://fedoraproject.org/static/0608B895.txt',
    })
    }
    it { should contain_rpmkey('12345678').with({
      'ensure' => 'absent',
      'source' => 'https://link-to-key.tld/static/12345678.txt',
    })
    }
  end
end
