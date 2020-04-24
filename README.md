# dotfiles

My dotfiles for macOS Catalina and Ubuntu 18.04.

## install

### macOS

```sh
# see https://stackoverflow.com/questions/15371925/how-to-check-if-command-line-tools-is-installed
$ if ! xcode-select -p 1>/dev/null; then xcode-select --install; fi
$ git clone https://github.com/ahuglajbclajep/dotfiles.git ~/.dotfiles && ~/.dotfiles/install.sh
```

### Ubuntu Desktop

```sh
$ sudo apt-get install build-essential curl file git
$ git clone https://github.com/ahuglajbclajep/dotfiles.git ~/.dotfiles && ~/.dotfiles/install.sh
```

### Ubuntu on WSL

```powershell
> $h=wsl wslpath ($HOME -replace '\\','/'); bash -c "git clone https://github.com/ahuglajbclajep/dotfiles.git $h/.dotfiles && $h/.dotfiles/install.sh"
> ~/.dotfiles/windows/install.bat
```

## update

```sh
$ git pull
```
