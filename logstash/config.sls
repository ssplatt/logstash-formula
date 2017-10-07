# -*- coding: utf-8 -*-
# vim: ft=sls
{% from "logstash/map.jinja" import logstash with context %}
logstash_main_config:
  file.managed:
    - name: /etc/logstash/logstash.yml
    - source: salt://logstash/files/logstash.yml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: 664

logstash_jvm_options:
  file.managed:
    - name: /etc/logstash/jvm.options
    - source: salt://logstash/files/jvm_options.j2
    - template: jinja
    - user: root
    - group: root
    - mode: 664

logstash_log4j2_properties.j2:
  file.managed:
    - name: /etc/logstash/log4j2.properties
    - source: salt://logstash/files/log4j2_properties.j2
    - template: jinja
    - user: root
    - group: root
    - mode: 664

logstash_startup_options:
  file.managed:
    - name: /etc/logstash/startup.options
    - source: salt://logstash/files/startup_options.j2
    - template: jinja
    - user: root
    - group: root
    - mode: 664

logstash_extra_patterns_dir:
  file.directory:
    - name: /usr/share/logstash/patterns
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

{% for k,v in logstash.patterns.iteritems() %}
{%   if v %}
logstash_extra_patterns_{{ k }}:
  file.managed:
    - name: /usr/share/logstash/patterns/{{ k }}
    - source: salt://logstash/files/patterns/{{ k }}
    - mode: 0644
    - user: root
    - group: root
{%   endif %}
{% endfor %}

{%- if logstash.inputs is defined %}
logstash_config_inputs:
  file.managed:
    - name: /etc/logstash/conf.d/01-inputs.conf
    - user: root
    - group: root
    - mode: 0644
    - source: salt://logstash/files/01-inputs.conf
    - template: jinja
    - watch_in:
      - service: logstash_service
{%- else %}
logstash_config_inputs:
  file.absent:
    - name: /etc/logstash/conf.d/01-inputs.conf
{%- endif %}

{%- if logstash.filters is defined %}
logstash_config_filters:
  file.managed:
    - name: /etc/logstash/conf.d/02-filters.conf
    - user: root
    - group: root
    - mode: 0644
    - source: salt://logstash/files/02-filters.conf
    - template: jinja
    - watch_in:
      - service: logstash_service
{%- else %}
logstash_config_filters:
  file.absent:
    - name: /etc/logstash/conf.d/02-filters.conf
{%- endif %}

{%- if logstash.outputs is defined %}
logstash_config_outputs:
  file.managed:
    - name: /etc/logstash/conf.d/03-outputs.conf
    - user: root
    - group: root
    - mode: 0644
    - source: salt://logstash/files/03-outputs.conf
    - template: jinja
    - watch_in:
      - service: logstash_service
{%- else %}
logstash_config_outputs:
  file.absent:
    - name: /etc/logstash/conf.d/03-outputs.conf
{%- endif %}
