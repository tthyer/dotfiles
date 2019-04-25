#!/usr/bin/env bash

set -e

# Fix this check
#if [[ -z "$(xcode-select --install 2>&1 | grep installed)" ]]; then
#  echo "Xcode command line tools already installed, skipping."
#else
#  echo "Installing xcode command line tools"
#   xcode-select --install
#fi

# ITERM
if [[ ! -d "/Applications/iTerm.app" ]]; then
    echo "Installing iTerm"
    curl -o "iterm.zip" -L "https://iterm2.com/downloads/stable/latest"
    unzip "iterm.zip"
    sudo mv "iTerm.app" "/Applications"
    rm "iterm.zip"
    echo "Done."
else
    echo "iTerm is already installed, skipping."
fi

# HOMEBREW
if [[ -z "$(which brew)" ]]; then
    echo "Installing Homebrew..."
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    echo "Done."
else
    echo "Homebrew is already installed, skipping."
fi

required_brew_dirs=( /usr/local/include /usr/local/opt /usr/local/sbin/ /usr/local/Cellar /usr/local/Frameworks)
for i in "${required_brew_dirs[@]}"
do
    if [[ ! -d $i ]]; then
        echo "Making required brew directory $i"
        sudo mkdir -p $i
        sudo chown -R $(whoami) $i
    else
        echo "Required directory $i already exists"
    fi
done

cask_things=( java8 sublime-text intellij-idea-ce font-inconsolata-dz dropbox r rstudio docker slack ) #google-chrome can be installed this way, too
cask_locs=( homebrew/cask-versions/java8 sublime-text intellij-idea-ce homebrew/cask-fonts/font-inconsolata-dz dropbox r rstudio docker slack)
for idx in "${!cask_things[@]}"
do
    thing=${cask_things[$idx]}
    cask=${cask_locs[$idx]}
    if [[ -z "$(brew cask list | grep $thing)" ]]; then
        echo "Installing $i through Homebrew Cask..."
        brew cask install $cask
        echo "Done."
    else
        echo "$thing is already installed, skipping."
    fi
done

# Things I like to install through Homebrew
# apache-spark is available but need to control the version
brew_things=( scala@2.11 sbt tree wget gnu-sed bash-completion python maven jq parquet-tools awscli graphviz)
for i in "${brew_things[@]}"
do
    if [[ -z "$(brew list | grep $i)" ]]; then
        echo "Installing $i through Homebrew..."
        brew install $i
        echo "Done."
    else
        echo "$i is already installed, skipping."
    fi
done

# This keeps throwing an archive format error -- fix this.
# if [[ ! -d /spark-2.3.2-bin-hadoop2.7 ]]; then
#     echo "Installing Apache Spark 2.3.2..."
#     # download with options junk-session-cookies, insecure, redirect to new location
#     curl -j -k -L -o spark-2.3.2-bin-hadoop2.7.tgz https://www-us.apache.org/dist/spark/spark-2.3.2/spark-2.3.2-bin-hadoop2.7.tgz
#     # untar to root
#     echo "You will be prompted for your password to unpack spark at root."
#     sudo tar -zxvf spark-2.3.2-bin-hadoop2.7.tgz -C /
#     # cleanup
#     rm spark-2.3.2-bin-hadoop2.7.tgz

#     echo "Spark is installed; remember to add /spark-2.3.2-bin-hadoop2.7/bin to PATH."
#     # TODO check whether it is added and if not then add export line in ~/.bash_profile and source it
# else
#     echo "Spark is already installed, skipping."
# fi

./install.sh
source $HOME/.bash_profile
python -m pip install --upgrade pip
python -m pip install jupyterlab flake8 yapf pandas numpy synapseclient

other_things_todo=(
    "Log into Chrome"
    "Install LastPass extension in Chrome"
    "Paste license into Sublime"
    "Sync Sublime Settings"
    "Log into Dropbox"
    "Goto https://coderwall.com/p/h6yfda/use-and-to-jump-forwards-backwards-words-in-iterm-2-on-os-x for instructions on how to set up word navigation in iTerm"
    "TODO: find other keys configuration needed for iTerm"
    "Open Docker Desktop and login. You will also need to login on the command line."
    )

echo "Other things to do:"
for i in "${other_things_todo[@]}"
do
    echo $i
done

# Set bottom left hot corner to sleep display
echo "Setting hot corner..."
defaults write com.apple.dock wvous-bl-corner -int 10
defaults write com.apple.dock wvous-bl-modifier -int 0
killall Dock
echo "Done."

# Package control for Sublime
if [[ ! -f "$HOME/Library/Application Support/Sublime Text 3/Installed Packages/Package Control.sublime-package" ]]; then
    echo "Installing package control for Sublime. This will take effect when Sublime restarts."
    wget https://packagecontrol.io/Package%20Control.sublime-package --directory-prefix="$HOME/Library/Application Support/Sublime Text 3/Installed Packages/"
    echo "Done."
else
    echo "Package control for Sublime has already been installed."
fi

sublime_things_to_do=(
    "Pretty JSON"
    "SublimeLinter"
    "SublimeLinter-flake8"
    )
echo "Things to install for Sublime through Package Control:"
for i in "${sublime_things_to_do[@]}"
do
    echo $i
done

