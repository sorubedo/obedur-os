# .bashrc
# 仅在交互式会话中启用后续设置
case $- in
  *i*) ;;
    *) return;;
esac

export HISTSIZE=100000
export HISTFILESIZE=100000
export HISTCONTROL=ignoreboth:erasedups

# starship
eval "$(starship init bash)"

# fzf
eval "$(fzf --bash)"
