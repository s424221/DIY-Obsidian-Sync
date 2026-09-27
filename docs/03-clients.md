# 3. 在 Windows / Mac / Android 設定 Obsidian LiveSync

> LiveSync 更新頻繁，按鈕和選項名稱可能跟這裡寫的略有不同，找意思相近的即可。

## 原則

- **只有第一台裝置上傳現有的 vault**，其他裝置一律從**空的 vault**開始，由伺服器同步下來。這樣可以避免一開始就產生大量重複檔案和衝突。
- 一定要開啟**端對端加密（E2EE）**：伺服器上只會存密文，就算 Pi 被別人拿走也讀不到筆記。
- 設定前先備份一份 vault（直接把資料夾壓縮起來就好）。

## 第一台裝置（放著現有 vault 的那台，通常是主力電腦）

1. 確認 Tailscale 已連線。
2. Obsidian → **設定 → 第三方外掛（Community plugins）** → 關閉安全模式 → 瀏覽 → 搜尋 **Self-hosted LiveSync** → 安裝並啟用。
3. 開啟 LiveSync 設定，依照設定精靈選擇 **手動設定 / CouchDB**，然後填入：
   | 欄位 | 值 |
   |---|---|
   | URI | `http://homeassistant.<tailnet>.ts.net:5984` |
   | Username | add-on 設定的 `username` |
   | Password | add-on 設定的 `password` |
   | Database name | `obsidian` |
4. 按 **Test / Check** 測試連線。如果它提示伺服器設定有問題並提供自動修正，通常可以直接套用（本 add-on 已經預先設好，一般不會出現）。
5. 如果有 **Use Request API** 之類的選項（用來避開 CORS 問題），可以開啟。
6. **End-to-end encryption**：開啟，並設一組 passphrase。**這組 passphrase 請另外存好**，其他裝置也要用到，忘記就解不開了。
7. 同步模式選 **LiveSync**（即時同步）。
8. 執行初次上傳（Rebuild / Send everything 之類的選項），等它把整個 vault 傳到伺服器。

### 產生 Setup URI（讓其他裝置一鍵設定）

1. 按 `Ctrl/Cmd + P` 開啟指令面板，執行 **Self-hosted LiveSync: Copy settings as a new setup URI**（或名稱類似的指令）。
2. 它會要你設一組「URI 密碼」，用來加密這串 URI。
3. 把複製下來的 URI 傳給自己，例如用 Tailscale 的 Taildrop 或密碼管理器，**不要貼在公開的地方**。

## 其他裝置（Mac / Android）

1. 安裝並登入 Tailscale（Android 記得完成 [這兩個設定](02-tailscale.md#在三台裝置安裝-tailscale)）。
2. 在 Obsidian **建立一個新的空 vault**。
   - Android：vault 可以放在內部儲存空間的 `Documents/` 底下，方便日後用檔案管理器備份。
3. 安裝並啟用 **Self-hosted LiveSync**。
4. 指令面板執行 **Use the copied setup URI**（或名稱類似的指令），貼上 URI，輸入 URI 密碼。
5. 被問到身分時，選 **這是第二台（或之後）的裝置**，讓它從伺服器下載資料，而不是上傳。
6. 等它同步完成，筆記就會出現。

## 建議設定

- **Hidden file sync（`.obsidian` 資料夾同步）**：建議一開始先**不要開**，每台裝置各自管理外掛和外觀，最不容易出問題。
  - 如果之後想同步 `.obsidian`，務必把 `workspace.json` 和 `workspace-mobile.json` 加進忽略清單。這兩個檔案記錄每台裝置開了哪些分頁，每台都不一樣，同步只會一直產生衝突。
  - 只能在桌機上用的外掛也不要同步到 Android。
- **Customization sync**：LiveSync 內建的外掛設定同步功能，比 hidden file sync 更安全，可以選擇性地同步，需要時再開。

## 驗證同步

1. 在 A 裝置新增一則筆記，幾秒內 B 裝置應該就會出現。
2. 在 B 修改同一則筆記，確認 A 也更新了。
3. 把 Android 切成飛航模式，修改一則筆記，再恢復網路，確認修改有同步出去。

完成！遇到問題請看 [疑難排解](04-troubleshooting.md)。
