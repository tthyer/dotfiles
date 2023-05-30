#!/usr/bin/env bash

source ${HOME}/bash_functions.sh

java_path=$(brew --prefix openjdk) #should be like /opt/homebrew/opt/openjdk

jdk_link_path=/Library/Java/JavaVirtualMachines/openjdk.jdk

#source ${HOME}/.terminal_setup.sh

# For the system Java wrappers to find this JDK, symlink it
! test -h ${jdk_link_path} && sudo ln -sfn ${java_path}/libexec/openjdk.jdk ${jdk_link_path}

# Add to PATH
pathadd ${java_path}/bin

#echo "export CPPFLAGS=-I${java_path}/include" >> ~/.config-java-spark.sh
java_home=$(/usr/libexec/java_home)
export JAVA_HOME="${java_home}"
launchctl setenv JAVA_HOME ${java_home}
