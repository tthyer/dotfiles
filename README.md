# dotfiles

Personal dotfiles and machine setup scripts.

## Setup

```bash
git clone git@github.com:tthyer/dotfiles.git
cd dotfiles
./install.sh
```

`install.sh` symlinks dotfiles, sets bash as default shell, installs Homebrew packages, and runs setup scripts.

Ghostty config is linked to `~/Library/Application Support/com.mitchellh.ghostty/config`. Put machine-specific overrides in `~/Library/Application Support/com.mitchellh.ghostty/local.ghostty`; that file is optional and intentionally not tracked.

## Structure

```
shell/          bash_profile, bashrc, bash_functions, terminal/warp setup
git/            gitconfig, gitignore_global
k8s/            kubectl aliases and helpers
vim/            vimrc
java/           java-setup.sh (sourced by bash_profile)
setup/          one-time install scripts (python, git ssh)
config/         app configs (ghostty, himalaya, sublime)
archive/        retired configs kept for reference
dotfiles.sh     symlink manager
install.sh      main setup orchestrator
```
