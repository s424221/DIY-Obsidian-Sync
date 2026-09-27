# 2. 用 Tailscale 從外面連回 Pi

Tailscale 會把你所有裝置放進同一個私人虛擬網路（tailnet），連線全程用 WireGuard 加密。**不用在路由器開任何 port**，CouchDB 也不會暴露在公網上。

## 在 Home Assistant 安裝 Tailscale

1. **設定 → Add-ons → Add-on Store**，搜尋 **Tailscale**，安裝並啟動。
2. 打開它的 **Web UI**，用你的 Tailscale 帳號登入（Google / Microsoft / GitHub 帳號都可以）。
3. 到 [Tailscale 管理後台 → Machines](https://login.tailscale.com/admin/machines) 確認 Pi 出現在清單上，記下它的名稱，例如 `homeassistant`。
4. 在管理後台的 **DNS** 頁面確認 **MagicDNS** 已開啟（新帳號預設開啟）。
   Pi 的完整名稱會是 `homeassistant.<你的 tailnet 名稱>.ts.net`，同一個頁面也看得到 tailnet 名稱。
5. 建議在 Machines 裡對 Pi 選 **Disable key expiry**，避免幾個月後金鑰過期，突然就連不上。

## 在三台裝置安裝 Tailscale

| 平台 | 安裝 | 要注意的設定 |
|---|---|---|
| Windows | [tailscale.com/download](https://tailscale.com/download) | 登入後設成開機自動啟動（預設即是） |
| Mac | Mac App Store 或官網 | 同上 |
| Android | Play 商店的 **Tailscale** | 見下方 |

**Android 要多做兩件事，不然切到背景就會斷線：**
1. 系統 **設定 → 網路 → VPN → Tailscale 旁的齒輪 → 開啟「永久連線 VPN」（Always-on VPN）**。
2. 系統 **設定 → 應用程式 → Tailscale → 電池 → 不受限制**。

> Android 同一時間只能開一個 VPN。開著 Tailscale 時，就不能再用其他 VPN app。

## 測試連線

把手機的 Wi-Fi 關掉改用行動網路（模擬在外面），然後：

- 瀏覽器開 `http://homeassistant.<tailnet>.ts.net:5984/`，應該會跳出登入框或回應 `unauthorized`，這代表連得到。
- 電腦上跑：
  ```bash
  ./scripts/check-couchdb.sh http://homeassistant.<tailnet>.ts.net:5984 obsidian
  ```
  全部 `[OK]` 就可以進行下一步。

連不上的話請看 [疑難排解](04-troubleshooting.md#連不上伺服器)。

下一步：[3. 設定 Obsidian LiveSync](03-clients.md)
