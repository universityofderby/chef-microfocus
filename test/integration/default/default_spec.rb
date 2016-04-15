%w(gcc glibc libgcc).each do |p|
  describe package(p) do
    it { should be_installed }
  end
end

describe file('/opt/microfocus') do
  it { should be_directory }
  its(:owner) { should eq 'root' }
  its(:group) { should eq 'root' }
  its(:mode) { should eq 0755 }
end

describe file('/opt/microfocus/cobol/install') do
  its(:owner) { should eq 'root' }
  its(:group) { should eq 'root' }
  its(:mode) { should eq 0555 }
end
