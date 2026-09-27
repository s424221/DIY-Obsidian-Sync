# 1. 在 Home Assistant 安裝 CouchDB add-on

> HA 的選單名稱會隨版本變動，新版的「Add-ons」可能改叫「Apps」，位置大致相同。

## 方法 A：把這個 repo 加成 add-on repository（repo 為公開時）

1. HA 左側選單 → **設定 → Add-ons → Add-on Store**。
2. 右上角 **⋮ → Repositories**，貼上：
   ```
   https://github.com/s424221/DIY-Obsidian-Sync
   ```
3. 關掉對話框，重新整理頁面，往下捲會看到 **DIY Obsidian Sync → Obsidian LiveSync CouchDB**。
4. 點進去按 **Install**。第一次會在 Pi 上 build 映像，大約需要幾分鐘。

## 方法 B：當成 local add-on 安裝（repo 為私有時）

HA 沒辦法直接讀取私有 GitHub repo，改成手動複製：

1. 安裝官方的 **Samba share** add-on（或 **Advanced SSH & Web Terminal**），並啟動它。
2. 把這個 repo 的 `obsidian-livesync` 整個資料夾複製到 HA 的 `addons` 分享資料夾，變成：
   ```
   /addons/obsidian-livesync/config.yaml
   /addons/obsidian-livesync/Dockerfile
   ...
   ```
3. **Add-on Store → ⋮ → Check for updates**，重新整理後在 **Local add-ons** 區塊會出現它，按 **Install**。

> 在 Windows 上複製時，請確認 `rootfs/run.sh` 的換行是 LF，不是 CRLF，否則 add-on 會啟動失敗。本 repo 的 `.gitattributes` 已經強制使用 LF。

## 設定並啟動

1. 進入 add-on 的 **Configuration** 分頁：
   - `username`：例如 `obsidian`
   - `password`：設一組強密碼，至少 8 個字元，不能包含 `;`
   - `database`：維持 `obsidian` 即可
2. 按 **Save**，回到 **Info** 分頁：
   - 開啟 **Start on boot**
   - 開啟 **Watchdog**（當掉會自動重啟）
   - 按 **Start**
3. 到 **Log** 分頁，看到下面這兩行就代表成功：
   ```
   [obsidian-livesync] 已建立資料庫 obsidian
   [obsidian-livesync] CouchDB 已就緒，port 5984
   ```
   第一次啟動時，log 裡可能會出現幾行 CouchDB 自己建立系統資料庫的 `[warning]` 或 `[error]`，只要最後有「已就緒」就沒問題。

## 先在家裡區網測試

在同一個區網的電腦上用瀏覽器開 `http://<Pi 的 IP>:5984/_utils`，這是 CouchDB 內建的管理介面。能用剛剛的帳號密碼登入，就代表伺服器正常。

也可以跑檢查腳本（Mac 用終端機，Windows 用 Git Bash 或 WSL）：

```bash
./scripts/check-couchdb.sh http://<Pi 的 IP>:5984 obsidian
```

## 備份（重要：你的 HA 跑在 USB 隨身碟上）

- add-on 的資料存在 `/data/couchdb`，HA 的備份預設會包含它。
- 隨身碟比 SSD 更容易壞，請在 **設定 → 系統 → 備份** 開啟自動備份，並把備份存到**Pi 以外的地方**（NAS 網路儲存，或 Google Drive 備份類的 add-on）。
- 同步時，每台裝置上都有完整的 vault，所以伺服器就算壞了筆記也不會消失；重建伺服器後，從任一台裝置重新上傳即可。

下一步：[2. 設定 Tailscale](02-tailscale.md)
