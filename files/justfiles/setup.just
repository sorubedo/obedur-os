# 首次登录 Obedur-OS 的交互式设置
setup:
    #!/usr/bin/bash
    set -euo pipefail
    if [ "$(id -u)" = "0" ]; then
        echo "请不要以 root 运行。请用普通用户执行：blujust setup"
        exit 1
    fi

    SRC="/usr/share/obedur-dotfiles"

    # --- 颜色 ---
    BLD='\033[1m'
    CYN='\033[36m'
    GRN='\033[32m'
    YLW='\033[33m'
    RST='\033[0m'

    # --- TTY 检测：临时字体 ---
    if [ -z "${DISPLAY-}" ] && [ -z "${WAYLAND_DISPLAY-}" ]; then
        echo ""
        echo "  TTY 控制台已检测到，当前字体在高分辨率下可能偏小。"
        echo "  标准屏幕 / 1080P   |   2K 屏幕   |   4K / 高分屏"
        echo "  ────────────────────┼─────────────┼─────────────────"
        echo "  1) ter-v16n  常规   |  5) ter-v24n |   7) ter-v32n"
        echo "  2) ter-v16b  粗体   |  6) ter-v24b |   8) ter-v32b"
        echo "  3) ter-v20n  常规   |             |"
        echo "  4) ter-v20b  粗体   |             |"
        printf "\n  是否立即用 ${CYN}setfont${RST} 临时放大字体？[y/N] "
        read -r _tmp
        if [ "${_tmp,,}" = "y" ] || [ "${_tmp,,}" = "yes" ]; then
            printf "  请选择字体编号 (1-8，推荐 4K 屏幕选 8)："
            read -r _fc
            case "$_fc" in
                1) _f="ter-v16n" ;;  2) _f="ter-v16b" ;;
                3) _f="ter-v20n" ;;  4) _f="ter-v20b" ;;
                5) _f="ter-v24n" ;;  6) _f="ter-v24b" ;;
                7) _f="ter-v32n" ;;  8) _f="ter-v32b" ;;
                *) _f="" ;;
            esac
            if [ -n "$_f" ]; then
                sudo setfont "$_f" 2>/dev/null || true
                printf "  ${GRN}✓${RST} 已临时应用 ${GRN}%s${RST}\n" "$_f"
            fi
        fi
    fi

    confirm() {
        local prompt="$1"
        printf "${CYN}%s${RST} " "$prompt"
        read -r answer
        [ "${answer,,}" = "y" ] || [ "${answer,,}" = "yes" ]
    }

    copy_file() {
        local src="$1" dst="$2"
        if [ -f "$dst" ]; then
            if ! confirm "  ${dst} 已存在，覆盖？[y/N]"; then
                echo "  跳过：${dst}"
                return
            fi
        fi
        mkdir -p "$(dirname "$dst")"
        cp "$src" "$dst"
        printf "  ${GRN}✓${RST} %s → %s\n" "$src" "$dst"
    }

    echo ""
    printf "${BLD}Obedur-OS 设置${RST}\n"
    printf "${BLD}================${RST}\n"
    echo ""

    # --- Shell ---
    current_shell="$(getent passwd "$USER" | cut -d: -f7)"
    if [ "$current_shell" = "/usr/bin/fish" ]; then
        printf "登录 Shell 已是 ${GRN}fish${RST}\n"
    else
        printf "当前登录 Shell：${YLW}%s${RST}\n" "$current_shell"
        if confirm "切换登录 Shell 为 fish？（自动补全、语法高亮、模糊历史搜索）[y/N]"; then
            chsh -s /usr/bin/fish
            printf "  ${GRN}✓${RST} Shell 已切换为 fish（下次登录生效）\n"
        else
            echo "  跳过"
        fi
    fi
    echo ""

    # --- TTY 字体 ---
    printf "TTY 控制台字体：默认字体在高分辨率屏幕下偏小，tuigreet 登录界面也会很小\n"
    printf "  已安装 ${GRN}terminus-fonts-console${RST}\n"
    echo ""
    echo "  标准屏幕 / 1080P   |   2K 屏幕   |   4K / 高分屏"
    echo "  ────────────────────┼─────────────┼─────────────────"
    echo "  1) ter-v16n  常规   |  5) ter-v24n |   7) ter-v32n"
    echo "  2) ter-v16b  粗体   |  6) ter-v24b |   8) ter-v32b"
    echo "  3) ter-v20n  常规   |             |"
    echo "  4) ter-v20b  粗体   |             |"
    echo ""
    if confirm "是否更换 TTY 字体？[y/N]"; then
        printf "请选择字体编号 (1-8，推荐 4K 屏幕选 8)：${CYN}"
        read -r font_choice
        printf "${RST}"
        case "$font_choice" in
            1) _f="ter-v16n" ;;  2) _f="ter-v16b" ;;
            3) _f="ter-v20n" ;;  4) _f="ter-v20b" ;;
            5) _f="ter-v24n" ;;  6) _f="ter-v24b" ;;
            7) _f="ter-v32n" ;;  8) _f="ter-v32b" ;;
            *) echo "  无效选择，跳过" ;; _f="" ;;
        esac
        if [ -n "$_f" ]; then
            if grep -q '^FONT=' /etc/vconsole.conf 2>/dev/null; then
                sudo sed -i "s/^FONT=.*/FONT=$_f/" /etc/vconsole.conf
            else
                printf 'FONT=%s\n' "$_f" | sudo tee -a /etc/vconsole.conf >/dev/null
            fi
            printf "  ${GRN}✓${RST} TTY 字体已设为 ${GRN}%s${RST}（重启生效）\n" "$_f"
        fi
    else
        echo "  跳过"
    fi
    echo ""

    # --- fish 配置 ---
    printf "fish 配置：starship 提示符 + fzf 按键绑定 + fastfetch 问候语\n"
    if confirm "复制 fish 配置到 ~/.config/fish/？[y/N]"; then
        copy_file "$SRC/fish/config.fish" "$HOME/.config/fish/config.fish"
        copy_file "$SRC/fish/functions/fish_greeting.fish" "$HOME/.config/fish/functions/fish_greeting.fish"
    else
        echo "  跳过"
    fi
    echo ""

    # --- starship ---
    printf "starship 提示符：彩色分段显示 目录/git/语言版本/时间\n"
    if confirm "复制 starship.toml 到 ~/.config/？[y/N]"; then
        copy_file "$SRC/starship.toml" "$HOME/.config/starship.toml"
    else
        echo "  跳过"
    fi
    echo ""

    # --- ghostty ---
    printf "ghostty 终端：MapleMono NF CN 字体 + noctalia 暗紫色主题\n"
    if confirm "复制 ghostty 配置到 ~/.config/ghostty/？[y/N]"; then
        copy_file "$SRC/ghostty/config" "$HOME/.config/ghostty/config"
        copy_file "$SRC/ghostty/themes/noctalia" "$HOME/.config/ghostty/themes/noctalia"
    else
        echo "  跳过"
    fi
    echo ""

    # --- niri override ---
    printf "niri 覆盖配置模板：fcitx5 输入法环境变量、Lavanda-Sea-Dark GTK 主题、\n"
    printf "  触摸板/指点杆/轨迹球/触摸屏禁用、双显示器参考布局\n"
    printf "  显示器输出部分已用 ${YLW}/-${RST} 注释，取消对应行的 ${YLW}/-${RST} 即可启用\n"
    if confirm "复制 override.kdl.example 到 ~/.config/niri/override.kdl？[y/N]"; then
        copy_file "$SRC/niri/override.kdl.example" "$HOME/.config/niri/override.kdl"
        echo ""
        if confirm "是否立即运行 ${YLW}niri msg outputs${RST} 查看显示器信息？[y/N]"; then
            niri msg outputs || true
        fi
        echo ""
        if confirm "是否运行 ${YLW}nano${RST} 编辑覆盖配置？[y/N]"; then
            nano "$HOME/.config/niri/override.kdl"
        fi
    else
        echo "  跳过"
    fi
    echo ""

    # --- 隐藏设置向导 ---
    if confirm "是否在应用菜单中隐藏此设置向导？[y/N]"; then
        mkdir -p "$HOME/.local/share/applications"
        cp /usr/share/applications/obedur-setup.desktop "$HOME/.local/share/applications/"
        echo "Hidden=true" >> "$HOME/.local/share/applications/obedur-setup.desktop"
        printf "  ${GRN}✓${RST} 已隐藏，可通过 ${CYN}blujust setup${RST} 重新运行\n"
    fi
    echo ""

    printf "${GRN}设置完成。${RST}部分变更需重新登录后生效。\n"
