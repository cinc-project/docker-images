case os.family
when 'redhat'
  pkgs = %w(curl wget ca-certificates iproute rsync openssh-clients)
  toolchain_ver = /^1\.1\.109/
when 'debian'
  pkgs = %w(curl wget ca-certificates iproute2 rsync openssh-client libssl-dev)
  case os.arch
  when x86_64
    toolchain_ver = /^1\.1\.109/
  when aarch64
    toolchain_ver = /^2\.0\.2/
  end
when 'suse'
  pkgs = %w(curl wget iproute2 rsync openssh tar gzip hostname rpm-build)
  case os.arch
  when x86_64
    toolchain_ver = /^1\.1\.109/
  when aarch64
    toolchain_ver = /^2\.0\.2/
  end
end

describe file '/home/omnibus/load-omnibus-toolchain.sh' do
  its('content') { should_not match /^env/ }
end

describe command '/home/omnibus/load-omnibus-toolchain.sh' do
  its('exit_status') { should eq 0 }
end

describe directory '/opt/omnibus-toolchain' do
  it { should exist }
end

describe package 'omnibus-toolchain' do
  it { should be_installed }
  its('version') { should match toolchain_ver }
end

describe command 'gcc --version' do
  its('exit_status') { should eq 0 }
end

pkgs.each do |pkg|
  describe package pkg do
    it { should be_installed }
  end
end

describe package 'chef' do
  it { should_not be_installed }
end
