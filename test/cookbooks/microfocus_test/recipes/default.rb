#
# Cookbook Name:: microfocus_test
# Recipe:: default
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

microfocus_server_express '/opt/microfocus/cobol' do
  checksum node['microfocus']['server_express']['checksum']
  license_number node['microfocus']['server_express']['license_number']
  serial_number node['microfocus']['server_express']['serial_number']
  url node['microfocus']['server_express']['url']
end
