# 首次登录 Obedur-OS 的交互式设置
setup:
    #!/usr/bin/bash
    if [ "$(id -u)" = "0" ]; then
        echo "请不要以 root 运行。请用普通用户执行：blujust setup"
        exit 1
    fi

    SRC="/usr/share/obedur-dotfiles"

    confirm() {
        local prompt="$1"
        read -p "$prompt " -r answer
        [ "${answer,,}" = "y" ] || [ "${answer,,}" = "yes" ]
    }

    copy_file() {
        local src="$1" dst="$2"
        if [ -f "$dst" ]; then
            if ! confirm "  $dst 已存在，覆盖？[y/N]"; then
                echo "  跳过：$dst"
                return
            fi
        fi
        mkdir -p "$(dirname "$dst")"
        cp "$src" "$dst"
        echo "  ✓ $src → $dst"
    }

    echo "Obedur-OS 设置"
    echo "================"
    echo ""

    # --- Shell ---
    current_shell="$(getent passwd "$USER" | cut -d: -f7)"
    echo "当前登录 Shell：$current_shell"
    if confirm "切换登录 Shell 为 fish？（自动补全、语法高亮、模糊历史搜索）[y/N]"; then
        chsh -s /usr/bin/fish
        echo "  ✓ Shell 已切换为 fish（下次登录生效）"
    else
        echo "  跳过"
    fi
    echo ""

    # --- fish 配置 ---
    echo "fish 配置：starship 提示符 + fzf 按键绑定 + fastfetch 问候语"
    if confirm "复制 fish 配置到 ~/.config/fish/？[y/N]"; then
        copy_file "$SRC/fish/config.fish" "$HOME/.config/fish/config.fish"
        copy_file "$SRC/fish/functions/fish_greeting.fish" "$HOME/.config/fish/functions/fish_greeting.fish"
    else
        echo "  跳过"
    fi
    echo ""

    # --- starship ---
    echo "starship 提示符：彩色分段显示 目录/git/语言版本/时间"
    if confirm "复制 starship.toml 到 ~/.config/？[y/N]"; then
        copy_file "$SRC/starship.toml" "$HOME/.config/starship.toml"
    else
        echo "  跳过"
    fi
    echo ""

    # --- ghostty ---
    echo "ghostty 终端：MapleMono NF CN 字体 + noctalia 暗紫色主题"
    if confirm "复制 ghostty 配置到 ~/.config/ghostty/？[y/N]"; then
        copy_file "$SRC/ghostty/config" "$HOME/.config/ghostty/config"
        copy_file "$SRC/ghostty/themes/noctalia" "$HOME/.config/ghostty/themes/noctalia"
    else
        echo "  跳过"
    fi
    echo ""

    # --- niri override ---
    echo "niri 覆盖配置模板：fcitx5 输入法环境变量、Lavanda-Sea-Dark GTK 主题、"
    echo "  触摸板/指点杆/轨迹球/触摸屏禁用、双显示器参考布局"
    if confirm "复制 override.kdl.example 到 ~/.config/niri/override.kdl？[y/N]"; then
        copy_file "$SRC/niri/override.kdl.example" "$HOME/.config/niri/override.kdl"
        if [ -f "$HOME/.config/niri/override.kdl" ]; then
            echo "  ⚠ 请编辑 $HOME/.config/niri/override.kdl 以匹配你的显示器和偏好"
        fi
    else
        echo "  跳过"
    fi
    echo ""

    echo "设置完成。部分变更需重新登录后生效。"
