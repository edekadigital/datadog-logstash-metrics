#! /usr/bin/env python
import os

import yaml
import sys


def error(msg):
    print()
    print('==================================================================================')
    print(msg)
    print('==================================================================================')
    print()
    exit(1)


def add_value(instance_conf, prefix, key, mandatory=False, boolean=False):
    full_key = f'{prefix}{key}'
    if full_key in os.environ:
        value = os.environ[full_key]
        if boolean:
            value = bool(value)
        instance_conf[key.lower()] = value
    elif mandatory:
        error(f'Missing mandatory environment variable {full_key}')


def parse_instance_conf(i):
    prefix = f'LOGSTASH_{i}_'
    instance_conf = {}
    add_value(instance_conf, prefix, 'URL', mandatory=True)
    add_value(instance_conf, prefix, 'SSL_VERIFY', boolean=True)
    add_value(instance_conf, prefix, 'SSL_CERT')
    add_value(instance_conf, prefix, 'SSL_KEY')
    tags = [os.environ[k] for k in sorted([k for k in os.environ.keys() if k.startswith(f'{prefix}TAGS_')])]
    if tags:
        instance_conf['tags'] = tags
    return instance_conf


def represent_none(self, _):
    return self.represent_scalar('tag:yaml.org,2002:null', '')


def dump(conf, stream):
    yaml.dump(conf, stream, default_flow_style=False)


ids = sorted(list(set([int(k.split('_')[1]) for k, v in os.environ.items() if k.startswith('LOGSTASH_')])))
if not ids:
    error('Missing environment variables LOGSTASH_{i}_*')
config = dict(init_config=None, instances=[parse_instance_conf(i) for i in ids])
yaml.add_representer(type(None), represent_none)

if len(sys.argv) >= 2 and sys.argv[1] == '-':
    dump(config, sys.stdout)
else:
    os.mkdir('/etc/datadog-agent/conf.d/logstash.d')
    with open('/etc/datadog-agent/conf.d/logstash.d/conf.yaml', 'w') as f:
        dump(config, f)
