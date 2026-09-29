# DIY Obsidian Sync

用 **Self-hosted LiveSync + CouchDB + Tailscale**，自己架設 Obsidian 多裝置即時同步（Windows / Mac / Android），伺服器跑在 **Home Assistant OS 的樹莓派**上。

- ⚡ 幾秒內同步，離線編輯的內容回到線上後會自動合併
- 🔒 不用開任何 port：外部連線走 Tailscale 私人網路，筆記用端對端加密
- 🏠 CouchDB 以 HA add-on 的形式執行，會跟著 HA 一起備份

## 架構

```
Windows ─┐
Mac ─────┼── Tailscale（WireGuard 加密）──►  Raspberry Pi 5（HA OS）
Android ─┘   Obsidian + LiveSync 外掛              ├─ Tailscale add-on
                                                    └─ Obsidian LiveSync CouchDB add-on（:5984）
```

所有裝置都用 **Pi 的區網 IP**（例如 `http://192.168.2.100:5984`）連線：在家直接走區網，在外面由 Tailscale 的 subnet route 轉送。

## 快速開始

1. [在 HA 安裝 CouchDB add-on](docs/01-ha-addon.md)
2. [設定 Tailscale](docs/02-tailscale.md)
3. [在各裝置設定 Obsidian LiveSync](docs/03-clients.md)
4. 遇到問題：[疑難排解](docs/04-troubleshooting.md)

## 內容

| 路徑 | 說明 |
|---|---|
| `repository.yaml` | 讓這個 repo 可以直接加進 HA 的 add-on 商店 |
| `obsidian-livesync/` | HA add-on：CouchDB 3.4，已套用 LiveSync 建議的設定 |
| `scripts/check-couchdb.sh` | 從任一台電腦檢查伺服器設定是否符合 LiveSync 的需求 |
| `docs/` | 繁體中文安裝教學 |

## 資源用量（估計）

CouchDB 閒置時約佔 100–200 MB 記憶體，CPU 幾乎為 0，對 HA 本身沒有明顯影響。
