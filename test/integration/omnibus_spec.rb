describe file '/home/omnibus/load-omnibus-toolchain.sh' do
  it { should be_executable }
end

describe command '/home/omnibus/load-omnibus-toolchain.sh' do
  its('exit_status') { should eq 0 }
end

describe directory '/opt/omnibus-toolchain' do
  it { should exist }
end

describe package 'omnibus-toolchain' do
  it { should be_installed }
end

describe command 'locale -a' do
  its('stdout') { should match /en_US\.utf8/ }
end

describe command 'aclocal --version' do
  its('exit_status') { should eq 0 }
end

describe package 'cinc' do
  it { should_not be_installed }
end
