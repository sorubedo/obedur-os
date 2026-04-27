# obedur-os &nbsp; [![bluebuild build badge](https://github.com/sorubedo/obedur-os/actions/workflows/build.yml/badge.svg)](https://github.com/sorubedo/obedur-os/actions/workflows/build.yml)

## 镜像选择

在进行系统变基或安装之前，请根据您的显卡硬件配置选择合适的镜像：

| 镜像名称 | 适用说明 |
| :--- | :--- |
| **`obedur-os`** | 标准版。适用于 Intel 或 AMD 显卡。 |
| **`obedur-os-nvidia`** | 包含传统的 NVIDIA 闭源专有驱动。 |
| **`obedur-os-nvidia-open`** | 包含 NVIDIA 官方的开源内核模块驱动 (Open Kernel Modules)。 |

---

## 安装

> [!WARNING]
> [这是一项实验性功能](https://www.fedoraproject.org/wiki/Changes/OstreeNativeContainerStable)，请自行评估风险并尝试。

要将现有的 Fedora Atomic 系统变基 (rebase) 到最新构建，您可以选择以下两种方式之一。**强烈推荐使用 `bootc` 方法**，因为它提供了更现代的容器原生系统管理体验。

*(注：以下命令中的 `obedur-os` 为标准镜像示例。如果您使用的是 NVIDIA 显卡，请务必将其替换为表中对应的镜像名称)*

### 方法一：使用 bootc (推荐)

这是管理容器原生系统（Bootable Container）的首选方法。

1. **变基到未签名的镜像**，以安装正确的签名密钥和策略：
   ```bash
   bootc switch ghcr.io/sorubedo/obedur-os:latest
   ```
2. **重启**以完成变基：
   ```bash
   systemctl reboot
   ```
3. **切换到强制签名验证**的镜像，确保安全性：
   ```bash
   bootc switch --enforce-container-sigpolicy ghcr.io/sorubedo/obedur-os:latest
   ```
4. **再次重启**以完成安装：
   ```bash
   systemctl reboot
   ```

---

### 方法二：使用 rpm-ostree (传统)

如果您习惯传统的原子更新命令，可以使用以下步骤：

1. **变基到未签名的镜像**，以安装正确的签名密钥和策略：
  ```bash
  rpm-ostree rebase ostree-unverified-registry:ghcr.io/sorubedo/obedur-os:latest
  ```
2. **重启**以完成变基：
  ```bash
  systemctl reboot
  ```
3. **然后变基到已签名的镜像**，如下所示：
  ```bash
  rpm-ostree rebase ostree-image-signed:docker://ghcr.io/sorubedo/obedur-os:latest
  ```
4. **再次重启**以完成安装：
  ```bash
  systemctl reboot
  ```

> [!NOTE]
> `latest` 标签会自动指向最新的构建。该构建将始终使用 `recipe.yml` 中指定的 Fedora 版本，因此您不会意外更新到下一个主要版本。

## ISO 镜像

如果在 Fedora Atomic 上构建，您可以按照[此处](https://blue-build.org/learn/universal-blue/#fresh-install-from-an-iso)提供的说明生成离线 ISO。遗憾的是，由于文件体积较大，这些 ISO 无法在 GitHub 上免费分发，因此对于公开项目，必须使用其他平台进行托管。

## 验证

这些镜像使用 [Sigstore](https://www.sigstore.dev/) 的 [cosign](https://github.com/sigstore/cosign) 进行了签名。您可以通过从本仓库下载 `cosign.pub` 文件并运行以下命令来验证签名：

```bash
cosign verify --key cosign.pub ghcr.io/sorubedo/obedur-os
```
