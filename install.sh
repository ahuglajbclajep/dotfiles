#!/bin/bash -e

cd "$(dirname "$0")"
files=$(find . -type f ! -path '*/.git/*' ! -path '*/other/*' ! -name 'install.sh' ! -name 'README.md')
IFS=$'\n'
for file in $files; do
  target=~/${file#./}
  mkdir -p "${target%/*}"
  ln -is "$PWD/${file#./}" "$target"
done
. ~/.profile

read -rp 'install VS Code extensions? (y/N): ' yn
if [ "$yn" = 'y' ] && type code > /dev/null 2>&1; then
  while read -r line; do
    code --install-extension "$line"
  done < 'other/vscode-extensions.txt'
fi
