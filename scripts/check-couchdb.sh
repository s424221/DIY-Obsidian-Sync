#!/usr/bin/env bash
# 檢查 CouchDB 是否符合 Obsidian LiveSync 的需求。
# 用法：./check-couchdb.sh <url> <username> [database]
#   例：./check-couchdb.sh http://homeassistant.tail1234.ts.net:5984 obsidian
# 密碼會提示輸入，也可以用環境變數 COUCHDB_PASSWORD 提供。
# Windows 請在 Git Bash 或 WSL 中執行。
set -uo pipefail

if [ $# -lt 2 ]; then
  echo "用法：$0 <url> <username> [database]" >&2
  exit 2
fi

URL=${1%/}
USER_NAME=$2
DB=${3:-obsidian}
if [ -z "${COUCHDB_PASSWORD:-}" ]; then
  read -r -s -p "CouchDB 密碼：" COUCHDB_PASSWORD
  echo
fi

FAILED=0
pass() { echo "  [OK]   $*"; }
fail() { echo "  [FAIL] $*"; FAILED=1; }
# expect <實際值> <預期值> <通過訊息> <失敗訊息>
expect() { if [ "$1" = "$2" ]; then pass "$3"; else fail "$4"; fi; }

status() { curl -s -o /dev/null -w '%{http_code}' --max-time 10 "$@"; }
auth=(-u "$USER_NAME:$COUCHDB_PASSWORD")

echo "檢查 $URL"

code=$(status "$URL/")
if [ "$code" = "000" ]; then
  fail "連不到伺服器。Tailscale 有連上嗎？add-on 有啟動嗎？"
  exit 1
elif [ "$code" = "401" ]; then
  pass "未登入時會被拒絕（require_valid_user 生效）"
else
  fail "未登入時應回 401，實際為 $code"
fi

code=$(status "${auth[@]}" "$URL/")
if [ "$code" = "200" ]; then
  pass "帳號密碼正確"
else
  fail "登入失敗（HTTP $code），請確認帳號密碼"
  exit 1
fi

config() { curl -s --max-time 10 "${auth[@]}" "$URL/_node/_local/_config/$1" | tr -d '"'; }

v=$(config chttpd/max_http_request_size)
expect "$v" "4294967296" "max_http_request_size = $v" "max_http_request_size 應為 4294967296，實際為 '$v'"

v=$(config couchdb/max_document_size)
expect "$v" "50000000" "max_document_size = $v" "max_document_size 應為 50000000，實際為 '$v'"

v=$(config chttpd/enable_cors)
expect "$v" "true" "CORS 已啟用" "chttpd/enable_cors 應為 true，實際為 '$v'"

for origin in app://obsidian.md capacitor://localhost http://localhost; do
  allowed=$(curl -s -D - -o /dev/null --max-time 10 -X OPTIONS \
    -H "Origin: $origin" \
    -H "Access-Control-Request-Method: GET" \
    -H "Access-Control-Request-Headers: authorization,content-type" \
    "$URL/" | tr -d '\r' | awk -F': ' 'tolower($1)=="access-control-allow-origin"{print $2}')
  expect "$allowed" "$origin" "CORS 允許 $origin" "CORS 未允許 $origin"
done

code=$(status "${auth[@]}" "$URL/$DB")
expect "$code" "200" "資料庫 $DB 存在" "資料庫 $DB 不存在（HTTP $code）"

echo
if [ "$FAILED" = 0 ]; then
  echo "全部通過，可以開始設定 LiveSync。"
else
  echo "有項目未通過，請參考 docs/04-troubleshooting.md。"
  exit 1
fi
