# ~/.zprofile: executed by zsh for login shell.
# see http://zsh.sourceforge.net/Guide/zshguide02.html

# read ~/.profile
# see https://support.apple.com/kb/HT208050
[[ -e "$HOME/.profile" ]] && emulate sh -c ". $HOME/.profile"

# read ~/.zshrc for SSH connection
# WARNING: `. ~/.zshrc` is so slow that plugins are not read correctly
#if [ -n "$ZSH_VERSION" ] && [ -f "$HOME/.zshrc" ]; then
#  . "$HOME/.zshrc"
#fi
