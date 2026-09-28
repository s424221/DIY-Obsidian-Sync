# 直接指定 CouchDB 官方映像（多架構，Pi 會自動抓 arm64 版）。
# 不使用 Supervisor 傳入的 BUILD_FROM：新版 Supervisor 會把它預設成 HA 的 Alpine base image。
FROM couchdb:3.4

# 只需要 Debian 官方套件庫；拿掉 CouchDB 自己的 apt 套件庫，避免它連不到時整個 build 失敗
RUN rm -f /etc/apt/sources.list.d/couchdb.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends jq \
    && rm -rf /var/lib/apt/lists/*

COPY rootfs/ /
RUN chmod +x /run.sh

ENTRYPOINT ["tini", "--", "/run.sh"]
