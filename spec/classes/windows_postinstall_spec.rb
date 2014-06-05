require 'spec_helper'

describe 'windows_postinstall' do
  let(:facts){{
    :osfamily => 'Windows',
    :path     => '/bin',
    :puppet_vardir => 'C:/ProgramData/PuppetLabs/puppet/var'
  }}

  context 'install without share' do
    let(:params){{
      :install_command => 'install.msi --quiet',
    }}

    it do
      should contain_exec('install_command').with({
        :command => 'install.msi --quiet',
        :path => '/bin',
        :provider => 'powershell'
      })

      should contain_file('C:/ProgramData/PuppetLabs/puppet/var/postinstall.lck')
    end
  end

  context 'install with share' do
    let(:params){{
      :share => '//server/share',
      :install_command => 'install.msi --quiet',
    }}

    it do
      should contain_exec('install_command').with({
        :command => 'install.msi --quiet',
        :path => '//server/share',
        :provider => 'powershell',
      })

      should contain_file('C:/ProgramData/PuppetLabs/puppet/var/postinstall.lck')
    end
  end

  context 'download file' do
    let(:params){{
      :upload_file => 'test.msi',
      :execute_file_command => 'test.msi --quiet',
    }}

    it do
      should contain_exec('postinstall').with({
        :command => 'test.msi --quiet',
        :path => 'C:/ProgramData/PuppetLabs/puppet/var/staging;/bin',
        :provider => 'powershell',
      })

      should contain_file('C:/ProgramData/PuppetLabs/puppet/var/postinstall.lck')
    end
  end
end
