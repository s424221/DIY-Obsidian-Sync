# Changelog

## 1.0.1

- 修正在新版 Supervisor 上 build 失敗：Dockerfile 直接指定 `FROM couchdb:3.4`，不再依賴 `build.yaml` 的 `build_from`
- 安裝 jq 時略過 CouchDB 自己的 apt 套件庫，只用 Debian 官方套件庫

## 1.0.0

- 第一版：CouchDB 3.4，預先套用 Obsidian LiveSync 建議設定
