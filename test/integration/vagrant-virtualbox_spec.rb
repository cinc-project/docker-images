describe command 'vagrant version' do
  its('exit_status') { should eq 0 }
  its('stderr') { should eq '' }
end

describe command 'vboxmanage -v' do
  its('exit_status') { should eq 0 }
  its('stderr') { should eq '' }
end
