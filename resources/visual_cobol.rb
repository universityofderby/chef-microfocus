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
property :visual_cobol_install_path, String, default: '/opt/microfocus/VisualCOBOL'
property :visual_cobol_license_checksum, String
#property :visual_cobol_license_install_tool, String, default: '/var/microfocuslicensing/bin/cesadmintool.sh'
property :visual_cobol_license_bin_path, String, default: '/var/microfocuslicensing/bin'
property :visual_cobol_license_path, String, default: lazy {"#{visual_cobol_install_path}/etc/PS-VC-UNIX-Linux"}
property :visual_cobol_license_url, String, required: true
property :visual_cobol_setup_path, String, default: '/tmp/setup_visualcobol'
property :visual_cobol_url, String, required: true

# default action :create
action :create do
  %w[glibc libgcc libstdc++ glibc-devel.i686 gcc ed pax xterm].each do |p|
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
    not_if { ::File.exist?(::File.join(new_resource.visual_cobol_install_path, 'bin/cob')) }
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
    command "#{new_resource.visual_cobol_license_bin_path}/cesadmintool.sh -install #{new_resource.visual_cobol_license_path}"
    not_if "/var/microfocuslicensing/bin/lsmon | grep '/var/microfocuslicensing/bin/lservrc\.net'"
    notifies :run, 'execute[stop_mfcesd]', :immediately
  end

  # stop mfcesd
  execute 'stop_mfcesd' do
    command "#{::File.join(new_resource.visual_cobol_license_bin_path, 'stopmfcesd.sh')}"
    action :nothing
    notifies :run, 'execute[stop_lserv]', :immediately
  end

  # stop lserv
  execute 'stop_lserv' do
    command "#{::File.join(new_resource.visual_cobol_license_bin_path, 'stoplserv.sh')}"
    action :nothing
  end

  # lserv service
  systemd_unit 'lserv.service' do
    content({
      Unit: {
        After: 'network.target',
        Description: 'Microfocus Visual Cobol lserv service'
      },
      Service: {
        ExecStart: "#{::File.join(new_resource.visual_cobol_license_bin_path, 'startlserv.sh')}",
        ExecStop: "#{::File.join(new_resource.visual_cobol_license_bin_path, 'stoplserv.sh')}",
        Type: 'forking'
      },
      Install: {
        WantedBy: 'multi-user.target'
      }
    })
    action [:create, :enable, :start]
  end

  # mfcesd service
  systemd_unit 'mfcesd.service' do
    content({
      Unit: {
        After: 'network.target lserv.service',
        Description: 'Microfocus Visual Cobol mfcesd service',
        Requires: 'lserv.service'
      },
      Service: {
        ExecStart: "#{::File.join(new_resource.visual_cobol_license_bin_path, 'startmfcesd.sh')}",
        ExecStop: "#{::File.join(new_resource.visual_cobol_license_bin_path, 'stopmfcesd.sh')}",
        Type: 'forking'
      },
      Install: {
        WantedBy: 'multi-user.target'
      }
    })
    action [:create, :enable, :start]
  end
end
