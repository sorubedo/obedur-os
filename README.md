# Obedur-OS &nbsp; [![bluebuild build badge](https://github.com/sorubedo/obedur-os/actions/workflows/build.yml/badge.svg)](https://github.com/sorubedo/obedur-os/actions/workflows/build.yml)

基于 [BlueBuild](https://blue-build.org/) 构建的 Fedora Atomic 不可变系统镜像。提供开箱即用的 Niri 滚动平铺 Wayland 桌面环境，集成 CachyOS LTO 优化内核。

> 完整文档请访问 **[sorubedo.github.io/obedur-os](https://sorubedo.github.io/obedur-os/)**。

## 特性

- **不可变基础设施**：Fedora Atomic (Ostree Native Container)，系统核心只读，更新原子化，一键回滚
- **CachyOS LTO 内核**：全版本集成 CachyOS 优化内核，兼顾性能与响应速度
- **Niri 滚动平铺桌面**：Wayland 下独特的横向无限平铺 + 纵向工作区，配合 [Noctalia Shell](https://docs.noctalia.dev/) 提供精美桌面 Shell
- **SecureBoot 支持**：内核模块自动签名 + MOK 一键注册，安全启动开箱可用
- **现代系统组件**：greetd + tuigreet 登录、iwd 无线后端、fcitx5 中文输入法、Ghostty 终端
- **容器化工作流**：预装 podman-compose、podlet、distrobox
- **自动构建与签名**：GitHub Actions 每日构建，cosign 签名可验证

## 镜像选择

| 镜像名称 | 适用硬件 |
| :--- | :--- |
| **`obedur-os`** | Intel / AMD 显卡 |
| **`obedur-os-nvidia`** | NVIDIA 显卡 |
| **`obedur-os-selfuse`** | 自用版（额外软件包） |

> 全部基于 `fedora-base`。NVIDIA 驱动由 CachyOS 内核模块提供，无需区分闭源/开源版本。

## 快速安装

以下以标准版为例，NVIDIA 用户替换镜像名即可。详细步骤请参阅 [安装指南](https://sorubedo.github.io/obedur-os/installation/)。

### 1. 变基

```bash
# bootc（推荐）
bootc switch ghcr.io/sorubedo/obedur-os:latest
```

```bash
# 或 rpm-ostree
rpm-ostree rebase ostree-unverified-registry:ghcr.io/sorubedo/obedur-os:latest
```

### 2. 注册 SecureBoot MOK 证书

变基后、**重启前**执行，避免 SecureBoot 阻止首次启动：

```bash
curl -fsSL https://raw.githubusercontent.com/sorubedo/obedur-os/main/scripts/enroll-mok.sh | sudo bash
```

重启后在蓝色 MOK Manager 界面选择 **Enroll MOK**，输入密码 **`obedur`** 即可。详见 [SecureBoot MOK 注册](https://sorubedo.github.io/obedur-os/installation/#secureboot-mok_1)。

### 3. 切换到签名验证镜像（可选）

```bash
# 首次重启后
bootc switch --enforce-container-sigpolicy ghcr.io/sorubedo/obedur-os:latest
systemctl reboot
```

## 验证镜像签名

```bash
cosign verify --key cosign.pub ghcr.io/sorubedo/obedur-os
```

## 致谢

- [BlueBuild](https://blue-build.org/) — 不可变镜像构建框架
- [Niri](https://github.com/YaLTeR/niri) — 滚动平铺 Wayland 合成器
- [Noctalia Shell](https://docs.noctalia.dev/) — 基于 quickshell 的桌面 Shell
- [CachyOS](https://cachyos.org/) — 优化内核与系统调度

## 许可证

[MIT License](LICENSE)
