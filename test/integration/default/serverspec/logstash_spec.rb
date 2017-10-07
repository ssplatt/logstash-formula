require 'serverspec'

# Required by serverspec
set :backend, :exec

describe package('logstash') do
  it { should be_installed }
end

describe user('logstash') do
  it { should exist }
  it { should belong_to_group 'logstash' }
end

describe file('/etc/logstash/jvm.options') do
  it { should exist }
  it { should be_mode 664 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  its(:md5sum) { should match /c4d139ba34295758cb415ce18307551f/ }
end

describe file('/etc/logstash/log4j2.properties') do
  it { should exist }
  it { should be_mode 664 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  its(:md5sum) { should match /765be676a62b1d7b96ea2dbb9f49f723/ }
end

describe file('/etc/logstash/logstash.yml') do
  it { should exist }
  it { should be_mode 664 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  its(:md5sum) { should match /318496fd62b9221178b1a61d5181ebcf/ }
end

describe file('/etc/logstash/startup.options') do
  it { should exist }
  it { should be_mode 664 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  its(:md5sum) { should match /3e1c05d4a60f786bb9d33373b137032f/ }
end
