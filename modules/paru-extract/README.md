# paru-extract

从已安装的 pacman/AUR 包中提取所有文件到指定目录，配合 `copy` 模块将文件从 stage 转移到主镜像。

**必须配合 `paru` 模块使用**：先 `paru` 装包，再 `paru-extract` 提取。

## 配置项

| 参数 | 类型 | 说明 |
|------|------|------|
| `packages` | array | 要提取的包名（必须已通过 pacman/paru 安装） |
| `output` | string | 提取目标目录（**必填**） |

## 用法示例

```yaml
stages:
  - name: arch
    from: ghcr.io/ublue-os/arch-toolbox:latest
    modules:
      - type: paru
        source: local
        packages:
          - lavanda-gtk-theme-git
      - type: paru-extract
        source: local
        packages:
          - lavanda-gtk-theme-git
        output: /out

modules:
  - type: copy
    from: arch
    src: /out/
    dest: /
```

## 工作原理

1. 遍历 `packages` 列表中的每个包名
2. `pacman -Ql <pkg>` 查询该包拥有的所有文件（只属于此包，不含依赖）
3. 保持目录结构复制到 `output` 目录
4. 主镜像通过 `copy` 模块将 `/out/` 整体转移到 `/`

## 与 paru 模块的关系

| | paru | paru-extract |
|---|---|---|
| 职责 | 安装 AUR 包 | 提取已安装包的文件 |
| 需要用户 | 是（paru 禁止 root） | 否（纯读 + cp） |
| 输出 | 包安装到系统 | 文件复制到指定目录 |
