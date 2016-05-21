require 'spec_helper_acceptance'

describe 'cassandra class' do
  cassandra_install_pp = <<-EOS
    class { '::cassandra::java':
      aptkey       => {
        'ZuluJDK' => {
          id     => '27BC0C8CB3D81623F59BDADCB1998361219BD9C9',
          server => 'keyserver.ubuntu.com',
        },
      },
      aptsource    => {
        'ZuluJDK' => {
          location => 'http://repos.azulsystems.com/debian',
          comment  => 'Zulu OpenJDK 8 for Debian',
          release  => 'stable',
          repos    => 'main',
        },
      },
      package_name => 'zulu-8',
      before       => Class['cassandra'],
    }

    class { '::cassandra::datastax_repo':
      before => Class['cassandra'],
    }

    class { '::cassandra':
      cassandra_9822 => true,
      cluster_name   => 'Issue245',
      package_ensure => '2.2.6',
    }
  EOS

  describe '########### Cassandra installation.' do
    it 'should work with no errors' do
      apply_manifest(cassandra_install_pp, catch_failures: true)
    end
    it 'check code is idempotent' do
      expect(apply_manifest(cassandra_install_pp,
                            catch_failures: true).exit_code).to be_zero
    end
  end

  describe package('cassandra') do
    it { is_expected.to be_installed }
  end

  describe service('cassandra') do
    it { is_expected.to be_running }
    it { is_expected.to be_enabled }
  end

  describe '########### Cassandra System Logs.' do
    it '/var/log/cassandra/system.log' do
      shell("test -f /var/log/cassandra/system.log && cat /var/log/cassandra/system.log")
    end
  end
end
