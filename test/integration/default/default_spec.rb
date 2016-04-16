# packages
%w(gcc glibc glibc.i686 libgcc libgcc.i686).each do |p|
  describe package(p) do
    it { should be_installed }
  end
end

# microfocus directories
{ '/opt/microfocus' => 0755,
  '/opt/microfocus/cobol' => 0755,
  '/opt/microfocus/mflmf' => 0700
}.each do |f, m|
  describe file(f) do
    it { should be_directory }
    its(:owner) { should eq 'root' }
    its(:group) { should eq 'root' }
    its(:mode) { should eq m }
  end
end

# microfocus files
{ '/opt/microfocus/cobol/install' => 0555,
  '/opt/microfocus/mflmf/mflmcmd' => 0555,
  '/opt/microfocus/mflmf/mflm_manager' => 0544
}.each do |f, m|
  describe file(f) do
    its(:owner) { should eq 'root' }
    its(:group) { should eq 'root' }
    its(:mode) { should eq m }
  end
end

# license manager init.d script
describe file('/etc/rc.d/init.d/mflm_manager') do
  its(:content) { should match(%r{sh \/etc\/mflmrcscript > \/dev\/null 2>&1}) }
  its(:owner) { should eq 'root' }
  its(:group) { should eq 'root' }
  its(:mode) { should eq 0755 }
end

# license manager service
describe service('mflm_manager') do
  it { should be_enabled }
  it { should be_running }
end

# license manager process
describe process('./mflm_manager') do
  it { should be_running }
end
