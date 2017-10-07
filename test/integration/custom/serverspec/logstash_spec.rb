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

describe file('/etc/logstash/conf.d') do
  it { should exist }
  it { should be_directory }
  it { should be_mode 775 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file('/usr/share/logstash') do
  it { should exist }
  it { should be_directory }
  it { should be_mode 775 }
  it { should be_owned_by 'logstash' }
  it { should be_grouped_into 'logstash' }
end

describe file('/etc/logstash/conf.d/01-inputs.conf') do
  it { should exist }
  it { should be_mode 644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  its(:content) { should match /^input {\n  file {/ }
  its(:content) { should match /^    path => \[\n      "\/var\/log\/syslog",\n      "\/var\/log\/auth.log"\n    \]/ }
  its(:content) { should match /^    type => "syslog"\n  }\n/ }
  its(:content) { should match /^    codec => collectd \{\n/}
end

describe file('/etc/logstash/conf.d/02-filters.conf') do
  it { should exist }
  it { should be_mode 644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  its(:content) { should match /^filter {/ }
  its(:sha256sum) { should eq '44c3c29ddeecf0e8ffa5c3f36619b024a8d67bcc9cad917b8178d62ffae746f4' }
end

describe file('/etc/logstash/conf.d/03-outputs.conf') do
  it { should exist }
  it { should be_mode 644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  its(:content) { should match /elasticsearch {/ }
  its(:content) { should match /^output {\n  elasticsearch {/ }
  its(:content) { should match /^    hosts => \[\n      "localhost"\n    \]/ }
end

describe file('/etc/logstash/jvm.options') do
  it { should exist }
  it { should be_mode 664 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  its(:content) { should match /-Xms256m/ }
  its(:content) { should match /-Xmx4g/ }
  its(:content) { should match /-XX:\+UseParNewGC/ }
  its(:content) { should match /-XX:\+UseConcMarkSweepGC/ }
  its(:content) { should match /-XX:CMSInitiatingOccupancyFraction=75/ }
  its(:content) { should match /-XX:\+UseCMSInitiatingOccupancyOnly/ }
  its(:content) { should match /-XX:\+DisableExplicitGC/ }
  its(:content) { should match /-Djava\.awt\.headless=true/ }
  its(:content) { should match /-Dfile\.encoding=UTF-8/ }
  its(:content) { should match /-XX:\+HeapDumpOnOutOfMemoryError/ }
end

describe file('/etc/logstash/log4j2.properties') do
  it { should exist }
  it { should be_mode 664 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  its(:content) { should match /^status = error/ }
  its(:content) { should match /^name = LogstashPropertiesConfig/ }
end

describe file('/etc/logstash/logstash.yml') do
  it { should exist }
  it { should be_mode 664 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  its(:content) { should match /path.data: \/var\/lib\/logstash/ }
  its(:content) { should match /path.config: \/etc\/logstash\/conf\.d/ }
  its(:content) { should match /path.logs: \/var\/log\/logstash/ }
end

describe file('/etc/logstash/startup.options') do
  it { should exist }
  it { should be_mode 664 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  its(:content) { should match /JAVACMD=\/usr\/bin\/java/ }
end

describe command('/usr/share/logstash/bin/logstash-plugin list') do
  its(:stdout) { should match /x-pack/ }
end

describe service('logstash') do
  it { should be_running }
  it { should be_enabled }
end

describe process('java') do
  its(:user) { should eq "logstash" }
  its(:args) { should match /-Xmx4g/ }
end

describe file('/usr/share/logstash/patterns/cisco') do
  it { should exist }
  it { should be_mode 644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file('/usr/share/logstash/patterns/juniper') do
  it { should exist }
  it { should be_mode 644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file('/usr/share/logstash/patterns/nginx') do
  it { should exist }
  it { should be_mode 644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file('/usr/share/logstash/patterns/loadbal') do
  it { should exist }
  it { should be_mode 644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file('/usr/share/logstash/patterns/cron') do
  it { should exist }
  it { should be_mode 644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file('/usr/share/logstash/patterns/syslog') do
  it { should exist }
  it { should be_mode 644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file('/usr/share/logstash/patterns/ssh') do
  it { should exist }
  it { should be_mode 644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file('/usr/share/logstash/patterns/apache') do
  it { should exist }
  it { should be_mode 644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file('/usr/share/logstash/patterns/longview') do
  it { should exist }
  it { should be_mode 644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file('/usr/share/logstash/patterns/uwsgi') do
  it { should exist }
  it { should be_mode 644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end