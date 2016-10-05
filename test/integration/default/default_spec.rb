# packages
%w(gcc glibc libgcc).each do |p|
  describe package(p) do
    it { should be_installed }
  end
end

# microfocus directories
{
  '/opt/microfocus' => 0o755,
  '/opt/microfocus/cobol' => 0o755,
  '/opt/microfocus/mflmf' => 0o700
}.each do |f, m|
  describe file(f) do
    it { should be_directory }
    its(:owner) { should eq 'root' }
    its(:group) { should eq 'root' }
    its(:mode) { should eq m }
  end
end

# microfocus files
{
  '/opt/microfocus/cobol/install' => 0o555,
  '/opt/microfocus/mflmf/mflmcmd' => 0o555,
  '/opt/microfocus/mflmf/mflm_manager' => 0o544
}.each do |f, m|
  describe file(f) do
    its(:owner) { should eq 'root' }
    its(:group) { should eq 'root' }
    its(:mode) { should eq m }
  end
end

# license manager startup script
describe file('/etc/mflmrcscript') do
  its(:content) { should match(%r{cd \/opt\/microfocus\/mflmf}) }
  its(:content) { should match(%r{\.\/mflm_manager}) }
  its(:owner) { should eq 'root' }
  its(:group) { should eq 'root' }
  its(:mode) { should eq 0o755 }
end

# license manager service
describe service('mflm') do
  it { should be_installed }
  it { should be_running }
end

describe service('mflm').runlevels(2, 3, 4, 5) do
  it { should be_enabled }
end

# license manager process
describe processes('./mflm_manager') do
  its('list.length') { should eq 1 }
  its('users') { should eq ['root'] }
end
