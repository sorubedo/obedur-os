# 常见问题

## 安装后无法提权，没有密码弹窗？

需要安装 Noctalia Shell 的 [polkit-agent 插件](https://noctalia.dev/plugins/polkit-agent)，在 Noctalia 设置面板中操作即可。

## 预装的 Flatpak 应用在哪里？

Obedur-OS 通过 BlueBuild 的 `default-flatpaks` 模块配置 Flatpak，但 Flatpak **并不打包在 OCI 镜像内部**。镜像中只包含仓库配置和 systemd 服务，实际安装在**每次启动时**自动执行。首次启动后可能需稍等片刻或重启一次才能看到。

### 查看配置了哪些 Flatpak

```bash
bluebuild-flatpak-manager show
```

### 手动触发安装

```bash
bluebuild-flatpak-manager apply all       # 同时安装 user 和 system 范围的 Flatpak
bluebuild-flatpak-manager apply user      # 仅安装 user 范围
bluebuild-flatpak-manager apply system    # 仅安装 system 范围
```

### 禁用/启用自动安装

```bash
# 禁用（不再每次启动自动安装）
bluebuild-flatpak-manager disable all

# 重新启用
bluebuild-flatpak-manager enable all
```

`disable`/`enable` 同样支持 `all`、`user`、`system` 三个子命令，可按需选择范围。