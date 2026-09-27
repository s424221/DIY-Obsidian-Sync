#!/bin/bash
# Home Assistant add-on 進入點：讀取 add-on 選項、產生 CouchDB 設定、啟動 CouchDB。
set -euo pipefail

OPTIONS=/data/options.json
DATA_DIR=/data/couchdb
STATE_INI=/data/state.ini
LOCAL_D=/opt/couchdb/etc/local.d

log() { echo "[obsidian-livesync] $*"; }
die() { log "錯誤：$*" >&2; exit 1; }

[ -f "$OPTIONS" ] || die "找不到 $OPTIONS"

USERNAME=$(jq -r '.username // ""' "$OPTIONS")
PASSWORD=$(jq -r '.password // ""' "$OPTIONS")
DATABASE=$(jq -r '.database // "obsidian"' "$OPTIONS")

[ -n "$USERNAME" ] || die "請在 add-on 設定頁填入 username"
[ -n "$PASSWORD" ] || die "請在 add-on 設定頁填入 password 後再啟動"
[ "${#PASSWORD}" -ge 8 ] || die "password 至少要 8 個字元"
case "$PASSWORD" in
  *";"*) die "password 不能包含分號 ;（CouchDB 設定檔會把它當成註解）" ;;
  " "*|*" ") die "password 開頭或結尾不能是空白" ;;
esac

mkdir -p "$DATA_DIR"

# uuid 與 cookie secret 只在第一次啟動時產生並保存，避免每次重啟都讓登入 session 失效
if [ ! -f "$STATE_INI" ]; then
  log "第一次啟動，產生 uuid 與 secret"
  {
    echo "[couchdb]"
    echo "uuid = $(head -c 16 /dev/urandom | od -An -tx1 | tr -d ' \n')"
    echo
    echo "[chttpd_auth]"
    echo "secret = $(head -c 32 /dev/urandom | od -An -tx1 | tr -d ' \n')"
  } > "$STATE_INI"
  chmod 600 "$STATE_INI"
fi

cp /etc/obsidian-livesync/livesync.ini "$LOCAL_D/10-livesync.ini"
cp "$STATE_INI" "$LOCAL_D/20-state.ini"
# 每次啟動都重寫管理者帳密，改了 add-on 設定後重啟就會生效（CouchDB 啟動時會自動雜湊）
printf '[admins]\n%s = %s\n' "$USERNAME" "$PASSWORD" > "$LOCAL_D/30-admin.ini"
chmod 600 "$LOCAL_D/20-state.ini" "$LOCAL_D/30-admin.ini"

chown -R couchdb:couchdb "$DATA_DIR"

# CouchDB 起來之後建立 vault 用的資料庫（已存在就略過）
(
  for _ in $(seq 1 120); do
    if curl -fsS -u "$USERNAME:$PASSWORD" http://127.0.0.1:5984/_up >/dev/null 2>&1; then
      code=$(curl -s -o /dev/null -w '%{http_code}' -u "$USERNAME:$PASSWORD" \
        -X PUT "http://127.0.0.1:5984/$DATABASE")
      case "$code" in
        201|202) log "已建立資料庫 $DATABASE" ;;
        412) log "資料庫 $DATABASE 已存在" ;;
        *) log "建立資料庫 $DATABASE 失敗（HTTP $code）" ;;
      esac
      log "CouchDB 已就緒，port 5984"
      exit 0
    fi
    sleep 1
  done
  log "等待 CouchDB 啟動逾時，請查看上方 log"
) &

log "啟動 CouchDB"
exec /docker-entrypoint.sh /opt/couchdb/bin/couchdb
