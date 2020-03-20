# ~/.zshrc: executed by zsh for non-login shells.
# see http://zsh.sourceforge.net/Guide/zshguide02.html

## antigen ##
# see https://github.com/zsh-users/antigen/issues/159
source "$(brew --prefix)/share/antigen/antigen.zsh"

# load plugins
antigen use oh-my-zsh

antigen bundle common-aliases
antigen bundle lukechilds/zsh-nvm
antigen bundle nvm
antigen bundle yarn

antigen bundle zsh-users/zsh-syntax-highlighting

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

## nvm ##
# if ~/.nvm/* exists from the beginning, `git clone` fails
if [ ! -f "$NVM_DIR/default-packages" ]; then
  printf 'yarn\n' > "$NVM_DIR/default-packages"
fi
