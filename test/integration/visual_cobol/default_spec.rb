# packages
%w[glibc libgcc libstdc++ glibc-devel.i686 gcc ed pax xterm].each do |p|
  describe package(p) do
    it { should be_installed }
  end
end

# microfocus visual cobol directories
[
  '/opt/microfocus/VisualCOBOL/bin/cob',
  '/var/microfocuslicensing/bin/cesadmintool.sh'
].each do |f|
  describe file(f) do
    its(:owner) { should eq 'root' }
    its(:group) { should eq 'root' }
    its(:mode) { should eq 0o555 }
  end
end

%w[lserv mfcesd].each do |p|
  describe processes(p) do
    it { should exist }
  end
end

describe command('/var/microfocuslicensing/bin/lsmon') do
  its('stdout') { should match (/\/var\/microfocuslicensing\/bin\/lservrc.net/) }
  its('stdout') { should match (/License status\s*:\s*Active/) }
end

# license manager and daemon services
%w[lserv mfcesd].each do |s|
  describe service(s) do
    it { should be_enabled }
    it { should be_running }
  end
end
