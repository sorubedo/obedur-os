# .bashrc
# 仅在交互式会话中启用后续设置
case $- in
  *i*) ;;
    *) return;;
esac

# mise
# eval "$(~/.local/bin/mise activate bash)"

# starship
eval "$(starship init bash)"

# fzf
# eval "$(fzf --bash)"

