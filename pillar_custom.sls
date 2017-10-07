# -*- coding: utf-8 -*-
# vim: ft=yaml
---
logstash:
  enabled: True
  service:
    name: logstash
    state: running
    enable: True
  config:
    path.data: /var/lib/logstash
    path.config: /etc/logstash/conf.d
    path.logs: /var/log/logstash
  plugins:
    - x-pack
  jvm:
    - -Xms256m
    - -Xmx4g
    - -XX:+UseParNewGC
    - -XX:+UseConcMarkSweepGC
    - -XX:CMSInitiatingOccupancyFraction=75
    - -XX:+UseCMSInitiatingOccupancyOnly
    - -XX:+DisableExplicitGC
    - -Djava.awt.headless=true
    - -Dfile.encoding=UTF-8
    - -XX:+HeapDumpOnOutOfMemoryError
  startup:
    javacmd: /usr/bin/java
    ls_home: /usr/share/logstash
    ls_settings_dir: /etc/logstash
    ls_opts: '"--path.settings ${LS_SETTINGS_DIR}"'
    ls_java_opts: '""'
    ls_pidfile: /var/run/logstash.pid
    ls_user: logstash
    ls_group: logstash
    ls_gc_log_file: /var/log/logstash/gc.log
    ls_open_files: 16384
    ls_nice: 19
    service_name: '"logstash"'
    service_description: '"logstash"'
  log4j:
    status: error
    name: LogstashPropertiesConfig
    appender.rolling.type: RollingFile
    appender.rolling.name: plain_rolling
    appender.rolling.fileName: "${sys:ls.logs}/logstash-${sys:ls.log.format}.log"
    appender.rolling.filePattern: "${sys:ls.logs}/logstash-${sys:ls.log.format}-%d{yyyy-MM-dd}.log.gz"
    appender.rolling.strategy.type: DefaultRolloverStrategy
    appender.rolling.strategy.fileIndex: min
    appender.rolling.strategy.max: 7
    appender.rolling.policies.type: Policies
    appender.rolling.policies.time.type: TimeBasedTriggeringPolicy
    appender.rolling.policies.time.interval: 1
    appender.rolling.policies.time.modulate: true
    appender.rolling.layout.type: PatternLayout
    appender.rolling.layout.pattern: "[%d{ISO8601}][%-5p][%-25c] %-.10000m%n"
    appender.json_rolling.type: RollingFile
    appender.json_rolling.name: json_rolling
    appender.json_rolling.fileName: "${sys:ls.logs}/logstash-${sys:ls.log.format}.log"
    appender.json_rolling.filePattern: "${sys:ls.logs}/logstash-${sys:ls.log.format}-%d{yyyy-MM-dd}.log.gz"
    appender.json_rolling.strategy.type: DefaultRolloverStrategy
    appender.json_rolling.strategy.fileIndex: min
    appender.json_rolling.strategy.max: 7
    appender.json_rolling.policies.type: Policies
    appender.json_rolling.policies.time.type: TimeBasedTriggeringPolicy
    appender.json_rolling.policies.time.interval: 1
    appender.json_rolling.policies.time.modulate: true
    appender.json_rolling.layout.type: JSONLayout
    appender.json_rolling.layout.compact: true
    appender.json_rolling.layout.eventEol: true
    rootLogger.level: ${sys:ls.log.level}
    rootLogger.appenderRef.rolling.ref: ${sys:ls.log.format}_rolling
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
    - plugin_name: file
      path:
        - /var/log/syslog
        - /var/log/auth.log
      type: syslog
    - plugin_name: udp
      port: 25826
      type: collectd
      host: 0.0.0.0
      codec:
        collectd:
          nan_handling: 'change_value'
          prune_intervals: 'true'
          typesdb:
            - '/tmp/types.db'
            - '/tmp/othertypes.db'

  filters:
    - plugin_name: 'grok'
      patterns_dir: '/usr/share/logstash/patterns'
      match:
        message:
          - '%{SYSLOGLINE2}'
      add_field:
        received_from: '%{host}'
        received_at: '%{@timestamp}'
      add_tag:
        - 'syslogline2'
    - plugin_name: grok
      cond: 'if [type] == "syslog"'
      match:
        message:
          - "%{FAIL2BAN}"
          - "%{SSH_LOGIN}"
          - "%{SSH_AUTH}"
          - "%{HTTP_SYSLOG}"
          - "%{CRONLOG}"
      add_tag:
        - "syslog"
    - plugin_name: grok
      cond: 'else if [type] == "nginx"'
      match:
        message: '%{IPORHOST:clientip} %{USER:ident} %{USER:auth} \[%{HTTPDATE:timestamp}\] \"(?:%{WORD:verb} %{URIPATHPARAM:request}(?: HTTP/%{NUMBER:httpversion})?|-)\" %{NUMBER:response} (?:%{NUMBER:bytes}|-) \"(?:%{URI:referrer}|-)\" %{QS:agent}'
      add_tag:
        - "nginx"
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
  outputs:
    - plugin_name: elasticsearch
      hosts:
        - localhost
