# .bash_profile
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# eval "$(mise activate bash --shims)"

if [[ -f ~/.bashrc ]] ; then
	. ~/.bashrc
fi
