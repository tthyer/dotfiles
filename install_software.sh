#!/usr/bin/env bash

set -e

# ITERM
if [[ ! -d "/Applications/iTerm.app" ]]; then
    echo "Installing iTerm"
    curl -o "iterm.zip" -L "https://iterm2.com/downloads/stable/latest"
    unzip "iterm.zip"
    sudo mv "iTerm.app" "/Applications"
    rm "iterm.zip"
    echo 'Done.\n'
else
    echo "iTerm is already installed, skipping."
fi

# HOMEBREW
if [[ -z "$(which brew)" ]]; then
    echo "Installing Homebrew..."
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    echo 'Done.\n'
else
    echo "Homebrew is already installed, skipping."
fi

# JDK
if [[ -z "$(ls /Library/Java/JavaVirtualMachines/ | grep jdk)" ]]; then
    echo "Installing JDK 8..."
    # download with options junk-session-cookies, insecure, redirect to new location, header specified
    curl --j -k -L -H "Cookie: oraclelicense=accept-securebackup-cookie" \
        -o jdk-8u201-macosx-x64.dmg \
        https://download.oracle.com/otn-pub/java/jdk/8u201-b09/jdk-8u201-macosx-x64.dmg
    # mount
    hdiutil attach jdk-8u201-macosx-x64.dmg
    # install
    sudo installer -pkg /Volumes/Java\ 8\ Update\ 201/Java\ 8\ Update\ 201.app/Contents/Resources/JavaAppletPlugin.pkg -target /
    # cleanup
    diskutil umount /Volumes/Java\ 8\ Update\ 201
    rm jdk-8u201-macosx-x64.dmg
else
    echo "JDK 8 is already installed, skipping."
fi

# Things I like to install through Homebrew
# apache-spark is available but need to control the version
brew_things=( scala@2.11 sbt tree wget gnu-sed bash-completion python maven jq parquet-tools awscli )
for i in "${brew_things[@]}"
do
    if [[ -z "$(brew list | grep $i)" ]]; then
        echo "Installing $i through Homebrew..."
        brew install $i
        echo 'Done.\n'
    else
        echo "$i is already installed, skipping."
    fi
done

# SPARK
# if [[ -z "$(brew list | grep spark)" ]]; then
#     echo "Installing Apache Spark..."
#     brew install apache-spark
#     echo 'Done. Installed $(head -n 1 $SPARK_HOME/RELEASE).\n'
# else
#     echo "Spark is already installed, skipping."    
# fi
if [[ -z "$(which spark-submit)" ]]; then
    echo "Installing Apache Spark 2.3.2..."
    # download with options junk-session-cookies, insecure, redirect to new location
    curl -j -k -L -o spark-2.3.2-bin-hadoop2.7.tgz https://www-us.apache.org/dist/spark/spark-2.3.2/spark-2.3.2-bin-hadoop2.7.tgz
    # untar to root
    echo "You will be prompted for your password to unpack spark at root."
    sudo tar -zxvf spark-2.3.2-bin-hadoop2.7.tgz -C /
    # cleanup
    rm spark-2.3.2-bin-hadoop2.7.tgz

    echo "Spark is installed; remember to add /spark-2.3.2-bin-hadoop2.7/bin to PATH."
    # TODO check whether it is added and if not then add export line in ~/.bash_profile and source it
else
    echo "Spark is already installed, skipping."
fi

# SUBLIME
# if [[ -z "$(brew list | grep sublime-text)" && ! -d /Applications/Sublime\ Text.app/ ]]; then
#     echo "Installing Sublime..."
#     brew cask install sublime-text
#     echo 'Done.\n'
# else
#     echo "Sublime is already installed, skipping."    
# fi

# INTELLIJ
# if [[ -z "$(brew list | grep intellij-idea-ce)" && ! -d /Applications/IntelliJ\ IDEA\ CE.app/ ]]; then
#     echo "Installing Intellij CE..."
#     brew cask install intellij-idea-ce
#     echo 'Done.\n'
# else
#     echo "Intellij CE is already installed, skipping."
# fi

cask_things=( sublime-text intellig-idea-ce google-chrome )
for i in "${cask_things[@]}"
do
    if [[ -z "$(brew list | grep $i)" ]]; then
        echo "Installing $i through Homebrew Cask..."
        brew cask install $i
        echo 'Done.\n'
    else
        echo "$i is already installed, skipping."
    fi
done

other_things_todo=(
    "Log into Chrome"
    "Install LastPass extension in Chrome"
    "Paste license into Sublime"
    "Sync Sublime Settings"
    )

echo "Other things to do:"
for i in "${other_things_todo[@]}"
do
    echo $i
done

# Set bottom left hot corner to sleep display
defaults write com.apple.dock wvous-bl-corner -int 10
defaults write com.apple.dock wvous-bl-modifier -int 0
killall Dock
