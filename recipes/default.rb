# Author:: Luke Bradbury (<luke.bradbury@derby.ac.uk>)
# Cookbook Name:: microfocus-server
# Recipe:: default
#
# Copyright 2013 University of Derby
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

serial_number = node['microfocus']['license']['serial number']
license_number = node['microfocus']['license']['license number']
mf_home     = node['microfocus']['server express']['home']
lmf_home    = node['microfocus']['license manager']['home']
tmp_dir     = Chef::Config['file_cache_path']
filename    = node['microfocus']['server express']['url'].split('/')[-1]
install_file = File.join(tmp_dir, filename)

chef_gem 'greenletters'
require 'greenletters'

node['microfocus']['packages'].each do |name|
  name += '.i386' if node['platform_version'].to_i == 5 && _32_bit?
  yum_package name
end

yum_package 'glibc'
yum_package 'glibc.i686'
yum_package 'libgcc'
yum_package 'libstdc++'

directory mf_home do
  recursive true
end

directory lmf_home do
  recursive true
end

remote_file install_file do
  source node['microfocus']['server express']['url']
end

ruby_block 'install' do
  block do
    install = Greenletters::Process.new("#{mf_home}/install", transcript: $stdout, timeout: 300)
    install.on(:output, /--more--/i) do
      install << ' '
    end

    install.start!
    # 12B-1-2.
    # 9 continue?
    install.wait_for(:output, /(y\/n)/i)
    install << "y\n"
    # 10 license?
    install.wait_for(:output, /(y\/n)/i)
    install << "y\n"
    # 11 not standard install?
    install.wait_for(:output, /(y\/n)/i)
    install << "y\n"
    # 12 confirm understanding?
    install << "\n"
    install.wait_for(:output, /(y\/n)/i)
    install << "y\n"
    # 13 java?
    install.wait_for(:output, /(y\/n)/i)
    install << "n\n"
    # 14 lmf?
    install.wait_for(:output, /(y\/n)/i)
    install << "y\n"
    # 15 lmf dir
    install.wait_for(:output, /mflmf/i)
    install << "#{lmf_home}\n"
    install.wait_for(:output, /(y\/n)/i)
    install << "y\n"

    # 16 superuser?
    install.wait_for(:output, /(y\/n)/i)
    install << "y\n"

    # 17 autostart?
    # install.wait_for(:output, /(y\/n)/i)
    # install << "y\n"
    # 18 notice only
    # 19 architecture?
    install.wait_for(:output, /set the system default mode:/i)
    install << "64\n"

    # 20 Enterprise Server?
    install.wait_for(:output, /(y\/n)/i)
    install << "n\n"

    # 21 XDB?
    install.wait_for(:output, /(y\/n)/i)
    install << "n\n"

    install.wait_for(:exit)
  end
  action :nothing
end

ruby_block 'license' do
  block do
    license = Greenletters::Process.new("cd #{lmf_home};./mflmcmd", transcript: $stdout, timeout: 300)
    license.start!
    license.wait_for(:output, / /i)
    license << "I\n"
    license << "#{serial_number}\n"
    license << "#{license_number}\n"
    license.wait_for(:exit)
  end
  action :nothing
  notifies :run, 'execute[start license manager]'
end

execute 'stop license manager' do
  cwd "#{lmf_home}"
  command "#{lmf_home}/lmfgetpv k"
  action :nothing
  ignore_failure true
end

execute 'start license manager' do
  cwd "#{lmf_home}"
  command "#{lmf_home}/mflmman"
  action :nothing
end

execute 'extract' do
  command "tar xvf #{install_file} -C #{mf_home}"
  not_if { ::File.exist?("#{mf_home}/install") }
  notifies :run, resources(ruby_block: 'install')
  notifies :run, resources(ruby_block: 'license')
end

node.default['ohai']['plugins']['microfocus-server'] = 'plugins'
include_recipe 'ohai::default'

template 'cobopt' do
  mode 00444
  variables(
    gcc_version: node['gcc']['version']
  )
  path ::File.join(mf_home, '/etc/cobopt')
end

template 'cobopt64' do
  mode 00444
  variables(
    gcc_version: node['gcc']['version']
  )
  path ::File.join(mf_home, '/etc/cobopt64')
end
