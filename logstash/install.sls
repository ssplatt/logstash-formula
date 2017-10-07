# -*- coding: utf-8 -*-
# vim: ft=sls
{% from "logstash/map.jinja" import logstash with context %}

logstash_install_dependencies:
  pkg.installed:
    - pkgs: {{ logstash.dep_pkgs }}
    {% if logstash.dep_fromrepo is defined %}
    - fromrepo: {{ logstash.dep_fromrepo }}
    {% endif %}

logstash_install_main_package:
  pkg.installed:
    - name: {{ logstash.pkg }}

{% if logstash.plugins is defined %}
{%  for k in logstash.plugins %}
logstash_install_plugin_{{ k }}:
  cmd.run:
    - name: bin/logstash-plugin install {{ k }}
    - cwd: /usr/share/logstash
    - unless: /usr/share/logstash/bin/logstash-plugin list | grep {{ k }}
    - watch_in:
      - service: logstash_service
{%  endfor %}
{% endif %}
