# dotfiles

My dotfiles for Ubuntu Desktop and WSL.

## install

### Ubuntu Desktop

```sh
$ git clone https://github.com/ahuglajbclajep/dotfiles.git ~/.dotfiles && ~/.dotfiles/scripts/install.sh
```

### WSL

[WSL](https://www.microsoft.com/store/apps/9n9tngvndl3q) and [WT](https://www.microsoft.com/store/apps/9n0dx20hk701) are required.

```powershell
> $h=wsl wslpath ($HOME -replace '\\','/'); bash -c "git clone https://github.com/ahuglajbclajep/dotfiles.git $h/.dotfiles && $h/.dotfiles/scripts/install.sh"
> ~/.dotfiles/scripts/install.bat
```

## update

```sh
git pull
```
