# Author:: Dan Webb (<d.webb@derby.ac.uk>)
# Cookbook Name:: microfocus-server
# Recipe::  gcc_version
#
# Copyright 2014 University of Derby
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

Ohai.plugin(:GCCVersion) do
  provides 'gcc', 'gcc/version' 
  depends 'platform'

  collect_data(:default) do
    if %w{ rhel }.include?(platform_family) or %w{ redhat centos }.include?(platform)
      gcc Mash.new
      gcc[:version] = Mixlib::ShellOut.new('gcc -dumpversion').run_command.stdout.delete!("\n")
    end
  end
end
