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
  sed -i '/shellcheck/s/^\(# \)*/# /' Brewfile
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
  if ! type brew >/dev/null 2>&1; then
    # see https://brew.sh/#install
    curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh | /bin/bash
    [ -d '/home/linuxbrew/.linuxbrew' ] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi
  brew bundle
fi

read -rp 'change default shell to zsh? (y/N): ' yn
if [ "$yn" = 'y' ]; then
  grep -q 'zsh' /etc/shells || echo "$(brew --prefix)/bin/zsh" | sudo tee -a /etc/shells >/dev/null
  chsh -s "$(grep 'zsh' /etc/shells)"
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

[ "$os" != 'UBUNTU_WSL' ] && \
read -rp 'install VS Code extensions? (y/N): ' yn
if [ $? -eq 0 ] && [ "$yn" = 'y' ] && type code >/dev/null 2>&1; then
  while read -r extension; do
    if [[ "$extension" = \#* ]]; then continue; fi
    code --install-extension "$extension"
  done < vscode/_extensions.txt
fi

[ "$os" = 'MACOS' ] && \
read -rp 'customize Finder? (y/N): ' yn
if [ $? -eq 0 ] && [ "$yn" = 'y' ]; then
  # about generating .DS_Store
  defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

  defaults write com.apple.finder AppleShowAllFiles -bool true
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true
  defaults write com.apple.finder ShowPathbar -bool true

  killall Finder
fi
