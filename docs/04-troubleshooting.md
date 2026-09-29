# 4. 疑難排解

## 連不上伺服器

依序檢查：

1. **Tailscale 有連上嗎？** 這台裝置和 Pi 在 Tailscale app 裡都要顯示為連線中。
2. **add-on 有在跑嗎？** 看 HA 裡 add-on 的 Log 分頁有沒有「CouchDB 已就緒」。
3. **port 有沒有被關掉？** add-on 的 **Configuration → Network** 裡，5984 不能是空白（空白代表停用）。
4. **在家可以連，在外面不行？**
   - Tailscale 管理後台 → Machines → Pi → **Edit route settings**，確認區網網段已經核准。
   - Windows / Mac 的 Tailscale 選單裡，**Use Tailscale subnets** 要勾選。
   - 重新啟動 HA 的 Tailscale add-on 再試一次。
5. **在某些外部網路連不上**：那個網路可能剛好跟你家同網段（例如也是 `192.168.2.x`），流量被送到當地的網路了。這時把 LiveSync 的 URI 暫時改成 Pi 的 Tailscale IP（`http://100.x.y.z:5984`，在 Tailscale app 或管理後台可以查到）。
   根本的解法是把家裡路由器的網段改成比較少見的，例如 `192.168.87.x`。

## Android 上 LiveSync 連不上，但電腦可以（HTTP 被擋）

部分 Android 或 Obsidian 版本可能不允許連 `http://` 開頭的網址。**Tailscale 的連線本身已經加密**，但如果 app 堅持要 HTTPS，可以讓 Tailscale 幫你加上 HTTPS 和有效憑證：

1. Tailscale 管理後台 → **DNS** → 開啟 **HTTPS Certificates**。
2. HA 安裝 **Advanced SSH & Web Terminal** add-on，在它的設定裡**關閉 Protection mode**，然後啟動並開啟終端機。
3. 找出 Tailscale add-on 的容器名稱：
   ```bash
   docker ps --format '{{.Names}}' | grep -i tailscale
   ```
4. 用 Tailscale 把 HTTPS 的 6984 port 轉給 CouchDB（把 `<容器名稱>` 換成上一步查到的名稱）：
   ```bash
   docker exec <容器名稱> tailscale serve --bg --https=6984 http://127.0.0.1:5984
   docker exec <容器名稱> tailscale serve status
   ```
   如果轉過去連不到，把 `127.0.0.1` 換成 Pi 的區網 IP 再試一次。
5. 所有裝置的 LiveSync URI 改成（HTTPS 憑證只綁 `*.ts.net` 名稱，這裡不能用區網 IP；Tailscale 管理後台的 **DNS** 頁面要開啟 **MagicDNS**） `https://homeassistant.<tailnet>.ts.net:6984`。
6. 用 `./scripts/check-couchdb.sh https://homeassistant.<tailnet>.ts.net:6984 obsidian` 驗證。
7. **重新啟動 Tailscale add-on 和 HA 之後，再跑一次 `tailscale serve status`**，確認設定還在。
   如果 Tailscale add-on 的 Home Assistant 分享功能也有開，它可能會覆蓋這個設定；不見了就重新執行第 4 步。

## 檢查腳本出現 `[FAIL]`

- **CORS 相關失敗**：add-on 設定沒有正確套用。重新啟動 add-on，看 Log 有沒有錯誤。
- **資料庫不存在**：確認 add-on 的 `database` 選項和腳本第三個參數一致（預設是 `obsidian`）。
- **登入失敗**：改了密碼後有沒有重新啟動 add-on？

## 同步衝突

- LiveSync 會自動合併大部分衝突；無法自動合併時，會跳出比較視窗讓你選擇要保留哪個版本。
- 常常衝突，通常是同步了 `.obsidian/workspace*.json`，請參考 [建議設定](03-clients.md#建議設定) 把它們排除。

## 資料庫越來越大

- CouchDB 3 內建自動 compaction，會定期清掉舊版本、釋放空間，一般不用手動處理。
- 想手動整理：開 `http://<Pi>:5984/_utils`，登入後選資料庫 → **Compact & Clean**。
- 如果變得非常大，LiveSync 設定裡有「重建資料庫」之類的維護功能：先在主力裝置上重建，其他裝置再重新抓取。

## USB 隨身碟與 SSD

- CouchDB 的寫入量隨你改筆記的頻率而定，一般個人使用量很小，隨身碟撐得住。
- 但隨身碟本身壽命和可靠度都不如 SSD。之後建議換成 USB SSD，Pi 5 從 USB 開機沒問題，用 HA 的完整備份還原到 SSD 即可。
- 無論用哪種，都要把**自動備份存到 Pi 以外的地方**。

## 在電腦上本機測試 add-on（不用 HA）

有 Docker 的話可以直接跑：

```bash
mkdir -p ./testdata
echo '{"username":"obsidian","password":"change-me-123","database":"obsidian"}' > ./testdata/options.json
docker build -t obsidian-livesync ./obsidian-livesync
docker run --rm -p 5984:5984 -v "$PWD/testdata:/data" obsidian-livesync
# 另開一個終端機
COUCHDB_PASSWORD=change-me-123 ./scripts/check-couchdb.sh http://127.0.0.1:5984 obsidian
```
