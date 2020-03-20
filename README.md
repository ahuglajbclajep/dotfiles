# dotfiles

My dotfiles for Ubuntu 18.04.

## install

### Ubuntu Desktop

```sh
$ git clone https://github.com/ahuglajbclajep/dotfiles.git ~/.dotfiles && ~/.dotfiles/install.sh
```

### WSL

```powershell
> $h=wsl wslpath ($HOME -replace '\\','/'); bash -c "git clone https://github.com/ahuglajbclajep/dotfiles.git $h/.dotfiles && $h/.dotfiles/install.sh"
> ~/.dotfiles/windows/install.bat
```

## update

```sh
$ git pull
```
