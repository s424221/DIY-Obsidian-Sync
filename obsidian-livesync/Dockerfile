ARG BUILD_FROM=couchdb:3.4
FROM ${BUILD_FROM}

RUN apt-get update \
    && apt-get install -y --no-install-recommends jq \
    && rm -rf /var/lib/apt/lists/*

COPY rootfs/ /
RUN chmod +x /run.sh

ENTRYPOINT ["tini", "--", "/run.sh"]
