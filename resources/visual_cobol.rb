#
# Cookbook Name:: microfocus
# Resource:: visual_cobol
#
# Copyright 2020 University of Derby
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

resource_name :microfocus_visual_cobol
default_action :create

property :group, String, default: 'root'
property :mode, Integer, default: 0o775
property :owner, String, default: 'root'
property :visual_cobol_checksum, String
property :visual_cobol_install_path_cob, String, default: '/opt/microfocus/VisualCOBOL/bin/cob'
property :visual_cobol_license_checksum, String
property :visual_cobol_license_install_tool, String, default: '/var/microfocuslicensing/bin/cesadmintool.sh'
property :visual_cobol_license_path, String, default: '/opt/microfocus/VisualCOBOL/etc/PS-VC-30DAY'
property :visual_cobol_license_url, String, required: true
property :visual_cobol_setup_path, String, default: '/tmp/setup_visualcobol'
property :visual_cobol_url, String, required: true
property :install_log_path, String, default: '/opt/microfocus/logs/install.log'

# default action :create
action :create do
  %w[glibc-devel.i686 ed pax xterm].each do |p|
    package p
  end

  # setup install file location
  remote_file new_resource.visual_cobol_setup_path do
    source new_resource.visual_cobol_url
    checksum new_resource.visual_cobol_checksum
    owner new_resource.owner
    group new_resource.group
    mode new_resource.mode
    action :create
    not_if { ::File.exist?(new_resource.visual_cobol_setup_path) }
  end

  # install visual cobol
  execute 'visual_cobol_install' do
    command "#{new_resource.visual_cobol_setup_path} -silent -IacceptEULA -noplatformcheck"
    not_if { ::File.exist?(new_resource.visual_cobol_install_path_cob) }
  end

  # copy license file to target
  remote_file new_resource.visual_cobol_license_path do
    source new_resource.visual_cobol_license_url
    checksum new_resource.visual_cobol_license_checksum
    owner new_resource.owner
    group new_resource.group
    mode new_resource.mode
    action :create
    not_if { ::File.exist?(new_resource.visual_cobol_license_path) }
  end

  # install license
  execute 'visual_cobol_license_install' do
    command "#{new_resource.visual_cobol_license_install_tool} -install #{new_resource.visual_cobol_license_path}"
    not_if "/var/microfocuslicensing/bin/lsmon | grep '/var/microfocuslicensing/bin/lservrc\.net'"
  end
end
