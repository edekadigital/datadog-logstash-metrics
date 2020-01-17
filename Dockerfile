FROM datadog/agent:7

RUN apt-get update && \
    apt-get install -y --no-install-recommends git && \
    git clone https://github.com/DataDog/integrations-extras.git "/opt/integrations-extras" && \
    pip install "datadog-checks-dev[cli]" && \
    ddev config set extras "/opt/integrations-extras" && \
    ddev -e release build logstash && \
    pip uninstall -y \
     astroid \
     atomicwrites \
     bleach \
     cached-property \
     click \
     coverage \
     datadog-checks-dev \
     docker \
     docker-compose \
     dockerpty \
     docker-pycreds \
     docopt \
     filelock \
     importlib-metadata \
     isort \
     jeepney \
     jsonschema \
     keyring \
     lazy-object-proxy \
     mccabe \
     mock \
     more-itertools \
     packaging \
     Pillow \
     pip-tools \
     pkginfo \
     pluggy \
     py \
     py-cpuinfo \
     Pygments \
     pylint \
     pyparsing \
     pyperclip \
     pytest \
     pytest-benchmark \
     pytest-cov \
     pytest-mock \
     readme-renderer \
     requests-toolbelt \
     secretstorage \
     texttable \
     toml \
     tox \
     tqdm \
     twine \
     typed-ast \
     virtualenv \
     wcwidth \
     webencodings \
     wheel \
     zipp \
    && \
    touch /etc/datadog-agent/datadog.yaml && \
    agent integration install -r -w /opt/integrations-extras/logstash/dist/datadog_logstash-*.whl && \
    rm -f /etc/datadog-agent/datadog.yaml && \
    apt-get purge -y git && \
    apt-get autoremove -y && \
    rm -rf /var/cache/apt /root/.cache

COPY create-logstash-plugin-conf.py /etc/cont-init.d/59-logstash.py
COPY start.sh /usr/local/bin/start.sh
ENTRYPOINT ["/usr/local/bin/start.sh"]
