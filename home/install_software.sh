#!/usr/bin/env bash

set -e

# install homebrew
echo "Installing Homebrew..."
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
echo "Done.\n"

# install Java 8 (through a download)
echo "Have you installed Java 8?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) make install; break;;
        No ) echo "Install Java 8 before proceeding. Goodbye."; exit;;
    esac
done

echo "Installing Scala 2.11..."
brew install scala@2.11
echo "Done.\n"

echo "Installing Apache Spark..."
brew install apache-spark
echo "Done. Installed $(head -n 1 $SPARK_HOME/RELEASE).\n"

# echo "Would you liked to install awscli?"
# select yn in "Yes" "No"; do
#     case $yn in
#         Yes ) "Installing awscli via brew..."; brew install awscli; echo "Done.\n"; break;;
#         No ) echo "Skipping install of awscli.\n";;
#     esac
# done

# add a section here for 