# 安装指南

## 前置条件

- 一台已安装 Fedora Atomic（如 Fedora Silverblue、Kinoite 等）的机器
- **CPU 至少支持 x86_64-v3 指令集**（Intel Haswell / AMD Excavator 及更新架构）
- 网络连接
- 了解当前使用的显卡型号

## 镜像选择

根据显卡硬件选择对应的镜像：

| 镜像名称 | 适用硬件 | 基础镜像 |
| :--- | :--- | :--- |
| **`obedur-os`** | Intel / AMD 显卡 | `fedora-base` |
| **`obedur-os-nvidia`** | NVIDIA 显卡 | `fedora-base` |
| **`obedur-os-selfuse`** | 自用版 | `fedora-base` |

> 所有变体均集成 CachyOS LTO 内核，需要 CPU 支持 **x86_64-v3** 指令集（Intel Haswell / AMD Excavator 及以上）。

以下命令以 `obedur-os` 为例，请根据你的显卡替换为对应镜像名。

## 安装步骤

### 方法一：bootc（推荐）

**第一步：变基到未签名镜像**

首先需要安装签名验证策略，因此先切换到未强制签名的镜像：

```bash
bootc switch ghcr.io/sorubedo/obedur-os:latest
```

**第二步：重启**

```bash
systemctl reboot
```

**第三步：切换到签名验证镜像**

```bash
bootc switch --enforce-container-sigpolicy ghcr.io/sorubedo/obedur-os:latest
```

**第四步：再次重启**

```bash
systemctl reboot
```

重启后进入 greetd 登录界面，安装完成。

### 方法二：rpm-ostree（传统）

**第一步：变基到未签名镜像**

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/sorubedo/obedur-os:latest
```

**第二步：重启**

```bash
systemctl reboot
```

**第三步：变基到已签名镜像**

```bash
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/sorubedo/obedur-os:latest
```

**第四步：再次重启**

```bash
systemctl reboot
```

## SecureBoot MOK 注册

Obedur-OS 使用 CachyOS 内核，所有内核模块（v4l2loopback、NVIDIA 等）均使用 MOK 密钥签名。在变基到 Obedur-OS 之后、**重启之前**，执行以下一行命令注册 MOK 证书：

```bash
curl -fsSL https://raw.githubusercontent.com/sorubedo/obedur-os/main/scripts/enroll-mok.sh | sudo bash
```

> 如果 SecureBoot 处于关闭状态，脚本会自动跳过导入，仅创建标记文件防止内置服务重复运行。

执行后正常重启，重启时会进入蓝色背景的 **MOK Manager** 界面：

| 步骤 | 操作 |
| :--- | :--- |
| 1 | 选择 **Enroll MOK** |
| 2 | 选择 **Continue** |
| 3 | 选择 **Yes** 确认注册 |
| 4 | 输入密码：**`obedur`** |
| 5 | 选择 **Reboot** 重新启动 |

重启后 MOK 证书已写入主板，后续内核更新无需再次操作。

> 如果跳过此步骤，系统内置的 `mok-enroll.service` 也会在首次启动时自动导入 MOK 证书（密码同上），但需要**额外多重启一次**才能完成注册流程。

## 更新与维护

推荐使用内置的 `blujust` 脚本进行日常维护。

### 更新系统

```bash
blujust update
```

这会通过 `pkexec` 提权执行 `bootc upgrade`，同时一并更新 Flatpak 应用。

### 系统清理

```bash
blujust clean-system
```

清理范围包括 rpm-ostree 冗余部署、未使用的 Flatpak、Podman 无用的 volume 和 image。

### 回滚

```bash
# bootc
bootc rollback

# rpm-ostree
rpm-ostree rollback

systemctl reboot
```

## 验证签名

镜像使用 [Sigstore cosign](https://github.com/sigstore/cosign) 签名：

```bash
cosign verify --key cosign.pub ghcr.io/sorubedo/obedur-os
```

## ISO 安装

在已有的 Fedora Atomic 系统上可生成离线 ISO 用于全新安装。详见 [BlueBuild ISO 指南](https://blue-build.org/how-to/generate-iso/)。ISO 体积较大，需使用其他平台托管分发。
