# obedur-os &nbsp; [![bluebuild build badge](https://github.com/sorubedo/obedur-os/actions/workflows/build.yml/badge.svg)](https://github.com/sorubedo/obedur-os/actions/workflows/build.yml)

## 安装

> [!WARNING]
> [这是一项实验性功能](https://www.fedoraproject.org/wiki/Changes/OstreeNativeContainerStable)，请自行评估风险并尝试。

要将现有的 Fedora Atomic 系统变基 (rebase) 到最新构建：

- 首先变基到未签名的镜像，以安装正确的签名密钥和策略：
  ```
  rpm-ostree rebase ostree-unverified-registry:ghcr.io/sorubedo/obedur-os:latest
  ```
- 重启以完成变基：
  ```
  systemctl reboot
  ```
- 然后变基到已签名的镜像，如下所示：
  ```
  rpm-ostree rebase ostree-image-signed:docker://ghcr.io/sorubedo/obedur-os:latest
  ```
- 再次重启以完成安装：
  ```
  systemctl reboot
  ```

`latest` 标签会自动指向最新的构建。该构建将始终使用 `recipe.yml` 中指定的 Fedora 版本，因此您不会意外更新到下一个主要版本。

## ISO 镜像

如果在 Fedora Atomic 上构建，您可以按照[此处](https://blue-build.org/learn/universal-blue/#fresh-install-from-an-iso)提供的说明生成离线 ISO。遗憾的是，由于文件体积较大，这些 ISO 无法在 GitHub 上免费分发，因此对于公开项目，必须使用其他平台进行托管。

## 验证

这些镜像使用 [Sigstore](https://www.sigstore.dev/) 的 [cosign](https://github.com/sigstore/cosign) 进行了签名。您可以通过从本仓库下载 `cosign.pub` 文件并运行以下命令来验证签名：

```bash
cosign verify --key cosign.pub ghcr.io/sorubedo/obedur-os
```

---

## 模块说明与致谢

本镜像中内置的 **dracut-numlock** 模块（用于在启动时自动开启小键盘数字锁）直接提取自开源仓库：[ChrTall/dracut-numlock](https://github.com/ChrTall/dracut-numlock)。感谢原作者的开源贡献！
