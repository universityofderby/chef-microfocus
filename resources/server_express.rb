#
# Cookbook Name:: microfocus
# Resource:: server_express
#
# Copyright 2016 University of Derby
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

resource_name :microfocus_server_express
default_action :create

property :checksum, String
property :group, String, default: 'root'
property :license_manager_dir, default: 'mflmf'
property :license_number, String, required: true
property :mode, Integer, default: 0755
property :owner, String, default: 'root'
property :path, String, default: '/opt/microfocus'
property :serial_number, String, required: true
property :server_express_dir, default: 'cobol'
property :url, String, required: true
property :install_responses, Array, default: lazy {
  [{ '\(y\/n\)' => "y\n" }, # 1. Do you wish to continue (y/n):
   { '\(y\/n\)' => "y\n" }, # 2. Do you agree to the terms of the License Agreement? (y/n):
   { '\(y\/n\)' => "y\n" }, # 3. Please confirm that you want to continue with this installation (y/n):
   { 'Please press return when you are ready:' => "\n" }, # 4. Please press return when you are ready:
   { '\(y\/n\)' => "y\n" }, # 5. Please confirm your understanding of the above reference environment details (y/n):
   { '\(y\/n\)' => "n\n" }, # 6. Do you want to make use of COBOL and Java working together? (y/n):
   { '\(y\/n\)' => "y\n" }, # 7. Would you like to install LMF now? (y/n):
   { 'Press Enter for default directory' => "#{::File.join(path, license_manager_dir)}\n" }, # 8. Enter the directory name where you wish to install License Manager
   { '\(y\/n\)' => "y\n" }, # 9. do you wish to create it ? (y/n)
   { '\(y\/n\)' => "y\n" }, # 10. Do you want only superuser to be able to access the License Admin System? (y/n)
   { '\(y\/n\)' => "n\n" }, # 11. Do you want license manager to be automatically started at boot time? (y/n)
   { 'Please enter either 32 or 64 to set the system default mode:' => "64\n" }, # 12. Please enter either 32 or 64 to set the system default mode:
   { '\(y\/n\)' => "n\n" } # 13. Do you wish to configure Enterprise Server now? (y/n):
  ]
}
property :mflmcmd_responses, Array, default: lazy {
  [{ 'License' => "I\n" }, # 1. Select the function you require from the list:
   { 'Serial Number' => "#{serial_number}\n" }, # 2. Enter the Serial Number part of the License Key:
   { 'License Number' => "#{license_number}\n" } # 3. Enter the License Number part of the License Key:
  ]
}

# default action :create
action :create do
  # greenletters gem required for responding to interactive install and mflmcmd commands
  chef_gem 'greenletters' do
    compile_time true
  end
  require 'greenletters'

  # install required packages
  %w(gcc glibc glibc.i686 libgcc libgcc.i686).each do |p|
    package p
  end

  # create parent directory
  directory new_resource.path do
    owner new_resource.owner
    group new_resource.group
    mode new_resource.mode
    recursive true
  end

  # extract archive
  ark new_resource.server_express_dir do
    path new_resource.path
    url new_resource.url
    checksum new_resource.checksum unless new_resource.checksum.nil?
    owner new_resource.owner
    group new_resource.group
    mode new_resource.mode
    strip_components 0
    not_if { ::File.exist?(::File.join(new_resource.path, new_resource.server_express_dir)) }
    notifies :run, 'ruby_block[install]', :immediately
    notifies :run, 'ruby_block[mflmcmd]', :immediately
    action :put
  end

  # execute install
  ruby_block 'install' do
    block do
      install = Greenletters::Process.new(::File.join(new_resource.path, new_resource.server_express_dir, 'install'), transcript: $stdout, timeout: 300)
      install.on(:output, /--more--/i) do
        install << ' '
      end
      install.start!
      new_resource.install_responses.each do |h|
        h.each do |p, i|
          install.wait_for(:output, /#{p}/i)
          install << i
        end
      end
      install.wait_for(:exit)
    end
    only_if { ::File.exist?(::File.join(new_resource.path, new_resource.server_express_dir, 'install')) }
    action :nothing
  end

  # execute mflmcmd
  ruby_block 'mflmcmd' do
    block do
      mflmcmd = Greenletters::Process.new("cd #{::File.join(new_resource.path, new_resource.license_manager_dir)};./mflmcmd", transcript: $stdout, timeout: 300)
      mflmcmd.start!
      new_resource.mflmcmd_responses.each do |h|
        h.each do |p, i|
          mflmcmd.wait_for(:output, /#{p}/i)
          mflmcmd << i
        end
      end
      mflmcmd.wait_for(:exit)
    end
    only_if { ::File.exist?(::File.join(new_resource.path, new_resource.license_manager_dir, 'mflmcmd')) }
    action :nothing
  end
end
