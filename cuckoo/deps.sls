include:
  - cuckoo.virtualbox

cuckoo_dependencies:
  pkg.installed:
    - refresh: True
    - pkgs:
      - git
      - python-pip
      - libffi-dev
      - libssl-dev
      - python-dev
      - unzip
      - libxml2-dev
      - libxslt-dev
      - libjpeg-dev
      - libpq-dev
      - automake
      - libtool
      - libjansson-dev
      - libmagic-dev
      - mongodb
      - postgresql
      - tcpdump

pip:
  pip.installed:
    - upgrade: True
    - reload_modules: True
    - require:
      - pkg: cuckoo_dependencies

cuckoo_pip:
  pip.installed:
    - upgrade: True
    - require:
      - pip: pip
    - pkgs:
      - psycopg2
      - yara-python
      - distorm3

cuckoo_setcap:
  cmd.run:
    - name: setcap cap_net_raw,cap_net_admin=eip /usr/sbin/tcpdump
    - require:
      - pkg: cuckoo_dependencies

mongodb:
  service.running:
    - enable: True

postgresql:
  service.running:
    - enable: True

cuckoodb:
  postgres_database.present:
    - name: {{ salt['pillar.get']('db:name', 'cuckoo') }}
    - require:
      - service: postgresql

cuckoodb_user:
  postgres_user.present:
    - name: {{ salt['pillar.get']('db:user', 'cuckoo') }}
    - password: {{ salt['pillar.get']('db:password', 'cuckoo') }}
    - require:
      - service: postgresql

cuckoodb_priv:
  postgres_privileges.present:
    - name: {{ salt['pillar.get']('db:name', 'cuckoo') }}
    - object_name: {{ salt['pillar.get']('db:user', 'cuckoo') }}
    - object_type: database
    - privileges:
      - ALL
    - require:
      - postgres_database: cuckoodb
      - postgres_user: cuckoodb_user

cuckoo_user:
  group.present:
    - name: {{ salt['pillar.get']('db:user'), 'cuckoo'}}
    - require:
      - sls: cuckoo.virtualbox
  user.present:
    - name: {{ salt['pillar.get']('db:user'), 'cuckoo'}}
    - fullname: cuckoo
    - gid_from_name: True
    - shell: /bin/bash
    - home: /srv/{{ salt['pillar.get']('db:user'), 'cuckoo'}}
    - groups:
      - vboxusers
    - require:
      - sls: cuckoo.virtualbox
