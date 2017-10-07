# -*- coding: utf-8 -*-
# vim: ft=yaml
---
logstash:
  enabled: True
  patterns:
    syslog: True
    apache: True
    cisco: True
    cron: True
    juniper: true
    nginx: true
    ssh: true
    uwsgi: true
  inputs:
      - plugin_name: 'stdin'

  filters:
    # each grok in it's own section
    # log line will attempt to match each pattern
    # tags will show what the log line matches
    - plugin_name: 'grok'
      patterns_dir: '/usr/share/logstash/patterns'
      match:
        message:
          - '%{SYSLOGLINE2}'
      add_field:
        received_from: '%{host}'
      add_tag:
        - 'syslogline2'

    - plugin_name: 'grok'
      cond: 'if [program] == "fail2ban.actions"'
      patterns_dir: '/usr/share/logstash/patterns'
      match:
        logmessage:
          - '%{FAIL2BAN}'
      add_tag:
        - 'fail2ban'
    - plugin_name: 'grok'
      cond: 'else if [program] == "sshd"'
      patterns_dir: '/usr/share/logstash/patterns'
      match:
        logmessage:
          - '%{SSH_PW_LOGIN}'
      add_tag:
        - 'ssh_pw_login'
    - plugin_name: 'grok'
      cond: 'else if [program] == "sshd"'
      patterns_dir: '/usr/share/logstash/patterns'
      match:
        logmessage:
          - '%{SSH_BAD_USER}'
      add_tag:
        - 'ssh_bad_user'
    - plugin_name: 'grok'
      cond: 'else if [program] == "sshd"'
      patterns_dir: '/usr/share/logstash/patterns'
      match:
        logmessage:
          - '%{SSH_CON_CLOSE}'
      add_tag:
        - 'ssh_con_close'
    - plugin_name: 'grok'
      cond: 'else if [program] == "sshd"'
      patterns_dir: '/usr/share/logstash/patterns'
      match:
        logmessage:
          - '%{SSH_LOGIN}'
      add_tag:
        - 'ssh_login'
    - plugin_name: 'grok'
      cond: 'else if [program] == "sshd"'
      patterns_dir: '/usr/share/logstash/patterns'
      match:
        logmessage:
          - '%{SSH_AUTH}'
      add_tag:
        - 'ssh_auth'
    - plugin_name: 'grok'
      cond: 'else if [program] == "cron"'
      patterns_dir: '/usr/share/logstash/patterns'
      match:
        logmessage:
          - '%{CRONLOG}'
      add_tag:
        - 'cronlog'
    - plugin_name: 'grok'
      cond: 'else if [program] == "uwsgi"'
      patterns_dir: '/usr/share/logstash/patterns'
      match:
        logmessage:
          - '%{UWSGI}'
      add_tag:
        - 'uwsgi'
    - plugin_name: 'grok'
      cond: 'if [program] == "nginx"'
      patterns_dir: '/usr/share/logstash/patterns'
      match:
        logmessage:
          - '%{NGINX_API_ACCESS}'
      add_tag:
        - 'nginx_api_access'
    - plugin_name: 'grok'
      cond: 'if [program] == "nginx"'
      patterns_dir: '/usr/share/logstash/patterns'
      match:
        logmessage:
          - '%{NGINX_DEFAULT_ACCESS}'
      add_tag:
        - 'nginx_default_access'
    - plugin_name: 'grok'
      cond: 'if [program] == "nginx"'
      patterns_dir: '/usr/share/logstash/patterns'
      match:
        logmessage:
          - '%{NGINX_ERROR_1}'
      add_tag:
        - 'nginx_error_1'
    - plugin_name: 'grok'
      cond: 'if [program] == "nginx"'
      patterns_dir: '/usr/share/logstash/patterns'
      match:
        logmessage:
          - '%{NGINX_ERROR_2}'
      add_tag:
        - 'nginx_error_2'
    - plugin_name: 'grok'
      cond: 'if [program] == "apache"'
      patterns_dir: '/usr/share/logstash/patterns'
      match:
        logmessage:
          - '%{HTTP_SYSLOG}'
      add_tag:
        - 'http_syslog'

    - plugin_name: 'syslog_pri'
      cond: 'if [type] == "syslog"'
    - plugin_name: 'date'
      cond: 'if [time_local]'
      match:
        - 'time_local'
        - 'dd/MMM/yyy:HH:mm:ss Z'
        - 'd/MMM/yyy:HH:mm:ss Z'
        - 'MMM  d HH:mm:ss'
        - 'MMM dd HH:mm:ss'
        - "MMM dd yyyy HH:mm:ss"
        - "MMM  d yyyy HH:mm:ss"
        - 'ISO8601'
      add_tag:
        - 'time_local'
    - plugin_name: 'date'
      cond: 'else if ![timestamp8601]'
      match:
        - 'timestamp'
        - 'MMM  d HH:mm:ss'
        - 'MMM dd HH:mm:ss'
        - "MMM dd yyyy HH:mm:ss"
        - "MMM  d yyyy HH:mm:ss"
        - "ISO8601"
      add_tag:
        - 'timestamp'
    - plugin_name: date
      cond: 'else'
      match:
        - 'timestamp8601'
        - "ISO8601"
      add_tag:
        - 'timestamp8601'

    - plugin_name: 'kv'
      cond: 'if [uri_param] and [program] != "api-debug-logs"'
      source: 'uri_param'
      field_split: '&'
      transform_key: 'lowercase'
      add_tag:
        - 'uri_to_kv'
    - plugin_name: 'fingerprint'
      cond: 'if [api_key]'
      source: 'api_key'
      method: 'UUID'
      add_tag:
        - 'fingerprint'

    - plugin_name: ruby
      code: "event.set('received_at', Time.now.utc)"
    - plugin_name: 'mutate'
      cond: 'if [x_forwarded_for]'
      add_field:
        clientip: '%{x_forwarded_for}'
    - plugin_name: 'mutate'
      cond: 'else if [remote_addr]'
      add_field:
        clientip: '%{remote_addr}'
    - plugin_name: 'geoip'
      cond: 'if [clientip]'
      add_tag: 'geoip'
      source: 'clientip'

  outputs:
    - plugin_name: 'stdout'
      codec:
        rubydebug:
          enable_metric: 'true'
          metadata: 'false'
