# dotfiles

My dotfiles for Ubuntu Desktop and WSL.

## install

### Ubuntu Desktop

```sh
$ git clone https://github.com/ahuglajbclajep/dotfiles.git ~/.dotfiles && ~/.dotfiles/scripts/install.sh
```

### WSL

```powershell
> $h=wsl wslpath ($HOME -replace '\\','/'); bash -c "git clone https://github.com/ahuglajbclajep/dotfiles.git $h/.dotfiles && $h/.dotfiles/scripts/install.sh"
> ~/.dotfiles/scripts/install.bat
```

## update

```sh
git pull
```
