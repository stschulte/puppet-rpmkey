require 'spec_helper'

describe 'rpmkey' do

  context 'with a key specified as present' do
    let(:params) do
      {
        :rpmkeys => {
          '0608B895' => {
            'ensure' => 'present',
            'source' => 'https://fedoraproject.org/static/0608B895.txt',
          }
        }
      }
    end
    it {should contain_rpmkey('0608B895').with({
      'ensure' => 'present',
      'source' => 'https://fedoraproject.org/static/0608B895.txt',
      })
    }
  end

  context 'with key specified as absent' do
    let(:params) do
      {
        :rpmkeys => {
          '0608B895' => {
            'ensure' => 'absent',
            'source' => 'https://fedoraproject.org/static/0608B895.txt',
          }
        }
      }
    end
    it {should contain_rpmkey('0608B895').with({
      'ensure' => 'absent',
      'source' => 'https://fedoraproject.org/static/0608B895.txt',
      })
    }
  end
end
