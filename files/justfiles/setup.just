SRC := "/usr/share/obedur-dotfiles"

_confirm default="no" prompt:
    #!/usr/bin/bash
    default="{{ default }}"
    read -p "{{ prompt }} " -r answer
    if [ -z "$answer" ]; then
        answer="$default"
    fi
    case "$answer" in
        [Yy]*) exit 0 ;;
        *) exit 1 ;;
    esac

@_copy_file src dest:
    #!/usr/bin/bash
    if [ -f "{{ dest }}" ]; then
        if ! {{ just_executable }} --quiet _confirm default="no" prompt="  {{ dest }} already exists. Overwrite? [y/N] "; then
            echo "  Skipped: {{ dest }}"
            exit 0
        fi
    fi
    mkdir -p "$(dirname "{{ dest }}")"
    cp "{{ src }}" "{{ dest }}"
    echo "  ✓ {{ src }} → {{ dest }}"

# Run first-time desktop setup for Obedur-OS
@setup:
    #!/usr/bin/bash
    set -euo pipefail

    if [ "$(id -u)" = "0" ]; then
        echo "Do not run as root. Run as your normal user: blujust setup"
        exit 1
    fi

    echo "Obedur-OS Setup"
    echo "================"
    echo ""

    # --- Shell ---
    current_shell="$(getent passwd "$USER" | cut -d: -f7)"
    echo "Current login shell: $current_shell"
    if {{ just_executable }} --quiet _confirm default="no" prompt="Switch login shell to /usr/bin/fish? (auto-suggestions, syntax highlighting, fuzzy history) [y/N] "; then
        chsh -s /usr/bin/fish
        echo "  ✓ Shell changed to fish (effective on next login)"
    else
        echo "  Skipped"
    fi
    echo ""

    # --- fish config ---
    echo "Fish config: starship prompt + fzf keybindings + fastfetch greeting"
    if {{ just_executable }} --quiet _confirm default="no" prompt="Copy fish config to ~/.config/fish/? [y/N] "; then
        {{ just_executable }} _copy_file "{{ SRC }}/fish/config.fish" "$HOME/.config/fish/config.fish"
        {{ just_executable }} _copy_file "{{ SRC }}/fish/functions/fish_greeting.fish" "$HOME/.config/fish/functions/fish_greeting.fish"
    else
        echo "  Skipped"
    fi
    echo ""

    # --- starship ---
    echo "Starship prompt: colored segments (dir, git, nodejs/rust/go/php, time)"
    if {{ just_executable }} --quiet _confirm default="no" prompt="Copy starship.toml to ~/.config/? [y/N] "; then
        {{ just_executable }} _copy_file "{{ SRC }}/starship.toml" "$HOME/.config/starship.toml"
    else
        echo "  Skipped"
    fi
    echo ""

    # --- ghostty ---
    echo "Ghostty terminal: MapleMono NF CN font, noctalia dark-purple theme"
    if {{ just_executable }} --quiet _confirm default="no" prompt="Copy ghostty config to ~/.config/ghostty/? [y/N] "; then
        {{ just_executable }} _copy_file "{{ SRC }}/ghostty/config" "$HOME/.config/ghostty/config"
        {{ just_executable }} _copy_file "{{ SRC }}/ghostty/themes/noctalia" "$HOME/.config/ghostty/themes/noctalia"
    else
        echo "  Skipped"
    fi
    echo ""

    # --- niri override ---
    echo "Niri override template: fcitx5 IME env, Lavanda-Sea-Dark GTK theme,"
    echo "  touch/trackpoint/ball/tablet disabled, dual-monitor reference layout"
    if {{ just_executable }} --quiet _confirm default="no" prompt="Copy niri override.kdl.example to ~/.config/niri/? [y/N] "; then
        dest="$HOME/.config/niri/override.kdl"
        if [ -f "$dest" ]; then
            if ! {{ just_executable }} --quiet _confirm default="no" prompt="  $dest already exists. Overwrite? [y/N] "; then
                echo "  Skipped: $dest"
            else
                cp "{{ SRC }}/niri/override.kdl.example" "$dest"
                echo "  ✓ {{ SRC }}/niri/override.kdl.example → $dest"
                echo "  ⚠ Edit $dest to match your monitors and preferences"
            fi
        else
            mkdir -p "$HOME/.config/niri"
            cp "{{ SRC }}/niri/override.kdl.example" "$dest"
            echo "  ✓ {{ SRC }}/niri/override.kdl.example → $dest"
            echo "  ⚠ Edit $dest to match your monitors and preferences"
        fi
    else
        echo "  Skipped"
    fi
    echo ""

    echo "Setup complete. Some changes need relogin to take effect."
