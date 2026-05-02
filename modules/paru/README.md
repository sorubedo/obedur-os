# paru

> 纯图一乐，跟项目无关。

通过 [paru](https://github.com/Morganamilo/paru) 在基于 Arch Linux 的镜像中安装 AUR 软件包。

**适用场景**：子层镜像（sub-layer）或 stage，基础镜像必须基于 Arch Linux 且已预装 `paru`。

## 配置项

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `user` | string | `builder` | 执行 paru 的非 root 用户名，不存在则自动创建 |
| `packages` | array | `[]` | 要安装的 AUR 软件包列表 |
| `sudo` | bool | `true` | 是否为用户配置免密 sudo（paru 需要它来调用 pacman） |

## 用法示例

### 主 recipe 中使用

```yaml
modules:
  - type: paru
    user: builder
    packages:
      - paru-bin
      - some-aur-package
```

### Stage 中使用

```yaml
stages:
  - name: arch
    from: ghcr.io/ublue-os/arch-toolbox:latest
    modules:
      - type: paru
        packages:
          - lavanda-gtk-theme-git

modules:
  - type: copy
    from: arch
    src: /usr/share/themes/Lavanda
    dest: /usr/share/themes/
```

## 工作原理

1. 创建非 root 用户（如不存在），因为 **paru 禁止以 root 运行**
2. 配置免密 sudo，使 paru 能调用 `pacman` 安装 repo 依赖
3. 写入默认 `paru.conf`
4. 以目标用户身份执行 `paru -S --noconfirm --needed`
5. 清理 paru 缓存

## 注意事项

- 基础镜像**必须已预装 paru**，本模块不会安装它
- 仅在 Arch Linux 或其衍生发行版上可用
- Stage 中使用时，目标文件通常还需要 `copy` 模块转移到主镜像
