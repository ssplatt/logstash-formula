# -*- coding: utf-8 -*-
# vim: ft=sls
{%- from "logstash/map.jinja" import logstash with context %}

logstash_service:
  service.{{ logstash.service.state }}:
    - name: {{ logstash.service.name }}
    - enable: {{ logstash.service.enable }}
