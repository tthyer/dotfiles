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
    #download
    curl -v -j -k -L -H "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u112-b15/jre-8u112-macosx-x64.dmg > jre-8u112-macosx-x64.dmg
    #mount
    hdiutil attach jre-8u112-macosx-x64.dmg
    #install
    sudo installer -pkg /Volumes/Java\ 8\ Update\ 112/Java\ 8\ Update\ 112.app/Contents/Resources/JavaAppletPlugin.pkg -target /
    #cleanup
    diskutil umount /Volumes/Java\ 8\ Update\ 112 
    rm jre-8u112-macosx-x64.dmg
else
    echo "JDK 8 is already installed, skipping."
fi

# SCALA
if [[ -z "$(brew list | grep scala)" ]]; then
    echo "Installing Scala 2.11..."
    brew install scala@2.11
    echo 'Done.\n'
else
    echo "Scala 2.11 is already installed, skipping."    
fi

# SPARK
if [[ -z "$(brew list | grep spark)" ]]; then
    echo "Installing Apache Spark..."
    brew install apache-spark
    echo 'Done. Installed $(head -n 1 $SPARK_HOME/RELEASE).\n'
else
    echo "Spark is already installed, skipping."    
fi

# SUBLIME
if [[ -z "$(brew list | grep sublime)" && ! -d /Applications/Sublime\ Text.app/ ]]; then
    echo "Installing Sublime..."
    brew cask install sublime-text
    echo 'Done.\n'
else
    echo "Sublime is already installed, skipping."    
fi

# echo "Would you liked to install awscli?"
# select yn in "Yes" "No"; do
#     case $yn in
#         Yes ) "Installing awscli via brew..."; brew install awscli; echo "Done.\n"; break;;
#         No ) echo "Skipping install of awscli.\n";;
#     esac
# done

# add a section here for 