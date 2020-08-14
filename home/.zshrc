# ~/.zshrc: executed by zsh for non-login shells.
# see http://zsh.sourceforge.net/Guide/zshguide02.html

## antigen ##
if command -v brew >/dev/null 2>&1; then
  # see https://github.com/zsh-users/antigen/issues/159
  source "$(brew --prefix)/share/antigen/antigen.zsh"
else
  source "$DOTFILES_ROOT/antigen.zsh"
fi

# load plugins
antigen use oh-my-zsh

antigen bundle common-aliases
antigen bundle lukechilds/zsh-nvm
antigen bundle nvm
antigen bundle yarn
antigen bundle zdharma/fast-syntax-highlighting
#antigen bundle zsh-users/zsh-syntax-highlighting

# load theme
# see https://github.com/sindresorhus/pure/tree/v1.11.0#antigen
antigen bundle mafredri/zsh-async
antigen bundle sindresorhus/pure

# apply all bundles
antigen apply

## zsh ##
setopt nobeep
# for `zshrc` command
export EDITOR=code

## *env ##
# if ~/.nvm/* exists from the beginning, `antigen bundle lukechilds/zsh-nvm` fails due to `git clone`
if [ ! -f "$NVM_DIR/default-packages" ]; then
  echo 'yarn' > "$NVM_DIR/default-packages"
fi

## others ##
# for Homebrew on Linux
[ "$(uname)" != 'Darwin' ] && umask 002

## aliases ##
command -v xdg-open >/dev/null 2>&1 && alias open='xdg-open'
command -v visual-studio-code >/dev/null 2>&1 && alias code='visual-studio-code'

## WSL ##
if uname -r | grep -q 'Microsoft'; then
  # see https://www.kwbtblog.com/entry/2019/04/27/023411
  export LS_COLORS='ow=01;33'

  # for remote-wsl extention
  codew() { powershell.exe start code "$@"; }

  # see https://qiita.com/ahuglajbclajep/items/7e72acd689c7b302795a
  wsl-open() {
    if [ $# -ne 1 ]; then return 1; fi
    if [ -e "$1" ]; then
      local winpath=$(readlink -f "$1" | xargs -0 wslpath -w)
      powershell.exe start "\"${winpath%?}\""
    else
      powershell.exe start "$1"
    fi
  }
  alias open='wsl-open'
fi
