# packages
%w[glibc-devel.i686 ed pax xterm].each do |p|
  describe package(p) do
    it { should be_installed }
  end
end

# microfocus visual cobol directories
{
  '/opt/microfocus/VisualCOBOL/bin/cob' => 0o555,
  '/var/microfocuslicensing/bin/cesadmintool.sh' => 0o555
}.each do |f, m|
  describe file(f) do
    its(:owner) { should eq 'root' }
    its(:group) { should eq 'root' }
    its(:mode) { should eq m }
  end
end

%w[lserv mfcesd].each do |p|
  describe processes(p) do
    it { should exist }
  end
end

describe command('/var/microfocuslicensing/bin/lsmon') do
  its('stdout') { should match (/\/var\/microfocuslicensing\/bin\/lservrc.net/) }
end

describe command('/var/microfocuslicensing/bin/lsmon') do
  its('stdout') { should match (/Active/) }
end
