#! /bin/bash -e

cd "$(dirname "$0")"

if [ "$(uname)" = 'Darwin' ]; then
  os='MACOS'
  find . -type f -name '.DS_Store' -delete
  # see https://support.apple.com/kb/HT208050
  [ ! -f "$HOME/.bashrc" ] && echo 'export BASH_SILENCE_DEPRECATION_WARNING=1' > "$HOME/.bashrc"
elif uname -v | grep -q 'Ubuntu'; then
  os='UBUNTU_DESKTOP'
else
  os='UBUNTU_WSL'
  sed -i '/shellcheck/s/^#*/#/' Brewfile
fi

MACOS=(
  "home:$HOME"
  "vscode:$HOME/Library/Application Support/Code/User"
)
UBUNTU_DESKTOP=(
  "home:$HOME"
  "vscode:$HOME/.config/Code/User"
)
UBUNTU_WSL=("home:$HOME")
case $os in
  'MACOS' ) mappings=("${MACOS[@]}") ;;
  'UBUNTU_DESKTOP' ) mappings=("${UBUNTU_DESKTOP[@]}") ;;
  'UBUNTU_WSL' ) mappings=("${UBUNTU_WSL[@]}") ;;
esac


printf 'run in %s mode.\n' $os

read -rp 'install homebrew and formulae? (y/N): ' yn
if [ "$yn" = 'y' ]; then
  if ! command -v brew >/dev/null 2>&1; then
    # see https://brew.sh/#install
    curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh | /bin/bash
    [ -d '/home/linuxbrew/.linuxbrew' ] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi
  brew bundle
fi

# if `false && read yn`, yn is not updated, so check if `read` was called on `[ $? -eq 0 ]`
! command -v zsh >/dev/null 2>&1 && command -v apt >/dev/null 2>&1 && \
read -rp 'install zsh via apt? (y/N): ' yn
if [ $? -eq 0 ] && [ "$yn" = 'y' ]; then
  # see https://github.com/ohmyzsh/ohmyzsh/wiki/Installing-ZSH
  sudo sh -c 'apt-get update && apt-get -y install zsh'
  # see https://github.com/zsh-users/antigen/issues/659
  curl -sSLo antigen.zsh git.io/antigen
fi

command -v zsh >/dev/null 2>&1 && \
read -rp 'change default shell to zsh? (y/N): ' yn
if [ $? -eq 0 ] && [ "$yn" = 'y' ]; then
  grep -q 'zsh' /etc/shells || command -v zsh | sudo tee -a /etc/shells >/dev/null
  chsh -s "$(command -v zsh)"
fi

read -rp 'create symbolic links? (y/N): ' yn
if [ "$yn" = 'y' ]; then
  for mapping in "${mappings[@]}"; do
    from="${mapping%:*}"
    to="${mapping#*:}"

    files=$(find "$from" -type f ! -name '_*')
    defaultIFS="$IFS"; IFS=$'\n'
    for file in $files; do
      target="$to/${file#*/}"
      mkdir -p "${target%/*}"
      ln -is "$PWD/$file" "$target"
    done
    IFS="$defaultIFS"
  done
fi

[ "$os" = 'UBUNTU_DESKTOP' ] && ! command -v code >/dev/null 2>&1 && \
read -rp 'install VS Code via umake? (y/N): ' yn
if [ $? -eq 0 ] && [ "$yn" = 'y' ]; then
  if ! command -v umake >/dev/null 2>&1; then
    # see https://github.com/ubuntu/ubuntu-make#ppa
    sudo sh -c 'add-apt-repository -y ppa:lyzardking/ubuntu-make && apt-get update && apt-get -y install ubuntu-make'
  fi
  # see https://github.com/ubuntu/ubuntu-make/issues/403
  umake ide visual-studio-code --accept-license "$HOME/.local/share/umake/ide/visual-studio-code"
fi

# for install VS Code extensions
# see https://unix.stackexchange.com/questions/1496/why-doesnt-my-bash-script-recognize-aliases
command -v visual-studio-code >/dev/null 2>&1 && code() { visual-studio-code "$@"; }

[ "$os" != 'UBUNTU_WSL' ] && command -v code >/dev/null 2>&1 && \
read -rp 'install VS Code extensions? (y/N): ' yn
if [ $? -eq 0 ] && [ "$yn" = 'y' ]; then
  while read -r extension; do
    [[ "$extension" =~ ^\# ]] && continue
    code --install-extension "$extension"
  done < vscode/_extensions.txt
fi

[ "$os" = 'MACOS' ] && \
read -rp 'customize Finder? (y/N): ' yn
if [ $? -eq 0 ] && [ "$yn" = 'y' ]; then
  # about display
  defaults write com.apple.finder AppleShowAllFiles -bool true
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true
  defaults write com.apple.finder ShowPathbar -bool true

  # about generating .DS_Store
  defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

  killall Finder
fi
