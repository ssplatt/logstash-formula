# States to place things that other formulas would take care of in production

logstash_repo:
  pkgrepo.managed:
    - humanname: Logstash Repo
    - name: deb https://artifacts.elastic.co/packages/5.x/apt stable main
    - dist: stable
    - file: /etc/apt/sources.list.d/logstash.list
    - key_url: https://artifacts.elastic.co/GPG-KEY-elasticsearch
    - refresh: True

logstash_repo_jessie_backports:
  pkgrepo.managed:
    - humanname: Jessie Backports
    - name: deb http://ftp.debian.org/debian jessie-backports main

# create a super simple types db so collectd codec loads
logstash_mockup_types_db:
  file.managed:
    - name: '/tmp/types.db'
    - contents: |
        absolute             value:ABSOLUTE:0:U
        apache_bytes         value:DERIVE:0:U
        apache_connections   value:GAUGE:0:65535

logstash_mockup_othertypes_db:
  file.managed:
    - name: '/tmp/othertypes.db'
    - contents: |
        apache_idle_workers  value:GAUGE:0:65535
        apache_requests      value:DERIVE:0:U
