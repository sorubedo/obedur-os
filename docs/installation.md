# 安装指南

## 前置条件

- 一台已安装 Fedora Atomic（如 Fedora Silverblue、Kinoite 等）的机器
- 网络连接
- 了解当前使用的显卡型号

## 镜像选择

根据显卡硬件选择对应的镜像：

| 镜像名称 | 适用硬件 | 基础镜像 |
| :--- | :--- | :--- |
| **`obedur-os`** | Intel / AMD 显卡 | `fedora-base` |
| **`obedur-os-nvidia`** | NVIDIA 闭源专有驱动 | `fedora-base-nvidia` |
| **`obedur-os-nvidia-open`** | NVIDIA 开源内核模块 | `fedora-base-nvidia-open` |

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
