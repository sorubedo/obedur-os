# 自定义内核模块 (Custom Kernel Module)

本模块用于在基于 Fedora ostree 的系统镜像中安装 CachyOS 内核，并自动处理 NVIDIA 驱动、v4l2loopback 模块的编译，以及 SecureBoot 的签名。

> **鸣谢与版权声明 / Acknowledgments**
> 本模块的核心安装与编译脚本 直接复制 自 **[Origami Linux](https://gitlab.com/origami-linux/images)**。
> 特此声明，并对 Origami Linux 社区的优秀开源工作表示最诚挚的感谢与尊重！
> 此文档由GEMINI撰写,用于备忘

## 使用方法
### 1. 配置 GitHub Actions 工作流

在你的 `.github/workflows/build.yml` 文件中，必须在调用 `blue-build/github-action` 的步骤下加入 `env` 变量，将 GitHub Secret 映射到构建环境。
```yaml
    steps:
      - name: Build Custom Image
        uses: blue-build/github-action@v1.11
        with:
          recipe: ${{ matrix.recipe }}
          cosign_private_key: ${{ secrets.SIGNING_SECRET }}
          registry_token: ${{ github.token }}
          pr_event_number: ${{ github.event.number }}
          maximize_build_space: true
        # 必须在这里注入 MOK_PRIVATE_KEY 环境变量，供配方中的 secrets 读取
        env:
          MOK_PRIVATE_KEY: ${{ secrets.MOK_PRIVATE_KEY }}
```

### 2. 配置 Recipe (配方文件)

在你的配方文件（例如 `obedur-os-selfuse.yml`）的 `modules` 列表中，按照以下格式引入模块。配置将读取上面的环境变量，并挂载为容器内的临时文件供签名使用。

```yaml
  - type: custom-kernel
    source: local
    kernel: cachyos-lto
    nvidia: true
    secrets:
      - type: env
        name: MOK_PRIVATE_KEY
        mount:
          type: file
          destination: /tmp/certs/MOK.priv
    sign:
      key: /tmp/certs/MOK.priv
      cert: /usr/share/cert/MOK.pem
      mok-password: obedur
```
*注：公钥 `/usr/share/cert/MOK.pem` 需提前放置在对应的目录中。*

## 配置参数速查表

| 参数名 | 类型 | 默认值 | 个人常用说明 |
| :--- | :--- | :--- | :--- |
| `kernel` | String | `cachyos-lto` | 支持 `cachyos`, `cachyos-lts`, `cachyos-rt`, `cachyos-lto`, `cachyos-lts-lto` |
| `nvidia` | Boolean | `false` | 设为 `true` 以编译 Nvidia 驱动 |
| `initramfs`| Boolean | `false` | 设为 `true` 以生成 dracut initramfs |
| `sign` | Object | 空 | 包含 `key`, `cert`, `mok-password`。省略此块则不进行签名 |
