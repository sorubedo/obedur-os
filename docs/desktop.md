# 桌面操作指南

## 桌面组件

| 组件 | 说明 |
| :--- | :--- |
| **Niri** | Wayland 滚动平铺合成器，横向无限平铺 + 纵向工作区 |
| **Noctalia Shell** | 基于 quickshell 的桌面 Shell，提供启动器、状态栏、壁纸等 |
| **greetd + tuigreet** | 终端风格登录管理器 |
| **Ghostty** | GPU 加速的现代终端模拟器 |
| **fcitx5** | 输入法框架（预装 Rime 引擎，需用户自行配置输入方案） |

## 布局概念

Niri 的布局有两个维度：

- **列（Column）**：窗口在**水平方向**平铺排列。新窗口默认在右侧创建新列，可无限向右延伸
- **工作区（Workspace）**：在**垂直方向**堆叠。每个工作区拥有独立的列布局

```
工作区 1  ──  [窗口A] [窗口B] [窗口C] ──→ 水平无限延伸
工作区 2  ──  [窗口D] [窗口E]
工作区 3  ──  [终端] [浏览器] [编辑器] [音乐]
     ↓
  垂直切换
```

## Noctalia Shell

[Noctalia Shell](https://docs.noctalia.dev/) 是基于 quickshell 的社区桌面 Shell 配置，提供：

- **启动器**：应用搜索与启动
- **状态栏**：工作区指示、系统信息
- **壁纸管理**：桌面壁纸设置与切换
- **系统监视器**：资源使用监控
- **剪贴板历史**：剪贴板内容管理
- **便签面板**：[notes-scratchpad 插件](https://noctalia.dev/plugins/notes-scratchpad)
- **会话菜单**：注销、重启、关机

### 配色同步

在 Noctalia 设置中，进入「配色方案 → 模板」启用 Niri 模板，Noctalia 会根据当前配色自动生成 `~/.config/niri/noctalia.kdl`，无需手动配置即可实现桌面配色与 Niri 窗口装饰的统一。

## 按键绑定

> Mod 键默认为 Super（Windows 键）。

### 焦点移动

| 快捷键 | 功能 |
| :--- | :--- |
| `Mod + H` 或 `Mod + ←` | 焦点移至左侧列 |
| `Mod + L` 或 `Mod + →` | 焦点移至右侧列 |
| `Mod + K` 或 `Mod + ↑` | 焦点移至同列上方窗口 |
| `Mod + J` 或 `Mod + ↓` | 焦点移至同列下方窗口 |
| `Mod + Shift + K` 或 `Mod + Shift + ↑` | 切换到上方工作区 |
| `Mod + Shift + J` 或 `Mod + Shift + ↓` | 切换到下方工作区 |
| `Mod + 1` ~ `9` | 跳转到指定工作区 |
| `Mod + Page_Up` / `Page_Down` | 切换显示器 |

### 窗口与列管理

| 快捷键 | 功能 |
| :--- | :--- |
| `Mod + Ctrl + H/←` | 将当前列向左移动 |
| `Mod + Ctrl + L/→` | 将当前列向右移动 |
| `Mod + Ctrl + K/↑` | 将当前窗口向上移动 |
| `Mod + Ctrl + J/↓` | 将当前窗口向下移动 |
| `Mod + Ctrl + Shift + K/↑` | 将当前列移至上方工作区（焦点跟随） |
| `Mod + Ctrl + Shift + J/↓` | 将当前列移至下方工作区（焦点跟随） |
| `Mod + Alt + Shift + K/↑` | 将列移至上方工作区（焦点不跟随） |
| `Mod + Alt + Shift + J/↓` | 将列移至下方工作区（焦点不跟随） |
| `Mod + G` | 将当前窗口吸入下方列 |
| `Mod + Shift + G` | 将窗口从列中移出为独立列 |
| `Mod + Q` | 关闭当前窗口 |
| `Mod + W` | 切换窗口浮动 / 平铺 |
| `Mod + Shift + W` | 在浮动与平铺窗口间切换焦点 |
| `Mod + F` | 最大化当前列宽度 |
| `Mod + Shift + F` | 全屏当前窗口 |
| `Mod + Ctrl + F` | 切换窗口化全屏 |
| `Mod + C` | 将当前列居中 |
| `Mod + R` | 循环列宽度预设（1/3 → 1/2 → 2/3 → 1） |
| `Mod + Shift + R` | 循环窗口高度预设（1/2 → 1） |

### 应用与面板

| 快捷键 | 功能 |
| :--- | :--- |
| `Mod + Space` 或 `Mod + A` | 打开启动器 |
| `Mod + T` 或 `Ctrl+Alt+T` | 打开 Ghostty 终端 |
| `Mod + E` | 打开 Nautilus 文件管理器 |
| `Mod + Escape` | 打开 Resources 系统监视器 |
| `Mod + V` | 打开剪贴板历史 |
| `Mod + N` | 打开便签面板 |
| `Mod + M` | 切换系统监视器面板 |
| `Mod + P` | 切换壁纸面板 |
| `Mod + Z` 或 `Mod + Shift + B` | 切换状态栏 |
| `Mod + Shift + P` | 关闭所有显示器 |
| `Ctrl+Alt+Delete` | 打开会话菜单（注销/重启/关机） |

### 截图

| 快捷键 | 功能 |
| :--- | :--- |
| `Print` | 选择输出后截图，在 Satty 中编辑 |
| `Mod + Shift + S` | 选择区域后截图，在 Satty 中编辑 |

### 鼠标操作

| 操作 | 功能 |
| :--- | :--- |
| `Mod + 滚轮` | 横向切换列焦点 |
| `Mod + Ctrl + 滚轮` | 横向移动列 |
| `Mod + Shift + 滚轮` | 纵向切换工作区 |
| `Mod + Ctrl + Shift + 滚轮` | 将列移至上方 / 下方工作区 |

## 自定义配置

默认配置位于 `/etc/obedur-dotfiles/niri/`。如需覆盖，在 `~/.config/niri/` 下创建 `override.kdl`：

```kdl
// ~/.config/niri/override.kdl
// 此处内容会覆盖默认配置中的对应项
```

更多参考：[Niri 文档](https://github.com/YaLTeR/niri/wiki)、[Noctalia Shell 文档](https://docs.noctalia.dev/)。
