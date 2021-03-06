# ~/.zprofile: executed by zsh for login shell.
# see http://zsh.sourceforge.net/Guide/zshguide02.html

# read ~/.profile
# see https://support.apple.com/kb/HT208050
[[ -e "$HOME/.profile" ]] && emulate sh -c ". $HOME/.profile"

# for Homebrew on Linux
# see https://docs.brew.sh/Homebrew-on-Linux#install
[ -d '/home/linuxbrew/.linuxbrew' ] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# for umake
[ -d "$HOME/.local/share/umake/bin" ] && PATH="$HOME/.local/share/umake/bin:$PATH"

# mainly for Ubuntu on WSL
if readlink --version >/dev/null 2>&1; then
  export DOTFILES_ROOT="$(readlink -f "$HOME/.zprofile" | sed 's:/[^/]*/[^/]*$::')"
fi
