# -*- coding: utf-8 -*-
# vim: ft=sls
# Init Logstash
{%- from "logstash/map.jinja" import logstash with context %}

{%- if logstash.enabled %}
include:
  - logstash.install
  - logstash.config
  - logstash.service
{%- else %}
'logstash-formula disabled':
  test.succeed_without_changes
{%- endif %}
