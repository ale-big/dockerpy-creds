FROM python:3.6
RUN apt-get update && apt-get -y install \
    gnupg2 \
    haveged \
    pass \
    curl

COPY ./tests/create_gpg_key.sh /create_gpg_key.sh
RUN sh /create_gpg_key.sh
RUN pass init $(gpg2 --no-auto-check-trustdb --list-secret-keys | grep ^sec | cut -d/ -f2 | cut -d" " -f1)
ARG VERSION=v0.6.0
RUN curl -sSL -o /opt/docker-credential-pass.tar.gz \
    https://github.com/docker/docker-credential-helpers/releases/download/$VERSION/docker-credential-pass-$VERSION-amd64.tar.gz && \
    tar -xf /opt/docker-credential-pass.tar.gz -O > /usr/local/bin/docker-credential-pass && \
    rm -rf /opt/docker-credential-pass.tar.gz && \
    chmod +x /usr/local/bin/docker-credential-pass
COPY . /src
WORKDIR /src
RUN python setup.py develop && pip install -r test-requirements.txt
CMD pytest -v ./tests
