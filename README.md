# My Personal Dotfiles

This is my personal `tmux`, `zsh` and `neovim` configuration

## Requirements

```bash
sudo apt install -y tmux zsh neovim stow
```

## Instalation

- clone this repository:
```bash
git clone git@github.com:LOCNNIL/dotfiles.git
```

- Get the submodules:
```bash
git submodule update --init --recursive
```

- From inside the folder run stow to apply the configs:
```bash
# Apply for tmux:
stow tmux

# Zsh Config:
# 1- first, change the default shell:
chsh 
# On the prompted query type:
# /usr/bin/zsh
# Apply for zsh:
stow zsh

# Apply for neovim:
stow neovim
```
