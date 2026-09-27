# Obsidian LiveSync CouchDB

給 [Self-hosted LiveSync](https://github.com/vrtmrz/obsidian-livesync) 用的 CouchDB 伺服器，已預先套用 LiveSync 需要的設定（CORS、請求大小上限、強制登入）。

## 設定

| 選項 | 說明 |
|---|---|
| `username` | CouchDB 管理者帳號，LiveSync 也用這組帳號登入 |
| `password` | 至少 8 個字元，不能含分號 `;`，開頭結尾不能是空白 |
| `database` | vault 使用的資料庫名稱，只能用小寫英數、`_`、`-`，預設 `obsidian` |

改了帳號或密碼後，重新啟動 add-on 就會生效；資料不受影響。

## 連線位址

- 家裡區網：`http://<Pi 的 IP>:5984`
- 外面（透過 Tailscale）：`http://<Pi 的 Tailscale 名稱>:5984`

資料存在 add-on 的 `/data/couchdb`，會被 Home Assistant 的備份包含。

完整教學請看 repo 裡的 `docs/` 資料夾。
