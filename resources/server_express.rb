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

# default action :create
action :create do
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
    action :put
  end

  # greenletters gem required for responding to interactive install and license commands
  chef_gem 'greenletters'
  require 'greenletters'

  # execute installer
  ruby_block 'install' do
    block do
      install = Greenletters::Process.new(::File.join(new_resource.path, new_resource.server_express_dir, 'install'), transcript: $stdout, timeout: 300)
      install.on(:output, /--more--/i) do
        install << ' '
      end
      install.start!
      [ # 01. Do you wish to continue (y/n):
        { method: 'wait_for', pattern: '(y\/n)', input: 'y\n' },
        # 02. Do you agree to the terms of the License Agreement? (y/n):
        { method: 'wait_for', pattern: '(y\/n)', input: 'y\n' },
        # 03. Please confirm that you want to continue with this installation (y/n):
        { method: 'wait_for', pattern: '(y\/n)', input: 'y\n' },
        # 04. Please press return when you are ready:
        { method: 'wait_for', pattern: 'Please press return when you are ready:', input: '\n' },
        # 05. Please confirm your understanding of the above reference environment details (y/n):
        { method: 'wait_for', pattern: '(y\/n)', input: 'y\n' },
        # 06. Do you want to make use of COBOL and Java working together? (y/n):
        { method: 'wait_for', pattern: '(y\/n)', input: 'n\n' },
        # 07. Would you like to install LMF now? (y/n):
        { method: 'wait_for', pattern: '(y\/n)', input: 'y\n' },
        # 08. Enter the directory name where you wish to install License Manager
        { method: 'wait_for', pattern: '(y\/n)', input: ::File.join(new_resource.path, new_resource.license_manager_dir) },
        # 09. do you wish to create it ? (y/n)
        { method: 'wait_for', pattern: '(y\/n)', input: 'y\n' },
        # 10. Do you want only superuser to be able to access the License Admin System? (y/n)
        { method: 'wait_for', pattern: '(y\/n)', input: 'y\n' },
        # 11. Do you want license manager to be automatically started at boot time? (y/n)
        { method: 'wait_for', pattern: '(y\/n)', input: 'n\n' },
        # 12. Please enter either 32 or 64 to set the system default mode:
        { method: 'wait_for', pattern: '(y\/n)', input: '64\n' },
        # 13. Do you wish to configure Enterprise Server now? (y/n):
        { method: 'wait_for', pattern: '(y\/n)', input: 'n\n' }
      ].each do |r|
        case r[:method]
        when 'wait_for'
          install.wait_for(:output, /#{r[:pattern]}/i)
          install << r[:input]
        end
      end
      install.wait_for(:exit)
    end
  end
end
