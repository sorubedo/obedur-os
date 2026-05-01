# 常见问题

??? info "安装后无法提权，没有密码弹窗？"

    需要安装 Noctalia Shell 的 [polkit-agent 插件](https://noctalia.dev/plugins/polkit-agent)，在 Noctalia 设置面板中操作即可。

??? info "系统预装了 sing-box，如何使用？"

    Obedur-OS 预装了最新 beta 版的 [sing-box](https://sing-box.sagernet.org/)，一个通用的网络工具核心。默认 sing-box 不会自动运行，不会对系统网络产生任何影响。

    需用户根据自身需求编写配置文件后通过 systemd 启动。

    ??? note "参考配置（点击展开）"

        ```json
        {
          "log": {
            "level": "info"
          },
          "dns": {
            "servers": [
              {
                "type": "fakeip",
                "tag": "FakeDns",
                "inet4_range": "198.18.0.0/15",
                "inet6_range": "fc00::/18"
              },
              {
                "type": "https",
                "tag": "Local-DNS",
                "server": "223.5.5.5"
              },
              {
                "type": "https",
                "tag": "Remote-DNS",
                "detour": "🚀 节点选择",
                "server": "8.8.8.8"
              }
            ],
            "rules": [
              {
                "clash_mode": "direct",
                "server": "Local-DNS"
              },
              {
                "clash_mode": "global",
                "server": "FakeDns"
              },
              {
                "type": "logical",
                "mode": "and",
                "rules": [
                  {
                    "domain_suffix": [
                      ".lan",
                      ".localdomain",
                      ".example",
                      ".invalid",
                      ".localhost",
                      ".test",
                      ".local",
                      ".home.arpa",
                      ".msftconnecttest.com",
                      ".msftncsi.com",
                      ".market.xiaomi.com",
                      ".wotgame.cn",
                      ".wggames.cn",
                      ".wowsgame.cn",
                      ".wargaming.net",
                      ".steamcontent.com"
                    ],
                    "invert": true
                  },
                  {
                    "query_type": [
                      "A",
                      "AAAA"
                    ]
                  }
                ],
                "server": "FakeDns"
              },
              {
                "rule_set": "CN-Domain",
                "server": "Local-DNS"
              }
            ],
            "final": "Remote-DNS",
            "strategy": "prefer_ipv4"
          },
          "http_clients": [
            {
              "tag": "direct",
              "engine": "go",
              "version": 2,
              "stream_receive_window": 0,
              "connection_receive_window": 0
            },
            {
              "tag": "proxy",
              "engine": "go",
              "version": 2,
              "detour": "🚀 节点选择",
              "stream_receive_window": 0,
              "connection_receive_window": 0
            }
          ],
          "inbounds": [
            {
              "type": "mixed",
              "tag": "mixed-in",
              "listen": "127.0.0.1",
              "listen_port": 1080,
              "tcp_fast_open": true,
              "udp_fragment": true
            },
            {
              "type": "socks",
              "tag": "bittorrent-in",
              "listen": "127.0.0.1",
              "listen_port": 1081,
              "tcp_fast_open": true,
              "udp_fragment": true
            },
            {
              "type": "tun",
              "tag": "tun-in",
              "interface_name": "SB0",
              "mtu": 9000,
              "address": [
                "172.18.0.1/30",
                "fdfe:dcba:9876::1/126"
              ],
              "auto_route": true,
              "auto_redirect": true,
              "strict_route": true,
              "stack": "mixed"
            }
          ],
          "outbounds": [
            {
              "type": "selector",
              "tag": "🚀 节点选择",
              "outbounds": [
                "jp(vless)"
              ],
              "interrupt_exist_connections": true
            },
            {
              "type": "selector",
              "tag": "🐼 中国大陆",
              "outbounds": [
                "直连",
                "🚀 节点选择"
              ],
              "interrupt_exist_connections": true
            },
            {
              "type": "selector",
              "tag": "🧲 Bittorrent",
              "outbounds": [
                "直连",
                "🚀 节点选择",
                "🐼 中国大陆"
              ],
              "interrupt_exist_connections": true
            },
            {
              "type": "selector",
              "tag": "🐟 漏网之鱼",
              "outbounds": [
                "🚀 节点选择",
                "🐼 中国大陆",
                "直连"
              ],
              "interrupt_exist_connections": true
            },
            {
              "type": "selector",
              "tag": "📺 Bilibili",
              "outbounds": [
                "🐼 中国大陆",
                "🚀 节点选择",
                "直连"
              ],
              "interrupt_exist_connections": true
            },
            {
              "type": "selector",
              "tag": "🛰 Telegram",
              "outbounds": [
                "🚀 节点选择",
                "🐼 中国大陆",
                "直连"
              ],
              "interrupt_exist_connections": true
            },
            {
              "type": "selector",
              "tag": "💻 Github",
              "outbounds": [
                "🚀 节点选择",
                "🐼 中国大陆",
                "直连"
              ],
              "interrupt_exist_connections": true
            },
            {
              "type": "selector",
              "tag": "🪟 Microsoft",
              "outbounds": [
                "🐼 中国大陆",
                "🚀 节点选择",
                "直连"
              ],
              "interrupt_exist_connections": true
            },
            {
              "type": "selector",
              "tag": "🎥 Youtube",
              "outbounds": [
                "🚀 节点选择",
                "🐼 中国大陆",
                "直连"
              ],
              "interrupt_exist_connections": true
            },
            {
              "type": "selector",
              "tag": "🌈 Google",
              "outbounds": [
                "🚀 节点选择",
                "🐼 中国大陆",
                "直连"
              ],
              "interrupt_exist_connections": true
            },
            {
              "type": "selector",
              "tag": "🍎 Apple",
              "outbounds": [
                "🐼 中国大陆",
                "🚀 节点选择",
                "直连"
              ],
              "interrupt_exist_connections": true
            },
            {
              "type": "selector",
              "tag": "GLOBAL",
              "outbounds": [
                "🚀 节点选择",
                "直连",
                "🐼 中国大陆"
              ],
              "interrupt_exist_connections": true
            },
            {
              "type": "direct",
              "tag": "直连"
            },
            {
              "type": "vless",
              "tag": "jp(vless)",
              "server": "",
              "server_port": 443,
              "uuid": "",
              "flow": "xtls-rprx-vision",
              "tls": {
                "enabled": true,
                "server_name": "www.microsoft.com",
                "utls": {
                  "enabled": true,
                  "fingerprint": "chrome"
                },
                "reality": {
                  "enabled": true,
                  "public_key": "",
                  "short_id": ""
                }
              }
            }
          ],
          "route": {
            "rules": [
              {
                "action": "sniff"
              },
              {
                "protocol": "dns",
                "action": "hijack-dns"
              },
              {
                "ip_is_private": true,
                "outbound": "直连"
              },
              {
                "clash_mode": "direct",
                "outbound": "直连"
              },
              {
                "clash_mode": "global",
                "outbound": "GLOBAL"
              },
              {
                "type": "logical",
                "mode": "or",
                "rules": [
                  {
                    "protocol": "bittorrent"
                  },
                  {
                    "inbound": "bittorrent-in"
                  }
                ],
                "outbound": "🧲 Bittorrent"
              },
              {
                "rule_set": "Bilibili-Domain",
                "outbound": "📺 Bilibili"
              },
              {
                "rule_set": "Telegram-Domain",
                "outbound": "🛰 Telegram"
              },
              {
                "rule_set": "Github-Domain",
                "outbound": "💻 Github"
              },
              {
                "rule_set": "Microsoft-Domain",
                "outbound": "🪟 Microsoft"
              },
              {
                "rule_set": "Youtube-Domain",
                "outbound": "🎥 Youtube"
              },
              {
                "rule_set": "Google-Domain",
                "outbound": "🌈 Google"
              },
              {
                "rule_set": "Apple-Domain",
                "outbound": "🍎 Apple"
              },
              {
                "rule_set": "CN-Domain",
                "outbound": "🐼 中国大陆"
              },
              {
                "rule_set": "!CN-Location-Domain",
                "outbound": "🚀 节点选择"
              },
              {
                "action": "resolve"
              },
              {
                "rule_set": "Bilibili-IP",
                "outbound": "📺 Bilibili"
              },
              {
                "rule_set": "Telegram-IP",
                "outbound": "🛰 Telegram"
              },
              {
                "rule_set": "Google-IP",
                "outbound": "🌈 Google"
              },
              {
                "rule_set": "Apple-IP",
                "outbound": "🍎 Apple"
              },
              {
                "rule_set": "CN-IP",
                "outbound": "🐼 中国大陆"
              }
            ],
            "rule_set": [
              {
                "type": "remote",
                "tag": "Github-Domain",
                "url": "https://ghfast.top/https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geosite/github.srs",
                "update_interval": "2h0m0s"
              },
              {
                "type": "remote",
                "tag": "Microsoft-Domain",
                "url": "https://ghfast.top/https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geosite/microsoft.srs",
                "update_interval": "2h0m0s"
              },
              {
                "type": "remote",
                "tag": "Youtube-Domain",
                "url": "https://ghfast.top/https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geosite/youtube.srs",
                "update_interval": "2h0m0s"
              },
              {
                "type": "remote",
                "tag": "Google-Domain",
                "url": "https://ghfast.top/https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geosite/google.srs",
                "update_interval": "2h0m0s"
              },
              {
                "type": "remote",
                "tag": "Google-IP",
                "url": "https://ghfast.top/https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geoip/google.srs",
                "update_interval": "2h0m0s"
              },
              {
                "type": "remote",
                "tag": "Bilibili-Domain",
                "url": "https://ghfast.top/https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geosite/bilibili.srs",
                "update_interval": "2h0m0s"
              },
              {
                "type": "remote",
                "tag": "Bilibili-IP",
                "url": "https://ghfast.top/https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo-lite/geoip/bilibili.srs",
                "update_interval": "2h0m0s"
              },
              {
                "type": "remote",
                "tag": "Telegram-Domain",
                "url": "https://ghfast.top/https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geosite/telegram.srs",
                "update_interval": "2h0m0s"
              },
              {
                "type": "remote",
                "tag": "Telegram-IP",
                "url": "https://ghfast.top/https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geoip/telegram.srs",
                "update_interval": "2h0m0s"
              },
              {
                "type": "remote",
                "tag": "CN-Domain",
                "url": "https://ghfast.top/https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geosite/cn.srs",
                "update_interval": "2h0m0s"
              },
              {
                "type": "remote",
                "tag": "CN-IP",
                "url": "https://ghfast.top/https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geoip/cn.srs",
                "update_interval": "2h0m0s"
              },
              {
                "type": "remote",
                "tag": "!CN-Location-Domain",
                "url": "https://ghfast.top/https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geosite/geolocation-!cn.srs",
                "update_interval": "2h0m0s"
              },
              {
                "type": "remote",
                "tag": "Apple-Domain",
                "url": "https://ghfast.top/https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geosite/apple.srs",
                "update_interval": "2h0m0s"
              },
              {
                "type": "remote",
                "tag": "Apple-IP",
                "url": "https://ghfast.top/https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo-lite/geoip/apple.srs",
                "update_interval": "2h0m0s"
              }
            ],
            "final": "🐟 漏网之鱼",
            "find_process": true,
            "auto_detect_interface": true,
            "default_domain_resolver": {
              "server": "Local-DNS",
              "strategy": "prefer_ipv4"
            },
            "default_http_client": "direct"
          },
          "experimental": {
            "cache_file": {
              "enabled": true,
              "path": "cache.db",
              "store_fakeip": true,
              "rdrc_timeout": "168h0m0s",
              "store_dns": true
            },
            "clash_api": {
              "external_controller": "127.0.0.1:23333",
              "external_ui": "./ui",
              "external_ui_download_url": "https://ghfast.top/https://github.com/Zephyruso/zashboard/releases/latest/download/dist.zip",
              "secret": "obedur",
              "default_mode": "rule",
              "access_control_allow_origin": "*"
            }
          }
        }
        ```

        将配置保存为 `/etc/sing-box/config.json`，然后：

        ```bash
        sudo systemctl enable --now sing-box
        ```

        Clash Dashboard 可通过 `http://127.0.0.1:23333` 访问，密钥为 `obedur`。

        更多配置选项请参考 [sing-box 官方文档](https://sing-box.sagernet.org/configuration/)。

??? info "预装的 Flatpak 应用在哪里？"

    Obedur-OS 通过 BlueBuild 的 `default-flatpaks` 模块配置 Flatpak，但 Flatpak **并不打包在 OCI 镜像内部**。镜像中只包含仓库配置和 systemd 服务，实际安装在**每次启动时**自动执行。首次启动后可能需稍等片刻或重启一次才能看到。

    **网络问题**：Flathub 在中国大陆访问可能不稳定，导致自动安装失败。如需改善网络环境，可参考上方 sing-box 配置。

    **查看配置了哪些 Flatpak：**

    ```bash
    bluebuild-flatpak-manager show
    ```

    **手动触发安装：**

    ```bash
    bluebuild-flatpak-manager apply all       # 同时安装 user 和 system 范围
    bluebuild-flatpak-manager apply user      # 仅安装 user 范围
    bluebuild-flatpak-manager apply system    # 仅安装 system 范围
    ```

    **禁用/启用自动安装：**

    ```bash
    bluebuild-flatpak-manager disable all     # 禁用（不再每次启动自动安装）
    bluebuild-flatpak-manager enable all      # 重新启用
    ```

    `disable`/`enable` 同样支持 `all`、`user`、`system` 三个子命令。