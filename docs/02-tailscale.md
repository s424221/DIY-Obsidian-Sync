# 2. 用 Tailscale 從外面連回 Pi

Tailscale 會把你所有裝置放進同一個私人虛擬網路（tailnet），連線全程用 WireGuard 加密。**不用在路由器開任何 port**，CouchDB 也不會暴露在公網上。

## 在 Home Assistant 安裝 Tailscale

1. **設定 → Add-ons → Add-on Store**，搜尋 **Tailscale**，安裝並啟動。
2. 打開它的 **Web UI**，用你的 Tailscale 帳號登入（Google / Microsoft / GitHub 帳號都可以）。
3. 到 [Tailscale 管理後台 → Machines](https://login.tailscale.com/admin/machines) 確認 Pi 出現在清單上，例如名稱是 `homeassistant`。
4. **核准區網路由（subnet route）**：HA 的 Tailscale add-on 會把 Pi 所在的區網（例如 `192.168.1.0/24`）廣播給 tailnet。在 Machines 裡點 Pi 旁的 **⋯ → Edit route settings**，勾選這個網段並儲存。
   核准後，任何連上 Tailscale 的裝置，即使人在外面，也能直接用 **Pi 的區網 IP**（例如 `192.168.1.50`）連到它。
   如果清單裡沒有網段可以勾，到 Tailscale add-on 的設定確認 `advertise_routes` 有包含你的區網。
5. **固定 Pi 的區網 IP**：在路由器的 DHCP 設定幫 Pi 保留固定 IP，或在 HA 的 **設定 → 系統 → 網路** 設定靜態 IPv4。IP 變了，所有裝置的 LiveSync 設定都要跟著改。
6. 建議在 Machines 裡對 Pi 選 **Disable key expiry**，避免幾個月後金鑰過期，突然就連不上。

## 在三台裝置安裝 Tailscale

| 平台 | 安裝 | 要注意的設定 |
|---|---|---|
| Windows | [tailscale.com/download](https://tailscale.com/download) | 開機自動啟動（預設即是）；工作列 Tailscale 選單裡的 **Use Tailscale subnets** 要勾選 |
| Mac | Mac App Store 或官網 | 同上，選單裡的 **Use Tailscale subnets** 要勾選 |
| Android | Play 商店的 **Tailscale** | 見下方 |

**Android 要多做兩件事，不然切到背景就會斷線：**
1. 系統 **設定 → 網路 → VPN → Tailscale 旁的齒輪 → 開啟「永久連線 VPN」（Always-on VPN）**。
2. 系統 **設定 → 應用程式 → Tailscale → 電池 → 不受限制**。

> Android 同一時間只能開一個 VPN。開著 Tailscale 時，就不能再用其他 VPN app。

## 測試連線

把手機的 Wi-Fi 關掉改用行動網路（模擬在外面），然後：

- 瀏覽器開 `http://<Pi 的區網 IP>:5984/`（例如 `http://192.168.1.50:5984/`），應該會跳出登入框或回應 `unauthorized`，這代表連得到。
- 電腦上跑：
  ```bash
  ./scripts/check-couchdb.sh http://192.168.1.50:5984 obsidian
  ```
  全部 `[OK]` 就可以進行下一步。

> **為什麼用區網 IP？** 在家時直接走區網，在外面則由 Tailscale 經 Pi 轉送，同一組網址到哪裡都能用，實測比 `*.ts.net` 名稱穩定。
> 唯一的例外：如果你在外面連上的網路剛好也是同一個網段（例如咖啡廳也是 `192.168.1.x`），會連錯地方。遇到這種情況，請看 [疑難排解](04-troubleshooting.md#連不上伺服器)。

連不上的話請看 [疑難排解](04-troubleshooting.md#連不上伺服器)。

下一步：[3. 設定 Obsidian LiveSync](03-clients.md)
