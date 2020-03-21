# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by shell, if ~/.*profile, ~/.*login, etc., exists.
# See https://www.gnu.org/software/bash/manual/bash.html#Bash-Startup-Files and
# http://zsh.sourceforge.net/Guide/zshguide02.html for examples.

# ~/.bashrc is not automatically read
if [ -n "$BASH_VERSION" ] && [ -f "$HOME/.bashrc" ]; then
  . "$HOME/.bashrc"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ]; then PATH="$HOME/bin:$PATH"; fi
if [ -d "$HOME/.local/bin" ]; then PATH="$HOME/.local/bin:$PATH"; fi

## umake ##
if [ -d "$HOME/.local/share/umake/bin" ]; then
  PATH="$HOME/.local/share/umake/bin:$PATH"
fi

## others ##

# mainly for Ubuntu on WSL
if readlink --version >/dev/null 2>&1; then
  export DOTFILES_ROOT="$(readlink -f "$HOME/.profile" | xargs -0 dirname | xargs -0 dirname)"
fi
