#! /bin/bash -e

cd "$(dirname "$0")"

if uname -r | grep -q 'Microsoft'; then
  arch='UBUNTU_WSL'
else
  arch='UBUNTU_DESKTOP'
fi
printf 'arch: %s\n' $arch

UBUNTU_WSL=("home:$HOME")
UBUNTU_DESKTOP=(
  "home:$HOME"
  "vscode:$HOME/.config/Code/User"
)
case $arch in
  'UBUNTU_WSL' ) mappings=("${UBUNTU_WSL[@]}") ;;
  'UBUNTU_DESKTOP' ) mappings=("${UBUNTU_DESKTOP[@]}") ;;
esac

read -rp 'create symbolic links? (y/N): ' yn
if [ "$yn" = 'y' ]; then
  for d in "${mappings[@]}"; do
    key="${d%:*}"
    value="${d#*:}"

    files=$(find "$key" -type f ! -name '_*')
    defaultIFS="$IFS"; IFS=$'\n'
    for file in $files; do
      target="$value/${file#*/}"
      mkdir -p "${target%/*}"
      ln -is "$PWD/$file" "$target"
    done
    IFS="$defaultIFS"
  done

  . ~/.profile
fi

if [ "$arch" != 'UBUNTU_WSL' ]; then
  read -rp 'install VS Code extensions? (y/N): ' yn
  if [ "$yn" = 'y' ] && type code >/dev/null 2>&1; then
    while read -r extension; do
      code --install-extension "$extension"
    done < 'vscode/_extensions.txt'
  fi
fi
