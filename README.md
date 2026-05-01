# Obedur-OS &nbsp; [![bluebuild build badge](https://github.com/sorubedo/obedur-os/actions/workflows/build.yml/badge.svg)](https://github.com/sorubedo/obedur-os/actions/workflows/build.yml)

基于 [BlueBuild](https://blue-build.org/) 构建的 Fedora Atomic 不可变系统镜像。提供开箱即用的 Niri 滚动平铺 Wayland 桌面环境，通过容器原生方式实现原子化系统更新与回滚。

## 特性

- **不可变基础设施**：基于 Fedora Atomic (Ostree Native Container)，系统核心只读，更新原子化，支持一键回滚
- **Niri 滚动平铺桌面**：Wayland 下独特的横向无限平铺 + 纵向工作区模式，配合 [Noctalia Shell](https://docs.noctalia.dev/) 提供精美的桌面 Shell 体验
- **CachyOS 内核**（自用版）：集成 CachyOS LTO 优化内核，兼顾性能与响应速度
- **SecureBoot 支持**：内核模块签名 + MOK 首次启动自动注册，安全启动开箱可用
- **现代系统组件**：greetd + tuigreet 终端风格登录、iwd 无线后端、fcitx5 中文输入法框架
- **容器化工作流**：预装 podman-compose、podlet、distrobox，容器开发即装即用
- **自动构建与签名**：GitHub Actions 每日自动构建，cosign 签名可验证

## 镜像选择

根据显卡硬件选择合适的镜像变体：

| 镜像名称 | 适用硬件 | 基础镜像 |
| :--- | :--- | :--- |
| **`obedur-os`** | Intel / AMD 显卡 | `fedora-base` |
| **`obedur-os-nvidia`** | NVIDIA 闭源专有驱动 | `fedora-base-nvidia` |
| **`obedur-os-nvidia-open`** | NVIDIA 开源内核模块 | `fedora-base-nvidia-open` |
| **`obedur-os-selfuse`** | 自用版（CachyOS LTO + NVIDIA） | `fedora-base` |

> `obedur-os-selfuse` 为作者自用版本，包含 CachyOS LTO 内核、ayugram-desktop、quickemu 及 scx 调度器工具。不建议直接使用。

## 安装

以下命令以 `obedur-os`（标准版）为例。NVIDIA 用户请将镜像名替换为对应的变体名称。

### 方法一：bootc（推荐）

容器原生系统（Bootable Container）的现代管理方式：

```bash
# 1. 变基到未签名镜像，以安装签名密钥和策略
bootc switch ghcr.io/sorubedo/obedur-os:latest

# 2. 重启完成变基
systemctl reboot

# 3. 切换到强制签名验证的镜像
bootc switch --enforce-container-sigpolicy ghcr.io/sorubedo/obedur-os:latest

# 4. 再次重启
systemctl reboot
```

### 方法二：rpm-ostree（传统）

```bash
# 1. 变基到未签名镜像
rpm-ostree rebase ostree-unverified-registry:ghcr.io/sorubedo/obedur-os:latest

# 2. 重启
systemctl reboot

# 3. 变基到已签名镜像
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/sorubedo/obedur-os:latest

# 4. 再次重启
systemctl reboot
```

> `latest` 标签始终指向最新构建，版本号由 recipe 中 `image-version` 固定，不会意外跨主版本更新。

## 桌面操作指南

### 设计概念

Niri 采用"横向无限平铺 + 纵向工作区"的布局模型：

- **列（Column）**：窗口在水平方向上平铺排列，可无限向右延伸
- **工作区（Workspace）**：纵向排列，每个工作区有独立的列布局
- **焦点**：当前操作的窗口/列，通过快捷键在列间、窗口间、工作区间移动

桌面 Shell 基于 [Noctalia Shell](https://docs.noctalia.dev/)，一个基于 quickshell 的精美社区配置，提供启动器、状态栏、壁纸管理、系统监视器等组件。

### 默认按键绑定

> Mod 键默认为 Super（Windows 键）。

#### 焦点移动

| 快捷键 | 功能 |
| :--- | :--- |
| `Mod + H` 或 `Mod + ←` | 焦点移至左侧列 |
| `Mod + L` 或 `Mod + →` | 焦点移至右侧列 |
| `Mod + K` 或 `Mod + ↑` | 焦点移至上方窗口 |
| `Mod + J` 或 `Mod + ↓` | 焦点移至下方窗口 |
| `Mod + Shift + K` 或 `Mod + Shift + ↑` | 切换到上方工作区 |
| `Mod + Shift + J` 或 `Mod + Shift + ↓` | 切换到下方工作区 |
| `Mod + 1` ~ `9` | 直接跳转到指定工作区 |
| `Mod + Page_Up` / `Page_Down` | 切换显示器 |

#### 窗口/列管理

| 快捷键 | 功能 |
| :--- | :--- |
| `Mod + Ctrl + H/←` | 将当前列向左移动 |
| `Mod + Ctrl + L/→` | 将当前列向右移动 |
| `Mod + Ctrl + K/↑` | 将窗口向上移动 |
| `Mod + Ctrl + J/↓` | 将窗口向下移动 |
| `Mod + Ctrl + Shift + K/↑` | 将当前列移至上方工作区（焦点跟随） |
| `Mod + Ctrl + Shift + J/↓` | 将当前列移至下方工作区（焦点跟随） |
| `Mod + Alt + Shift + K/↑` | 将当前列移至上方工作区（焦点不跟随） |
| `Mod + Alt + Shift + J/↓` | 将当前列移至下方工作区（焦点不跟随） |
| `Mod + G` | 将当前窗口吸入下方列 |
| `Mod + Shift + G` | 将窗口从列中移出为独立列 |
| `Mod + Q` | 关闭当前窗口 |
| `Mod + W` | 切换窗口浮动/平铺 |
| `Mod + F` | 最大化当前列宽度 |
| `Mod + Shift + F` | 全屏当前窗口 |
| `Mod + C` | 将当前列居中 |
| `Mod + R` | 循环切换列宽度预设（1/3、1/2、2/3、全宽） |
| `Mod + Shift + R` | 循环切换窗口高度预设（1/2、全高） |

#### 启动器与应用

| 快捷键 | 功能 |
| :--- | :--- |
| `Mod + Space` 或 `Mod + A` | 打开启动器（noctalia-shell launcher） |
| `Mod + T` 或 `Ctrl+Alt+T` | 打开 Ghostty 终端 |
| `Mod + E` | 打开 Nautilus 文件管理器 |
| `Mod + Escape` | 打开 Resources 系统监视器 |

#### 截图

| 快捷键 | 功能 |
| :--- | :--- |
| `Print` | 选择输出，截图后在 Satty 中编辑 |
| `Mod + Shift + S` | 选择区域，截图后在 Satty 中编辑 |

#### 其他

| 快捷键 | 功能 |
| :--- | :--- |
| `Mod + V` | 打开剪贴板历史 |
| `Mod + N` | 打开便签面板（依赖 [notes-scratchpad 插件](https://noctalia.dev/plugins/notes-scratchpad)） |
| `Mod + M` | 切换系统监视器面板 |
| `Mod + P` | 切换壁纸面板 |
| `Mod + Z` 或 `Mod + Shift + B` | 切换状态栏 |
| `Mod + Shift + P` | 关闭所有显示器 |
| `Ctrl+Alt+Delete` | 打开会话菜单（注销/重启/关机） |
| `Mod + 鼠标滚轮` | 横向切换列焦点 |
| `Mod + Ctrl + 鼠标滚轮` | 横向移动列 |
| `Mod + Shift + 鼠标滚轮` | 纵向切换工作区 |

### 自定义配置

在 `~/.config/niri/` 下创建 `override.kdl` 即可覆盖任意默认配置。Noctalia Shell 配色同步：在「配色方案 → 模板」中启用 Niri，Noctalia 会自动生成 `~/.config/niri/noctalia.kdl`。

## ISO 安装

在 Fedora Atomic 系统上可生成离线 ISO，参考 [BlueBuild ISO 指南](https://blue-build.org/learn/universal-blue/#fresh-install-from-an-iso)。ISO 体积较大，无法在 GitHub 免费分发，需使用其他平台托管。

## 验证镜像签名

所有镜像使用 [Sigstore cosign](https://github.com/sigstore/cosign) 签名：

```bash
cosign verify --key cosign.pub ghcr.io/sorubedo/obedur-os
```

## 本地构建

```bash
# 安装 CLI
pip install bluebuild

# 构建
bluebuild build ./recipes/obedur-os.yml

# 使用 zstd 压缩以减小体积
bluebuild build --build-chunked-oci --compression-format zstd ./recipes/obedur-os.yml
```

## 项目结构

```
obedur-os/
├── recipes/                       # 镜像 recipe 定义
│   ├── obedur-os.yml              #   标准版（Intel/AMD）
│   ├── obedur-os-nvidia.yml       #   NVIDIA 闭源驱动
│   ├── obedur-os-nvidia-open.yml  #   NVIDIA 开源驱动
│   ├── obedur-os-selfuse.yml      #   自用版（CachyOS LTO）
│   ├── bootstrap.yml              #   共享：OS 身份、内核参数、字体
│   ├── core.yml                   #   共享：软件包、Flatpak、systemd、脚本
│   └── finalize.yml               #   共享：initramfs、签名
├── files/
│   ├── system/                    # 注入镜像的系统文件（映射到 /）
│   └── scripts/                   # 构建时执行的脚本
├── modules/custom-kernel/         # CachyOS 内核模块
├── cosign.pub                     # cosign 公钥
└── MOK.der                        # SecureBoot MOK 证书
```

## 致谢

- [BlueBuild](https://blue-build.org/) — 不可变镜像构建框架
- [Niri](https://github.com/YaLTeR/niri) — 滚动平铺 Wayland 合成器
- [Noctalia Shell](https://docs.noctalia.dev/) — 基于 quickshell 的桌面 Shell
- [CachyOS](https://cachyos.org/) — 优化内核与系统调度

## 许可证

[MIT License](LICENSE)
