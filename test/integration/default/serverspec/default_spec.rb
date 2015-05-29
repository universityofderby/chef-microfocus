require 'serverspec'

set :backend, :exec

describe file('/opt/microfocus/cobol') do
  it { should be_a_directory }
end

describe file('/opt/microfocus/mflmf') do
  it { should be_a_directory }
end
# cobopt & cobopt64
describe file('/opt/microfocus/cobol/etc/cobopt') do
  it { should be_a_file }
  it { should be_mode 444 }
end

describe file('/opt/microfocus/cobol/etc/cobopt64') do
  it { should be_a_file }
  it { should be_mode 444 }
end

# Service Script
describe file('/etc/mflmrcscript') do
  it { should be_file }
end

# Inittab
describe file('/etc/inittab') do
  it { should contain '/etc/mflmrcscript' }
end

# libgcc
describe package('libgcc') do
  it { should be_installed }
end

#libgcc.i686
describe package('libgcc.i686') do
  it { should be_installed }
end

#check mflm_manager process
describe process('mflm_manager') do
  it { should be_running }
end
